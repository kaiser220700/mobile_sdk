import "package:flutter/widgets.dart";

import "package:mobile_ui_kit/src/toast/ui_kit_toast_type.dart";

/// 1 yêu cầu hiển thị toast — nội dung visual hoàn toàn do [builder] app-layer
/// quyết định, package chỉ điều phối thứ tự/thời lượng hiển thị.
class UiKitToastRequest {
  const UiKitToastRequest({
    required this.type,
    required this.builder,
    this.duration = const Duration(seconds: 4),
  });

  final UiKitToastType type;
  final WidgetBuilder builder;

  /// `Duration.zero` = sticky, chỉ đóng qua [UiKitToastQueue.dismissCurrent].
  final Duration duration;
}

/// Hàng đợi hiển thị toast tuần tự — tối đa 1 toast hiện tại 1 thời điểm.
/// Yêu cầu mới trong lúc đang hiển thị sẽ xếp hàng, hiện ra ngay khi toast
/// hiện tại kết thúc (timeout hoặc [dismissCurrent]).
class UiKitToastQueue extends ChangeNotifier {
  final List<UiKitToastRequest> _pending = [];
  UiKitToastRequest? _current;

  UiKitToastRequest? get current => _current;

  void enqueue(UiKitToastRequest request) {
    if (_current == null) {
      _current = request;
      notifyListeners();
      return;
    }
    _pending.add(request);
  }

  void dismissCurrent() {
    if (_current == null) return;
    if (_pending.isNotEmpty) {
      _current = _pending.removeAt(0);
    } else {
      _current = null;
    }
    notifyListeners();
  }

  void dismissAll() {
    _pending.clear();
    _current = null;
    notifyListeners();
  }
}
