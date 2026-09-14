import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/loading/ui_kit_loading_controller.dart";

typedef UiKitLoadingStepBuilder =
    Widget Function(BuildContext context, UiKitLoadingStep step);

/// Overlay headless điều khiển bởi [UiKitLoadingController] — hiển thị
/// [child] bình thường, phủ [builder] lên trên khi `controller.visible`.
/// Nội dung overlay (spinner/success/error UI) hoàn toàn do app-layer quyết
/// định qua [builder]; package chỉ điều phối show/hide + animation chuyển
/// step.
class UiKitLoadingOverlay extends StatefulWidget {
  const UiKitLoadingOverlay({
    required this.controller,
    required this.child,
    required this.builder,
    this.barrierDismissible = false,
    this.barrierColor,
    this.animationDuration = const Duration(milliseconds: 200),
    super.key,
  });

  final UiKitLoadingController controller;
  final Widget child;
  final UiKitLoadingStepBuilder builder;
  final bool barrierDismissible;
  final Color? barrierColor;
  final Duration animationDuration;

  @override
  State<UiKitLoadingOverlay> createState() => _UiKitLoadingOverlayState();
}

class _UiKitLoadingOverlayState extends State<UiKitLoadingOverlay> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleChange);
  }

  void _handleChange() => setState(() {});

  @override
  void didUpdateWidget(covariant UiKitLoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleChange);
      widget.controller.addListener(_handleChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = widget.controller.visible;

    return PopScope(
      canPop: !(visible && !widget.barrierDismissible),
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          IgnorePointer(
            ignoring: !visible,
            child: AnimatedOpacity(
              opacity: visible ? 1 : 0,
              duration: widget.animationDuration,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ModalBarrier(
                    color: widget.barrierColor,
                    dismissible: widget.barrierDismissible,
                    onDismiss: widget.barrierDismissible
                        ? widget.controller.hide
                        : null,
                  ),
                  AnimatedSwitcher(
                    duration: widget.animationDuration,
                    child: KeyedSubtree(
                      key: ValueKey(widget.controller.step),
                      child: widget.builder(context, widget.controller.step),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
