import "dart:async";
import "dart:math";

import "package:flutter/material.dart";
import "package:flutter/rendering.dart";

import "mobile_devtool_controller.dart";
import "mobile_devtool_exclude_from_fuzz_tap.dart";
import "mobile_devtool_fuzz_run_log.dart";
import "mobile_devtool_fuzz_run_preset.dart";

/// Random-tap crash/exception fuzzer. Each tick: walks the current widget
/// tree, finds render objects that expose a `SemanticsAction.tap` (Material
/// buttons, `InkWell`, `GestureDetector`, `Switch`/`Checkbox`/`Radio`,
/// Cupertino controls, or any app-specific widget built on top of them —
/// whatever exposes tap to accessibility services also exposes it here),
/// occasionally scrolls a random `Scrollable`, then invokes one random target
/// through the same `SemanticsOwner.performAction` accessibility services use
/// to "activate" a focused element. This does NOT hit-test or simulate a real
/// gesture, so it cannot replace Patrol/integration_test — it is only meant
/// for fast crash-hunting during manual debugging.
///
/// Does not handle `TextField` or native pickers (image/file) — those are
/// excluded by [_pickerKeywords] since the runner cannot dismiss a native
/// picker it cannot hit-test; if one still slips through, the runner stops
/// itself after [_stuckTickThreshold] ticks with no target found.
class MobileDevToolFuzzTapRunner {
  MobileDevToolFuzzTapRunner({
    required this.log,
    required this.networkController,
    this.currentRouteKey,
  });

  /// Session/step history — see [MobileDevToolFuzzRunLog].
  final MobileDevToolFuzzRunLog log;

  /// Source of network errors that should stop a running session.
  final MobileDevToolController networkController;

  /// Host-supplied accessor for the current route's identity (e.g. from an
  /// `AutoRoute`/`Navigator` observer) — required only for
  /// `restrictToCurrentRoute`; when omitted, that option has no effect.
  final String Function()? currentRouteKey;

  static const _stuckTickThreshold = 3;

  /// Every [_scrollEveryNTicks] ticks, prefer a scroll over a tap — sparse
  /// enough not to crowd out tapping, dense enough to reveal content outside
  /// the initial viewport (long lists, scrollable sheets...).
  static const _scrollEveryNTicks = 3;

  static const _scrollExtent = 240.0;

  static const _pickerKeywords = [
    "ảnh",
    "photo",
    "camera",
    "chụp",
    "chọn file",
    "file",
    "gallery",
    "thư viện",
    "upload",
    "tải lên",
  ];

  Timer? _timer;
  Timer? _sessionTimer;
  SemanticsHandle? _semanticsHandle;
  final _random = Random();

  MobileDevToolFuzzRunConfig? _config;
  String? _startRouteKey;
  Duration? _remainingSessionDuration;
  DateTime? _sessionDeadline;
  int _tickCount = 0;
  int _emptyTickStreak = 0;
  Set<String> _seenNetworkErrorIds = {};
  bool _semanticsReady = false;
  bool _active = false;
  bool _paused = false;

  bool get isRunning => _active;
  bool get isPaused => _active && _paused;
  bool get hasTimeLimit => _remainingSessionDuration != null;

  MobileDevToolFuzzRunConfig? get lastConfig => _config;

