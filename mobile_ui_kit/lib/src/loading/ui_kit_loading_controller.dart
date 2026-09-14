import "package:flutter/foundation.dart";

/// Bước hiển thị hiện tại của [UiKitLoadingOverlay].
enum UiKitLoadingStep { spinner, success, error }

/// Điều khiển show/hide + chuyển step của 1 [UiKitLoadingOverlay] từ bên
/// ngoài (ví dụ từ ViewModel) — không cần rebuild widget cha để đổi state,
/// cùng pattern với `UiKitOverlayController`.
class UiKitLoadingController extends ChangeNotifier {
  bool _visible = false;
  UiKitLoadingStep _step = UiKitLoadingStep.spinner;

  bool get visible => _visible;
  UiKitLoadingStep get step => _step;

  void showSpinner() {
    _visible = true;
    _step = UiKitLoadingStep.spinner;
    notifyListeners();
  }

  void showSuccess() {
    _visible = true;
    _step = UiKitLoadingStep.success;
    notifyListeners();
  }

  void showError() {
    _visible = true;
    _step = UiKitLoadingStep.error;
    notifyListeners();
  }

  void hide() {
    if (!_visible) return;
    _visible = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _visible = false;
    super.dispose();
  }
}
