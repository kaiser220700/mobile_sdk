import "dart:ui";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "mobile_devtool_fuzz_preset_sheet.dart";
import "mobile_devtool_fuzz_run_log.dart";
import "mobile_devtool_fuzz_tap_runner.dart";
import "mobile_devtool_theme.dart";

/// Full-screen Fuzz Tap overlay. The top panel owns setup and run controls;
/// the lower edge is reserved for a live-style log stream.
class MobileDevToolFuzzTapOverlay extends StatefulWidget {
  const MobileDevToolFuzzTapOverlay({
    required this.runner,
    required this.log,
    required this.onClose,
    super.key,
  });

  final MobileDevToolFuzzTapRunner runner;
  final MobileDevToolFuzzRunLog log;
  final VoidCallback onClose;

  @override
  State<MobileDevToolFuzzTapOverlay> createState() =>
      _MobileDevToolFuzzTapOverlayState();
}

class _MobileDevToolFuzzTapOverlayState
    extends State<MobileDevToolFuzzTapOverlay> {
  static const _scrimKey = ValueKey("fuzz-overlay-scrim");
  int? _handledTerminalSessionId;
  MobileDevToolFuzzRunSession? _terminalDialogSession;
  bool _presetSheetOpen = false;

  void _closeOverlay() {
    if (widget.runner.isRunning) widget.runner.stop();
    widget.onClose();
  }

  void _maybeShowTerminalDialog(MobileDevToolFuzzRunSession? session) {
    if (session == null || session.isRunning) return;
    if (session.status == MobileDevToolFuzzRunStatus.stoppedByUser) return;
    if (_handledTerminalSessionId == session.id) return;
    _handledTerminalSessionId = session.id;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _terminalDialogSession = session);
    });
  }

  void _handleTerminalDialog(bool rerun) {
    if (_terminalDialogSession == null) return;
    setState(() => _terminalDialogSession = null);
    if (rerun) {
      widget.runner.restartLast();
    }
  }

  void _openPresetSheet() => setState(() => _presetSheetOpen = true);

  void _closePresetSheet() {
    if (!_presetSheetOpen) return;
    setState(() => _presetSheetOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: AnimatedBuilder(
        animation: widget.log,
        builder: (context, _) {
          final mediaQuery = MediaQuery.of(context);
          final session = widget.log.currentSession;
          _maybeShowTerminalDialog(session);

          return Stack(
            fit: StackFit.expand,
            children: [
              IgnorePointer(
                child: ColoredBox(
                  key: _scrimKey,
                  color: MobileDevToolTheme.fuzzOverlayScrim,
                ),
              ),
              if (session != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _FuzzLogStream(
                    session: session,
                    bottomSafeArea: mediaQuery.viewPadding.bottom,
                  ),
                ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: _ExpandedPanel(
                  session: session,
                  onClose: _closeOverlay,
                  topInset: mediaQuery.viewPadding.top,
                  onOpenCustomSheet: _openPresetSheet,
                ),
              ),
              if (session?.isRunning ?? false)
                Align(
                  alignment: Alignment.center,
                  child: _FuzzRunControls(
                    runner: widget.runner,
                    session: session!,
                  ),
                ),
              if (_presetSheetOpen)
                _FuzzPresetSheetOverlay(
                  runner: widget.runner,
                  onClose: _closePresetSheet,
                ),
              if (_terminalDialogSession case final dialogSession?)
                _FuzzTerminalDialog(
                  session: dialogSession,
                  onDismiss: () => _handleTerminalDialog(false),
                  onRerun: () => _handleTerminalDialog(true),
                ),
            ],
          );
        },
      ),
    );
  }
}

Color _statusColor(BuildContext context, MobileDevToolFuzzRunSession? session) {
  final scheme = Theme.of(context).colorScheme;
  if (session == null) return Theme.of(context).hintColor;
  if (session.isRunning) return scheme.primary;
  return switch (session.status) {
    MobileDevToolFuzzRunStatus.stoppedNetworkError ||
    MobileDevToolFuzzRunStatus.stoppedStuck => scheme.error,
    MobileDevToolFuzzRunStatus.running ||
    MobileDevToolFuzzRunStatus.paused ||
    MobileDevToolFuzzRunStatus.stoppedByUser ||
    MobileDevToolFuzzRunStatus.stoppedTimeLimit => Theme.of(context).hintColor,
  };
}

class _ExpandedPanel extends StatelessWidget {
  const _ExpandedPanel({
    required this.session,
    required this.onClose,
    required this.topInset,
    required this.onOpenCustomSheet,
  });

  final MobileDevToolFuzzRunSession? session;
  final VoidCallback onClose;
  final double topInset;
  final VoidCallback onOpenCustomSheet;

