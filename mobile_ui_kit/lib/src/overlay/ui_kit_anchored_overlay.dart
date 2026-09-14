import "package:flutter/widgets.dart";

import "package:mobile_ui_kit/src/overlay/ui_kit_overlay_controller.dart";

/// Overlay neo theo 1 widget target — thay `FPopover`. Dựa trên
/// `OverlayPortal` + `CompositedTransformTarget`/`Follower` (built-in
/// Flutter). Tự đóng gói post-frame callback khi cần đồng bộ trạng thái ban
/// đầu (tránh assertion "should not be called during build" khi controller
/// đã `shown = true` lúc widget mount) — caller không cần tự làm việc này.
class UiKitAnchoredOverlay extends StatefulWidget {
  const UiKitAnchoredOverlay({
    required this.controller,
    required this.overlayBuilder,
    required this.child,
    this.childAnchor = Alignment.bottomLeft,
    this.overlayAnchor = Alignment.topLeft,
    this.offset = Offset.zero,
    this.barrierDismissible = true,
    this.excludeChildFromBarrier = true,
    this.barrierColor,
    this.onDismiss,
    this.animationDuration = const Duration(milliseconds: 150),
    super.key,
  });

  final UiKitOverlayController controller;
  final WidgetBuilder overlayBuilder;
  final Widget child;
  final Alignment childAnchor;
  final Alignment overlayAnchor;
  final Offset offset;
  final bool barrierDismissible;
  final bool excludeChildFromBarrier;
  final Color? barrierColor;
  final VoidCallback? onDismiss;
  final Duration animationDuration;

  @override
  State<UiKitAnchoredOverlay> createState() => _UiKitAnchoredOverlayState();
}

class _UiKitAnchoredOverlayState extends State<UiKitAnchoredOverlay> {
  final _overlayPortalController = OverlayPortalController();
  final _link = LayerLink();
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChange);
    if (widget.controller.shown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _open();
      });
    }
  }

  void _handleControllerChange() {
    if (widget.controller.shown) {
      _open();
    } else {
      _close();
    }
  }

  void _open() {
    if (_overlayPortalController.isShowing) return;
    _overlayPortalController.show();
    setState(() => _visible = true);
  }

  void _close() {
    if (!_overlayPortalController.isShowing) return;
    setState(() => _visible = false);
    Future.delayed(widget.animationDuration, () {
      if (mounted && !widget.controller.shown) {
        _overlayPortalController.hide();
      }
    });
  }

  void _handleDismiss() {
    widget.controller.hide();
    widget.onDismiss?.call();
  }

  @override
  void didUpdateWidget(covariant UiKitAnchoredOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChange);
      widget.controller.addListener(_handleControllerChange);
      _handleControllerChange();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _overlayPortalController,
        overlayChildBuilder: (context) => _AnchoredOverlayContent(
          link: _link,
          childAnchor: widget.childAnchor,
          overlayAnchor: widget.overlayAnchor,
          offset: widget.offset,
          barrierDismissible: widget.barrierDismissible,
          excludeChildFromBarrier: widget.excludeChildFromBarrier,
          barrierColor: widget.barrierColor,
          animationDuration: widget.animationDuration,
          visible: _visible,
          onDismiss: _handleDismiss,
          builder: widget.overlayBuilder,
        ),
        child: widget.child,
      ),
    );
  }
}

class _AnchoredOverlayContent extends StatelessWidget {
  const _AnchoredOverlayContent({
    required this.link,
    required this.childAnchor,
    required this.overlayAnchor,
    required this.offset,
    required this.barrierDismissible,
    required this.excludeChildFromBarrier,
    required this.barrierColor,
    required this.animationDuration,
    required this.visible,
    required this.onDismiss,
    required this.builder,
  });

  final LayerLink link;
  final Alignment childAnchor;
  final Alignment overlayAnchor;
  final Offset offset;
  final bool barrierDismissible;
  final bool excludeChildFromBarrier;
  final Color? barrierColor;
  final Duration animationDuration;
  final bool visible;
  final VoidCallback onDismiss;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (barrierColor != null || barrierDismissible)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: barrierDismissible ? onDismiss : null,
              child: AnimatedOpacity(
                opacity: visible ? 1 : 0,
                duration: animationDuration,
                child: ColoredBox(
                  color: barrierColor ?? const Color(0x00000000),
                ),
              ),
            ),
          ),
        CompositedTransformFollower(
          link: link,
          targetAnchor: childAnchor,
          followerAnchor: overlayAnchor,
          offset: offset,
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: animationDuration,
            curve: Curves.easeOut,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: visible ? 0.95 : 1, end: visible ? 1 : 0.95),
              duration: animationDuration,
              curve: Curves.easeOut,
              builder: (context, scale, child) => Transform.scale(
                scale: scale,
                alignment: overlayAnchor,
                child: child,
              ),
              child: Builder(builder: builder),
            ),
          ),
        ),
      ],
    );
  }
}
