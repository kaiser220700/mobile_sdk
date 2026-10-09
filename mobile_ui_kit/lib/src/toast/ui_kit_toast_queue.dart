import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/toast/ui_kit_toast_type.dart";

/// Visual overrides for a structured [UiKitToastContent].
///
/// Omitted properties inherit the semantic defaults from [UiKitTheme], so a
/// host can brand all toasts through [UiKitThemeData] and override only an
/// exceptional notification here.
class UiKitToastAppearance {
  const UiKitToastAppearance({
    this.backgroundColor,
    this.titleColor,
    this.messageColor,
    this.leadingIconColor,
    this.trailingIndicatorColor,
    this.leadingIcon,
    this.trailingIndicator,
  });

  final Color? backgroundColor;
  final Color? titleColor;
  final Color? messageColor;
  final Color? leadingIconColor;
  final Color? trailingIndicatorColor;
  final IconData? leadingIcon;
  final IconData? trailingIndicator;
}

/// Structured notification content rendered by the SDK's standard toast
/// surface. Use this when the host only needs to provide notification data and
/// actions, rather than its own gesture, safe-area and motion implementation.
class UiKitToastContent {
  const UiKitToastContent({
    required this.title,
    required this.message,
    this.semanticLabel,
    this.onTap,
    this.appearance,
  });

  final String title;
  final String message;

  /// Accessible label for the complete notification. Defaults to title and
  /// message when omitted.
  final String? semanticLabel;

  /// Runs only after the user taps the toast. Tapping also dismisses it.
  final VoidCallback? onTap;

  /// Per-notification visual overrides over [UiKitTheme].
  final UiKitToastAppearance? appearance;
}

/// One toast display request.
///
/// The original [UiKitToastRequest] constructor keeps the app-owned visual
/// [builder] path intact. Use [UiKitToastRequest.content] for the standard
/// SDK-owned notification surface.
class UiKitToastRequest {
  const UiKitToastRequest({
    required this.type,
    required this.builder,
    this.duration = const Duration(seconds: 4),
    this.onDismiss,
  }) : content = null;

  const UiKitToastRequest.content({
    required this.type,
    required this.content,
    this.duration = const Duration(seconds: 4),
    this.onDismiss,
  }) : builder = _contentBuilder;

  static Widget _contentBuilder(BuildContext context) =>
      const SizedBox.shrink();

  final UiKitToastType type;

  /// App-owned visual retained for backwards compatibility. For requests made
  /// with [UiKitToastRequest.content], the overlay renders [content] instead.
  final WidgetBuilder builder;

  /// Structured content rendered by the SDK when non-null.
  final UiKitToastContent? content;

  /// `Duration.zero` = sticky, chỉ đóng qua [UiKitToastQueue.dismissCurrent].
  final Duration duration;

  /// Called once when this request leaves the queue, including timeout, tap,
  /// swipe and an explicit [UiKitToastQueue.dismissCurrent].
  final VoidCallback? onDismiss;
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
    final dismissed = _current;
    if (dismissed == null) return;
    if (_pending.isNotEmpty) {
      _current = _pending.removeAt(0);
    } else {
      _current = null;
    }
    dismissed.onDismiss?.call();
    notifyListeners();
  }

  void dismissAll() {
    final dismissed = [_current, ..._pending].nonNulls;
    _pending.clear();
    _current = null;
    for (final request in dismissed) {
      request.onDismiss?.call();
    }
    notifyListeners();
  }
}
