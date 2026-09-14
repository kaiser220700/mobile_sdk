import "package:flutter/foundation.dart";

/// Điều khiển show/hide 1 [UiKitAnchoredOverlay] từ bên ngoài — thay
/// `FPopoverController`. Không cần `TickerProvider`: animation entrance/exit
/// được [UiKitAnchoredOverlay] tự quản nội bộ.
class UiKitOverlayController extends ChangeNotifier {
  bool _shown = false;

  bool get shown => _shown;

  void show() {
    if (_shown) return;
    _shown = true;
    notifyListeners();
  }

  void hide() {
    if (!_shown) return;
    _shown = false;
    notifyListeners();
  }

  void toggle() => _shown ? hide() : show();

  @override
  void dispose() {
    _shown = false;
    super.dispose();
  }
}