  @override
  Widget build(BuildContext context) {
    final currentSession = session;
    final maxPanelHeight = (MediaQuery.sizeOf(context).height * .48).clamp(
      180.0,
      360.0,
    );

    return DecoratedBox(
      decoration: const BoxDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            key: const ValueKey("fuzz-overlay-panel"),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: .84),
            ),
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: .72),
                  child: Material(
                    type: MaterialType.transparency,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: maxPanelHeight),
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(16, topInset + 8, 16, 14),
                        child: DefaultTextStyle.merge(
                          style: const TextStyle(color: Colors.white),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    LucideIcons.bot,
                                    color: currentSession?.isRunning ?? false
                                        ? Colors.white
                                        : _statusColor(context, currentSession),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  const Expanded(
                                    child: Text(
                                      "Fuzz Tap",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      LucideIcons.x,
                                      color: Colors.white,
                                    ),
                                    tooltip: "Đóng Fuzz Tap",
                                    onPressed: onClose,
                                  ),
                                ],
                              ),
                              if (currentSession == null)
                                Text(
                                  "Chưa chạy lượt nào — chọn 1 kịch bản để bắt đầu.",
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: .72),
                                  ),
                                )
                              else if (currentSession.isRunning) ...[
                                Text(
                                  currentSession.configLabel,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${currentSession.isPaused ? 'Đã tạm dừng' : 'Đang chạy'} · "
                                  "${currentSession.tapCount} tap · "
                                  "${_formatDuration(currentSession.elapsed)}",
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: .72),
                                  ),
                                ),
                              ] else
                                _SessionReport(session: currentSession),
                              if (currentSession == null ||
                                  !currentSession.isRunning) ...[
                                const SizedBox(height: 12),
                                const Text(
                                  "Chọn kịch bản khác",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                _FuzzPresetButton(
                                  icon: const Icon(
                                    LucideIcons.list,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  label: "Chọn kịch bản",
                                  onPressed: onOpenCustomSheet,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            key: const ValueKey("fuzz-overlay-top-fade"),
            width: double.infinity,
            height: 96,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: .9),
                      Colors.black.withValues(alpha: .48),
                      Colors.transparent,
                    ],
                    stops: const [0, .28, 1],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FuzzPresetSheetOverlay extends StatelessWidget {
  const _FuzzPresetSheetOverlay({required this.runner, required this.onClose});

  final MobileDevToolFuzzTapRunner runner;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final maxSheetHeight = MediaQuery.sizeOf(context).height * .82;

    return Stack(
      key: const ValueKey("fuzz-preset-sheet-overlay"),
      fit: StackFit.expand,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onClose,
          child: const ColoredBox(color: Color(0x66000000)),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: double.infinity,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxSheetHeight),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: MobileDevToolFuzzPresetSheet(
                  runner: runner,
                  onDone: onClose,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FuzzPresetButton extends StatelessWidget {
  const _FuzzPresetButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(MobileDevToolTheme.radiusMd),
      side: BorderSide(color: Colors.white.withValues(alpha: .38)),
    );

    return Material(
      color: const Color(0xFF292929),
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        customBorder: shape,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 6)],
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FuzzTerminalDialog extends StatelessWidget {
  const _FuzzTerminalDialog({
    required this.session,
    required this.onDismiss,
    required this.onRerun,
  });

  final MobileDevToolFuzzRunSession session;
  final VoidCallback onDismiss;
  final VoidCallback onRerun;

  @override
  Widget build(BuildContext context) {
    final isSuccess =
        session.status == MobileDevToolFuzzRunStatus.stoppedTimeLimit &&
        session.errorCount == 0;

    return Stack(
      key: const ValueKey("fuzz-terminal-dialog"),
      fit: StackFit.expand,
      children: [
        const ModalBarrier(dismissible: false, color: Color(0x99000000)),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Dialog(
                insetPadding: EdgeInsets.zero,
                backgroundColor: MobileDevToolTheme.surface,
                surfaceTintColor: Colors.transparent,
                elevation: 12,
                shadowColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isSuccess
                                ? "Fuzz hoàn tất"
                                : "Fuzz phát hiện vấn đề",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${session.stopReasonLabel}.\n"
                            "${session.tapCount} tap · ${session.errorCount} lỗi runtime.",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: MobileDevToolTheme.textMuted,
                                  height: 1.4,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Divider(
                        height: 1,
                        thickness: .5,
                        color: Color(0xFFD9D9D9),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: onDismiss,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFF1F1F3),
                                foregroundColor: Colors.black,
                                minimumSize: const Size.fromHeight(44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: const Text("Đóng"),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton(
                              onPressed: onRerun,
                              style: FilledButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimary,
                                minimumSize: const Size.fromHeight(44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text("Chạy lại"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FuzzRunControls extends StatelessWidget {
  const _FuzzRunControls({required this.runner, required this.session});

  final MobileDevToolFuzzTapRunner runner;
  final MobileDevToolFuzzRunSession session;

  @override
  Widget build(BuildContext context) {
    final canSeek = runner.hasTimeLimit;
    final isPaused = session.isPaused;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        key: const ValueKey("fuzz-run-controls"),
        mainAxisSize: MainAxisSize.min,
        children: [
          _FuzzControlButton(
            size: 52,
            tooltip: "Tua lại 10 giây",
            icon: const Icon(Icons.replay_10),
            onPressed: canSeek
                ? () => runner.skip(const Duration(seconds: -10))
                : null,
          ),
          const SizedBox(width: 14),
          _FuzzControlButton(
            size: 68,
            tooltip: isPaused ? "Tiếp tục" : "Tạm dừng",
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause, size: 44),
            onPressed: isPaused ? runner.resume : runner.pause,
          ),
          const SizedBox(width: 14),
          _FuzzControlButton(
            size: 52,
            tooltip: "Tua nhanh 10 giây",
            icon: const Icon(Icons.forward_10),
            onPressed: canSeek
                ? () => runner.skip(const Duration(seconds: 10))
                : null,
          ),
        ],
      ),
    );
  }
}

class _FuzzControlButton extends StatelessWidget {
  const _FuzzControlButton({
    required this.size,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final double size;
  final String tooltip;
  final Widget icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tightFor(width: size, height: size),
        style: IconButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.black.withValues(alpha: .58),
          shape: const CircleBorder(),
        ),
        icon: IconTheme.merge(
          data: IconThemeData(size: size == 68 ? 34 : 26),
          child: icon,
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class _FuzzLogStream extends StatefulWidget {
  const _FuzzLogStream({required this.session, required this.bottomSafeArea});

  final MobileDevToolFuzzRunSession session;
  final double bottomSafeArea;

  @override
  State<_FuzzLogStream> createState() => _FuzzLogStreamState();
}

class _FuzzLogStreamState extends State<_FuzzLogStream> {
  GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<MobileDevToolFuzzRunStep> _steps = const [];
  int? _sessionId;

  @override
  void initState() {
    super.initState();
    _resetSteps(widget.session);
  }

  @override
  void didUpdateWidget(covariant _FuzzLogStream oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session.id != widget.session.id) {
      setState(() {
        _listKey = GlobalKey<AnimatedListState>();
        _resetSteps(widget.session);
      });
      return;
    }
    _syncSteps(widget.session);
  }

  void _resetSteps(MobileDevToolFuzzRunSession session) {
    _sessionId = session.id;
    _steps = session.steps.toList();
  }

  void _syncSteps(MobileDevToolFuzzRunSession session) {
    if (_sessionId != session.id) return;
    final next = session.steps.toList();
    final existingKeys = _steps.map(_stepKey).toSet();
    final additions = next
        .takeWhile((step) => !existingKeys.contains(_stepKey(step)))
        .toList();
    for (final step in additions.reversed) {
      _steps.insert(0, step);
      _listKey.currentState?.insertItem(
        0,
        duration: const Duration(milliseconds: 220),
      );
    }
    while (_steps.length > next.length) {
      final removeIndex = _steps.length - 1;
      final removed = _steps.removeLast();
      _listKey.currentState?.removeItem(
        removeIndex,
        (context, animation) => _buildItem(removed, removeIndex, animation),
        duration: const Duration(milliseconds: 120),
      );
    }
  }

  String _stepKey(MobileDevToolFuzzRunStep step) =>
      "${step.timestamp.microsecondsSinceEpoch}-${step.message}";

  Widget _buildItem(
    MobileDevToolFuzzRunStep step,
    int index,
    Animation<double> animation,
  ) => FadeTransition(
    opacity: animation,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, .18),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: _FuzzLogMessage(
        step: step,
        opacity: (1 - index * .12).clamp(.42, 1.0).toDouble(),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey("fuzz-log-stream"),
      height: 244 + widget.bottomSafeArea,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: .82),
                    Colors.black.withValues(alpha: .92),
                  ],
                  stops: const [0, .24, 1],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              42,
              20,
              widget.bottomSafeArea + 12,
            ),
            child: AnimatedList(
              key: _listKey,
              reverse: true,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              initialItemCount: _steps.length,
              itemBuilder: (context, index, animation) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildItem(_steps[index], index, animation),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FuzzLogMessage extends StatelessWidget {
  const _FuzzLogMessage({required this.step, required this.opacity});

  final MobileDevToolFuzzRunStep step;
  final double opacity;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: opacity,
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: "${_formatTime(step.timestamp)}  ",
            style: const TextStyle(color: Color(0xFFBDBDBD)),
          ),
          TextSpan(text: step.message),
        ],
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        height: 1.3,
        decoration: TextDecoration.none,
        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
      ),
    ),
  );
}

class _SessionReport extends StatelessWidget {
  const _SessionReport({required this.session});

  final MobileDevToolFuzzRunSession session;

  @override
  Widget build(BuildContext context) {
    final hasError =
        session.errorCount > 0 ||
        session.status == MobileDevToolFuzzRunStatus.stoppedNetworkError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          session.configLabel,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(
          session.stopReasonLabel,
          style: TextStyle(
            color: hasError ? const Color(0xFFFF8A80) : Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "${session.tapCount} tap · ${_formatDuration(session.elapsed)}"
          "${session.errorCount > 0 ? ' · ${session.errorCount} lỗi runtime' : ''}",
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}

String _formatTime(DateTime timestamp) =>
    "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}";

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return minutes > 0 ? "${minutes}p${seconds}s" : "${seconds}s";
}