  void start({required MobileDevToolFuzzRunConfig config}) {
    if (isRunning) return;
    _config = config;
    _active = true;
    _paused = false;
    _semanticsHandle = SemanticsBinding.instance.ensureSemantics();
    _startRouteKey = currentRouteKey?.call();
    _tickCount = 0;
    _emptyTickStreak = 0;
    _semanticsReady = false;
    _seenNetworkErrorIds = networkController.networkEntries
        .where((e) => e.status == MobileDevToolNetworkStatus.error)
        .map((e) => e.id)
        .toSet();
    final durationLabel = config.sessionDuration == null
        ? "không giới hạn"
        : "${config.sessionDuration}";
    log.start(
      config.label,
      "Bắt đầu fuzz tap — ${config.label} (tick ${config.tickInterval}, thời lượng $durationLabel)",
    );
    _startTickTimer();
    // `ensureSemantics()` enables the pipeline, but the first semantics tree
    // is produced by a frame. Without waiting for that frame, an aggressive
    // preset can spend its first few ticks against an empty tree and stop as
    // "stuck" even though the screen contains tappable widgets.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isRunning && !isPaused) _semanticsReady = true;
    });
    final sessionDuration = config.sessionDuration;
    if (sessionDuration != null) {
      _remainingSessionDuration = sessionDuration;
      _resumeSessionTimer();
    }
  }

  void stop() {
    if (!isRunning) return;
    _stopInternal();
    log.stopByUser();
  }

  void pause() {
    if (!isRunning || isPaused) return;
    _timer?.cancel();
    _timer = null;
    _pauseSessionTimer();
    _paused = true;
    log.pause();
    log.log("Đã tạm dừng phiên fuzz");
  }

  void resume() {
    if (!isRunning || !isPaused) return;
    _paused = false;
    log.resume();
    log.log("Tiếp tục phiên fuzz");
    _startTickTimer();
    _resumeSessionTimer();
  }

  /// Adjusts the remaining timed-run duration. A positive [adjustment]
  /// fast-forwards the session; a negative value rewinds it.
  void skip(Duration adjustment) {
    if (!isRunning || _remainingSessionDuration == null) return;

    final wasPaused = isPaused;
    if (!wasPaused) _pauseSessionTimer();
    final remaining = _remainingSessionDuration! - adjustment;
    _remainingSessionDuration = remaining.isNegative
        ? Duration.zero
        : remaining;
    log.adjustElapsed(adjustment);
    log.log(
      adjustment.isNegative
          ? "Tua lại ${adjustment.abs().inSeconds}s"
          : "Tua nhanh ${adjustment.inSeconds}s",
    );

    if (_remainingSessionDuration == Duration.zero && !adjustment.isNegative) {
      _stopInternal();
      log.stopTimeLimit("đã tua đến hết thời lượng phiên");
      return;
    }
    if (!wasPaused) _resumeSessionTimer();
  }

  void restartLast() {
    final config = _config;
    if (config == null || isRunning) return;
    start(config: config);
  }

  void _tickOnce() {
    _checkNetworkErrors();
    if (!isRunning || isPaused) return;
    if (_checkRouteRestriction()) return;
    if (!_semanticsReady) return;

    try {
      final rootElement = WidgetsBinding.instance.rootElement;
      if (rootElement == null) {
        log.log("Chưa có rootElement, bỏ qua lượt này");
        return;
      }

      _tickCount++;
      if (_tickCount % _scrollEveryNTicks == 0 && _tryScroll(rootElement))
        return;

      final targets = <_FuzzTarget>[];
      final semanticsRoots = RendererBinding.instance.renderViews
          .map((view) => view.owner?.semanticsOwner?.rootSemanticsNode)
          .whereType<SemanticsNode>()
          .toList();
      if (semanticsRoots.isEmpty) {
        log.log("Chưa có semantics tree, bỏ qua lượt này");
        return;
      }
      for (final semanticsRoot in semanticsRoots) {
        _collectTargets(semanticsRoot, targets, <int>{});
      }

      if (targets.isEmpty) {
        _emptyTickStreak++;
        log.log(
          "Không tìm thấy widget bấm được ($_emptyTickStreak/$_stuckTickThreshold)",
        );
        if (_emptyTickStreak >= _stuckTickThreshold) {
          _stopInternal();
          log.stopStuck(
            "không tìm thấy widget bấm được sau $_stuckTickThreshold lượt liên tiếp (có thể đang bị picker/dialog ngoài Flutter che)",
          );
        }
        return;
      }

      _emptyTickStreak = 0;
      final target = targets[_random.nextInt(targets.length)];
      log.logTap("Bấm ${target.label}");
      target.invoke();
    } on Object catch (error, stackTrace) {
      log.logError("LỖI — $error\n$stackTrace");
    }
  }

  /// Returns `true` if the runner stopped due to a route change (only
  /// applies when `restrictToCurrentRoute` and a [currentRouteKey] accessor
  /// were supplied).
  bool _checkRouteRestriction() {
    final config = _config;
    final routeKeyOf = currentRouteKey;
    if (config == null || !config.restrictToCurrentRoute || routeKeyOf == null)
      return false;
    final current = routeKeyOf();
    if (current == _startRouteKey) return false;

    if (_startRouteKey == null) {
      _startRouteKey = current;
      return false;
    }

    _stopInternal();
    log.stopStuck(
      "đã điều hướng sang màn khác ($_startRouteKey → $current) — dừng do giới hạn 1 màn hình",
    );
    return true;
  }

  /// Best-effort: finds a `ScrollableState` in the current subtree and jumps
  /// it a random distance (possibly negative). Returns `false` (tick not
  /// consumed) if no scrollable can currently scroll.
  bool _tryScroll(Element rootElement) {
    final scrollables = <ScrollableState>[];
    void collect(Element element) {
      final widget = element.widget;
      if (widget is! ExcludeFromFuzzTap) {
        if (widget is Scrollable &&
            element is StatefulElement &&
            element.state is ScrollableState) {
          scrollables.add(element.state as ScrollableState);
        }
        element.visitChildren(collect);
      }
    }

    collect(rootElement);
    if (scrollables.isEmpty) return false;

    final scrollable = scrollables[_random.nextInt(scrollables.length)];
    final position = scrollable.position;
    if (!position.hasContentDimensions ||
        position.maxScrollExtent <= position.minScrollExtent)
      return false;

    final direction = _random.nextBool() ? 1 : -1;
    final target = (position.pixels + direction * _scrollExtent).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (target == position.pixels) return false;

    log.log("Cuộn Scrollable (${direction > 0 ? 'xuống/phải' : 'lên/trái'})");
    position.jumpTo(target);
    return true;
  }

  bool _looksLikePicker(String label, List<String> extraKeywords) {
    final lower = label.toLowerCase();
    return _pickerKeywords.any(lower.contains) ||
        extraKeywords.any((keyword) => lower.contains(keyword.toLowerCase()));
  }

  /// Walks the public semantics tree looking for nodes exposing a
  /// `SemanticsAction.tap`. This is the same action accessibility services
  /// invoke to activate a focused element, and unlike `debugSemantics` it is
  /// available in profile and release builds too.
  void _collectTargets(
    SemanticsNode node,
    List<_FuzzTarget> out,
    Set<int> seenIds,
  ) {
    final data = node.getSemanticsData();
    if (data.flagsCollection.isHidden ||
        data.tags?.contains(mobileDevToolFuzzTapExcludeTag) == true)
      return;

    if (data.hasAction(SemanticsAction.tap) && seenIds.add(node.id)) {
      final label = data.label.isNotEmpty ? data.label : "không rõ nhãn";
      final extraKeywords = _config?.extraExcludeKeywords ?? const [];
      if (!_looksLikePicker(label, extraKeywords)) {
        final semanticsOwner = node.owner;
        if (semanticsOwner != null) {
          out.add(
            _FuzzTarget(
              label: '"$label"',
              invoke: () =>
                  semanticsOwner.performAction(node.id, SemanticsAction.tap),
            ),
          );
        }
      }
    }

    node.visitChildren((child) {
      _collectTargets(child, out, seenIds);
      return true;
    });
  }

  void _checkNetworkErrors() {
    if (!isRunning) return;
    final errorEntry = networkController.networkEntries
        .where((e) => e.status == MobileDevToolNetworkStatus.error)
        .where((e) => !_seenNetworkErrorIds.contains(e.id))
        .firstOrNull;
    if (errorEntry == null) return;

    _stopInternal();
    log.stopNetworkError("${errorEntry.request.label} — ${errorEntry.error}");
  }

  void _stopInternal() {
    _timer?.cancel();
    _timer = null;
    _sessionTimer?.cancel();
    _sessionTimer = null;
    _sessionDeadline = null;
    _remainingSessionDuration = null;
    _active = false;
    _paused = false;
    _semanticsReady = false;
    _semanticsHandle?.dispose();
    _semanticsHandle = null;
  }

  void _startTickTimer() {
    final config = _config;
    if (config == null) return;
    _timer?.cancel();
    _timer = Timer.periodic(config.tickInterval, (_) => _tickOnce());
  }

  void _pauseSessionTimer() {
    final deadline = _sessionDeadline;
    if (deadline != null) {
      final remaining = deadline.difference(DateTime.now());
      _remainingSessionDuration = remaining.isNegative
          ? Duration.zero
          : remaining;
    }
    _sessionTimer?.cancel();
    _sessionTimer = null;
    _sessionDeadline = null;
  }

  void _resumeSessionTimer() {
    final remaining = _remainingSessionDuration;
    if (remaining == null || remaining == Duration.zero || isPaused) return;
    _sessionTimer?.cancel();
    _sessionDeadline = DateTime.now().add(remaining);
    _sessionTimer = Timer(remaining, () {
      if (!isRunning || isPaused) return;
      _stopInternal();
      log.stopTimeLimit("hết thời lượng phiên");
    });
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _FuzzTarget {
  _FuzzTarget({required this.label, required this.invoke});

  final String label;
  final VoidCallback invoke;
}
