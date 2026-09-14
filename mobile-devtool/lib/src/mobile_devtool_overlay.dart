import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

import "mobile_devtool_chrome.dart";
import "mobile_devtool_configuration.dart";
import "mobile_devtool_controller.dart";
import "mobile_devtool_ui_state.dart";

/// Widget-tree-wrapping alternative to [MobileDevToolChrome.attach] — wraps
/// [child] in a `Stack` with the chrome painted above it. Prefer `attach` for
/// a true `Overlay` mount that never touches the host's widget tree; this
/// widget exists for hosts that already compose overlays this way (e.g.
/// inside a `MaterialApp.builder`) and don't want to manage an `OverlayEntry`
/// themselves.
class MobileDevToolOverlay extends StatefulWidget {
  const MobileDevToolOverlay({
    required this.child,
    required this.controller,
    this.enabled = true,
    this.configuration = const MobileDevToolConfiguration(),
    this.navigatorKey,
    this.showLauncher = true,
    this.currentRouteKey,
    super.key,
  });

  final Widget child;
  final MobileDevToolController controller;
  final bool enabled;
  final MobileDevToolConfiguration configuration;
  final GlobalKey<NavigatorState>? navigatorKey;
  final bool showLauncher;
  final ValueListenable<String>? currentRouteKey;

  @override
  State<MobileDevToolOverlay> createState() => _MobileDevToolOverlayState();
}

class _MobileDevToolOverlayState extends State<MobileDevToolOverlay> {
  final _scrollDelta = MobileDevToolScrollDelta();

  @override
  void dispose() {
    _scrollDelta.dispose();
    super.dispose();
  }

  /// Gating on whether Screen Draw is actually open happens inside
  /// [MobileDevToolChrome] itself (it owns the annotation-tool state this
  /// widget no longer has direct access to) — this just converts every
  /// scroll tick into a delta and lets the chrome decide whether to use it.
  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification &&
        notification.scrollDelta != null) {
      final axisDirection = notification.metrics.axisDirection;
      final delta =
          axisDirection == AxisDirection.left ||
              axisDirection == AxisDirection.right
          ? Offset(notification.scrollDelta!, 0)
          : Offset(0, notification.scrollDelta!);
      _scrollDelta.emit(delta);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return Stack(
      fit: StackFit.expand,
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: widget.child,
        ),
        MobileDevToolChrome(
          controller: widget.controller,
          configuration: widget.configuration,
          navigatorKey: widget.navigatorKey,
          showLauncher: widget.showLauncher,
          currentRouteKey: widget.currentRouteKey,
          scrollDelta: _scrollDelta,
        ),
      ],
    );
  }
}
