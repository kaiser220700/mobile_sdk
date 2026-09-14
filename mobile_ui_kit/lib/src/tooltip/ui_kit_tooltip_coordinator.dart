import "package:mobile_ui_kit/src/overlay/ui_kit_overlay_controller.dart";

/// Singleton điều phối tooltip toàn app — đảm bảo chỉ 1 [UiKitTooltip] hiện
/// tại 1 thời điểm, thay `FTooltipGroup` (không cần mount widget ở root).
class UiKitTooltipCoordinator {
  UiKitTooltipCoordinator._();

  static final UiKitTooltipCoordinator instance = UiKitTooltipCoordinator._();

  UiKitOverlayController? _active;

  /// Gọi TRƯỚC khi show 1 tooltip mới — tự đóng tooltip đang mở (nếu khác)
  /// rồi đăng ký [controller] làm active hiện tại.
  void requestShow(UiKitOverlayController controller) {
    if (_active != null && _active != controller) {
      _active!.hide();
    }
    _active = controller;
  }

  /// Gọi khi 1 tooltip đã đóng/dispose — bỏ đăng ký nếu nó đang là active.
  void notifyHidden(UiKitOverlayController controller) {
    if (_active == controller) {
      _active = null;
    }
  }
}
