import "dart:async";

import "package:flutter/widgets.dart";

import "package:mobile_ui_kit/src/overlay/ui_kit_anchored_overlay.dart";
import "package:mobile_ui_kit/src/overlay/ui_kit_overlay_controller.dart";
import "package:mobile_ui_kit/src/tooltip/ui_kit_tooltip_coordinator.dart";

/// Tooltip headless trigger bằng LONG-PRESS — thay `FTooltip`. Tự quản
/// [UiKitOverlayController] nội bộ (caller không cần tự tạo/dispose) và tự
/// đóng theo [duration] (0 = không tự tắt). Phối hợp với
/// [UiKitTooltipCoordinator] để đảm bảo chỉ 1 tooltip hiện tại 1 thời điểm
/// toàn app.
class UiKitTooltip extends StatefulWidget {
  const UiKitTooltip({
    required this.tipBuilder,
    required this.child,
    this.childAnchor = Alignment.topCenter,
    this.tipAnchor = Alignment.bottomCenter,
    this.duration = const Duration(seconds: 3),
    this.decoration,
    this.padding,
    this.constraints,
    super.key,
  });

  final WidgetBuilder tipBuilder;
  final Widget child;
  final Alignment childAnchor;
  final Alignment tipAnchor;
  final Duration duration;
  final BoxDecoration? decoration;
  final EdgeInsetsGeometry? padding;
  final BoxConstraints? constraints;

  @override
  State<UiKitTooltip> createState() => _UiKitTooltipState();
}

class _UiKitTooltipState extends State<UiKitTooltip> {
  final _controller = UiKitOverlayController();
  Timer? _timer;

  void _show() {
    UiKitTooltipCoordinator.instance.requestShow(_controller);
    _controller.show();
    _timer?.cancel();
    if (widget.duration > Duration.zero) {
      _timer = Timer(widget.duration, _hide);
    }
  }

  void _hide() {
    _timer?.cancel();
    _controller.hide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    UiKitTooltipCoordinator.instance.notifyHidden(_controller);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UiKitAnchoredOverlay(
      controller: _controller,
      childAnchor: widget.childAnchor,
      overlayAnchor: widget.tipAnchor,
      barrierDismissible: false,
      overlayBuilder: (context) => Container(
        decoration: widget.decoration,
        padding: widget.padding,
        constraints: widget.constraints,
        child: widget.tipBuilder(context),
      ),
      child: GestureDetector(onLongPress: _show, child: widget.child),
    );
  }
}
