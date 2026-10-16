import "package:flutter/foundation.dart";

/// Bước hiển thị hiện tại của [UiKitLoadingOverlay].
enum UiKitLoadingStep { spinner, success, error }

/// Điều khiển show/hide + chuyển step của 1 [UiKitLoadingOverlay] từ bên
/// ngoài (ví dụ từ ViewModel) — không cần rebuild widget cha để đổi state,
/// cùng pattern với `UiKitOverlayController`.
class UiKitLoadingController extends ChangeNotifier {
  bool _visible = false;
  bool _disposed = false;
  final Set<Object> _leases = {};

  /// Acquires spinner ownership. The returned release callback is idempotent.
  /// Manual success/error states are shown after all leases are released.
  VoidCallback acquire() {
    if (_disposed) throw StateError('LoadingController is disposed');
    final token = Object();
    _leases.add(token);
    notifyListeners();
    return () {
      if (_disposed || !_leases.remove(token)) return;
      notifyListeners();
    };
  }

  /// Keeps loading visible until the operation completes, including failure.
  Future<T> run<T>(Future<T> Function() operation) async {
    final release = acquire();
    try {
      return await operation();
    } finally {
      release();
    }
  }

  int get activeCount => _leases.length;
  UiKitLoadingStep _step = UiKitLoadingStep.spinner;

  bool get visible => _visible || _leases.isNotEmpty;
  UiKitLoadingStep get step =>
      _leases.isNotEmpty ? UiKitLoadingStep.spinner : _step;

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
    _disposed = true;
    _leases.clear();
    _visible = false;
    super.dispose();
  }
}
