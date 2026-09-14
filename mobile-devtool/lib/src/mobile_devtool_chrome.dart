import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

import "mobile_devtool_annotation_overlay.dart";
import "mobile_devtool_annotation_tool.dart";
import "mobile_devtool_bubble.dart";
import "mobile_devtool_configuration.dart";
import "mobile_devtool_controller.dart";
import "mobile_devtool_exclude_from_fuzz_tap.dart";
import "mobile_devtool_fuzz_run_log.dart";
import "mobile_devtool_fuzz_tap_overlay.dart";
import "mobile_devtool_fuzz_tap_overlay_state.dart";
import "mobile_devtool_fuzz_tap_runner.dart";
import "mobile_devtool_root_menu.dart";
import "mobile_devtool_theme.dart";
import "mobile_devtool_ui_state.dart";

/// The dev tool's chrome (launcher bubble, root menu, Screen-Draw/Fuzz-Tap
/// full-screen overlays) with no `child` slot of its own — meant to be
/// inserted directly into a `Navigator`'s `Overlay` via [attach] rather than
/// wrapped around the host's widget tree. `MobileDevToolOverlay` is the
/// widget-tree-wrapping alternative that composes this same chrome.
class MobileDevToolChrome extends StatefulWidget {
  const MobileDevToolChrome({
    required this.controller,
    this.enabled = true,
    this.configuration = const MobileDevToolConfiguration(),
    this.navigatorKey,
    this.showLauncher = true,
    this.currentRouteKey,
    this.scrollDelta,
    super.key,
  });

  final MobileDevToolController controller;
  final bool enabled;
  final MobileDevToolConfiguration configuration;

  /// Used to resolve a navigator context for the root menu when this widget's
  /// own `context` (an `Overlay` entry, when mounted via [attach]) is not
  /// under the navigator the host wants the sheet to attach to.
  final GlobalKey<NavigatorState>? navigatorKey;

  /// Set to `false` to mount the overlays (annotation/fuzz-tap) without the
  /// launcher bubble — the host then opens the root menu itself via a
  /// `hostActions` entry or its own UI.
  final bool showLauncher;

  /// Fed by the host's navigator observer so Screen Draw annotations and
  /// `restrictToCurrentRoute` Fuzz Tap sessions can scope themselves to the
  /// page actually on screen. Omit it and both features simply stop scoping
  /// by route.
  final ValueListenable<String>? currentRouteKey;

  /// Fed by the host with each incremental scroll delta of the page
  /// underneath — lets the Screen Draw canvas shift its drawings along with
  /// scrolling content while it's open. Omit it and annotations stay fixed
  /// to the screen instead of the content.
  final ValueListenable<Offset>? scrollDelta;

  /// Inserts [builder]'s widget (typically a [MobileDevToolChrome], or a host
  /// wrapper that rebuilds one from live state) into [navigatorKey]'s root
  /// `Navigator` `Overlay` — a "true overlay" mount that never wraps the
  /// host's widget tree in a `Stack`. Waits for the first frame so
  /// `navigatorKey.currentState` is attached before inserting. The host owns
  /// the returned `OverlayEntry`'s lifecycle and must call `.remove()` when
  /// done (e.g. from `State.dispose()`) — this method does not manage it.
  static OverlayEntry attach({
    required GlobalKey<NavigatorState> navigatorKey,
    required WidgetBuilder builder,
  }) {
    final entry = OverlayEntry(
      builder: (context) => Positioned.fill(child: Builder(builder: builder)),
    );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => navigatorKey.currentState?.overlay?.insert(entry),
    );
    return entry;
  }

  @override
  State<MobileDevToolChrome> createState() => _MobileDevToolChromeState();
}

class _MobileDevToolChromeState extends State<MobileDevToolChrome> {
  late final _bubblePosition = MobileDevToolBubblePosition(
    const Offset(20, 100),
  );
  late final _bubbleIdle = MobileDevToolBubbleIdle();
  late final _annotationTool = MobileDevToolAnnotationTool(
    accentColor: widget.configuration.accentColor,
  );
  late final _fuzzRunLog = MobileDevToolFuzzRunLog();
  late final _fuzzTapRunner = MobileDevToolFuzzTapRunner(
    log: _fuzzRunLog,
    networkController: widget.controller,
    currentRouteKey:
        widget.currentRouteKey == null
            ? null
            : () => widget.currentRouteKey!.value,
  );
  final _fuzzTapOverlayActive = MobileDevToolFuzzTapOverlayActive();
  bool _menuOpen = false;

