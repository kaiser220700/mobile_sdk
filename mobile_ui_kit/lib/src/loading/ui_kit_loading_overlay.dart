import "package:material_ui/material_ui.dart";
import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

import "package:mobile_ui_kit/src/loading/ui_kit_loading_controller.dart";

typedef UiKitLoadingStepBuilder = Widget Function(
  BuildContext context,
  UiKitLoadingStep step,
);

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
    this.animationDuration,
    super.key,
  });

  final UiKitLoadingController controller;
  final Widget child;
  final UiKitLoadingStepBuilder builder;
  final bool barrierDismissible;
  final Color? barrierColor;
  final Duration? animationDuration;

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
    final theme = UiKitTheme.of(context);
    final duration = theme.motion.resolve(
      context,
      widget.animationDuration ?? theme.motion.base,
    );

    return PopScope(
      canPop: !(visible && !widget.barrierDismissible),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ExcludeFocus(
            excluding: visible,
            child: ExcludeSemantics(
              excluding: visible,
              child: AbsorbPointer(absorbing: visible, child: widget.child),
            ),
          ),
          ExcludeSemantics(
            excluding: !visible,
            child: IgnorePointer(
              ignoring: !visible,
              child: AnimatedOpacity(
                opacity: visible ? 1 : 0,
                duration: duration,
                curve: theme.motion.curve,
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
                      duration: duration,
                      switchInCurve: theme.motion.curve,
                      switchOutCurve: theme.motion.curve,
                      child: KeyedSubtree(
                        key: ValueKey(widget.controller.step),
                        child: widget.builder(context, widget.controller.step),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