  @override
  void initState() {
    super.initState();
    widget.currentRouteKey?.addListener(_onRouteKeyChanged);
    widget.scrollDelta?.addListener(_onScrollDeltaChanged);
  }

  @override
  void didUpdateWidget(covariant MobileDevToolChrome oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRouteKey != widget.currentRouteKey) {
      oldWidget.currentRouteKey?.removeListener(_onRouteKeyChanged);
      widget.currentRouteKey?.addListener(_onRouteKeyChanged);
    }
    if (oldWidget.scrollDelta != widget.scrollDelta) {
      oldWidget.scrollDelta?.removeListener(_onScrollDeltaChanged);
      widget.scrollDelta?.addListener(_onScrollDeltaChanged);
    }
  }

  /// Both listeners below run from their own `ValueListenable`'s
  /// notification, never from this widget's `build()` — mutating
  /// `_annotationTool` synchronously during build would call
  /// `notifyListeners()` while the `AnimatedBuilder` that watches it is still
  /// building, triggering "setState() called during build".
  void _onRouteKeyChanged() =>
      _annotationTool.updateRoute(widget.currentRouteKey!.value);

  /// Only forwards while Screen Draw is actually open — mirrors the gating
  /// `MobileDevToolOverlay` used to do inline from its own `build()`.
  void _onScrollDeltaChanged() {
    if (!_annotationTool.overlayActive) return;
    _annotationTool.addScrollDelta(widget.scrollDelta!.value);
  }

  @override
  void dispose() {
    widget.currentRouteKey?.removeListener(_onRouteKeyChanged);
    widget.scrollDelta?.removeListener(_onScrollDeltaChanged);
    _bubblePosition.dispose();
    _bubbleIdle.dispose();
    _annotationTool.dispose();
    _fuzzTapRunner.stop();
    _fuzzRunLog.dispose();
    _fuzzTapOverlayActive.dispose();
    super.dispose();
  }

  Future<void> _openMenu() async {
    final navigatorContext = widget.navigatorKey?.currentContext ?? context;
    setState(() => _menuOpen = true);
    try {
      await MobileDevToolRootMenu.show(
        navigatorContext,
        controller: widget.controller,
        configuration: widget.configuration,
        fuzzRunLog: _fuzzRunLog,
        onOpenScreenDraw: _annotationTool.showOverlay,
        onOpenFuzzTap: _openFuzzTap,
      );
    } finally {
      if (mounted) setState(() => _menuOpen = false);
    }
  }

  void _openFuzzTap() {
    // Re-opening the tool starts a fresh run screen while preserving older
    // completed sessions for the separate Fuzz Tap Log panel.
    if (_fuzzTapRunner.isRunning) _fuzzTapRunner.stop();
    _fuzzRunLog.resetCurrentSession();
    _fuzzTapOverlayActive.show();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return const SizedBox.shrink();

    return ExcludeFromFuzzTap(
      child: Theme(
        data: MobileDevToolTheme.data(
          context,
          accentColor: widget.configuration.accentColor,
        ),
        child: AnimatedBuilder(
          animation: Listenable.merge([_annotationTool, _fuzzTapOverlayActive]),
          builder: (context, _) {
            final isAnnotationOpen = _annotationTool.overlayActive;
            final isFuzzTapOpen = _fuzzTapOverlayActive.value;

            return Stack(
              fit: StackFit.expand,
              children: [
                if (widget.showLauncher &&
                    !_menuOpen &&
                    !isAnnotationOpen &&
                    !isFuzzTapOpen)
                  MobileDevToolBubble(
                    controller: widget.controller,
                    position: _bubblePosition,
                    idle: _bubbleIdle,
                    accentColor: widget.configuration.accentColor,
                    onTap: () => unawaited(_openMenu()),
                  ),
                if (isFuzzTapOpen)
                  MobileDevToolFuzzTapOverlay(
                    runner: _fuzzTapRunner,
                    log: _fuzzRunLog,
                    onClose: _fuzzTapOverlayActive.hide,
                  ),
                // Keep Screen Draw last so its canvas and toolbar stay above
                // the Fuzz Tap scrim/panel when both tools are open.
                if (isAnnotationOpen)
                  MobileDevToolAnnotationOverlay(tool: _annotationTool),
              ],
            );
          },
        ),
      ),
    );
  }
}
