import "dart:async";

import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/pressable/ui_kit_pressable_state.dart";

typedef UiKitPressableBuilder =
    Widget Function(
      BuildContext context,
      Set<UiKitPressableState> states,
      Widget? child,
    );

/// Vùng chạm headless quản lý state pressed/hovered/disabled/selected —
/// thay thế `FTappable`. Caller quyết định toàn bộ style qua [builder].
///
/// [hitSlop] mở rộng vùng chạm bằng layout space thật (giống cách
/// `IconButton` mở rộng `minSize` quanh icon nhỏ hơn kích thước hiển thị),
/// thay cho việc caller phải tự bọc `SizedBox` touch-target thủ công.
class UiKitPressable extends StatefulWidget {
  const UiKitPressable({
    required this.builder,
    this.onPress,
    this.onLongPress,
    this.child,
    this.selected = false,
    this.checked,
    this.toggled,
    this.hitSlop = EdgeInsets.zero,
    this.semanticsLabel,
    this.excludeSemantics = false,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.mouseCursor,
    this.autofocus = false,
    this.focusNode,
    this.tapThrottleDuration = const Duration(milliseconds: 300),
    super.key,
  }) : assert(
         tapThrottleDuration >= Duration.zero,
         "tapThrottleDuration must not be negative.",
       );

  final UiKitPressableBuilder builder;
  final VoidCallback? onPress;
  final VoidCallback? onLongPress;
  final Widget? child;
  final bool selected;
  final bool? checked;
  final bool? toggled;
  final EdgeInsets hitSlop;
  final String? semanticsLabel;
  final bool excludeSemantics;
  final HitTestBehavior hitTestBehavior;
  final MouseCursor? mouseCursor;
  final bool autofocus;
  final FocusNode? focusNode;

  /// Minimum interval between accepted taps.
  ///
  /// The first tap is delivered immediately. Further taps during this
  /// interval are ignored. Set to [Duration.zero] for controls that
  /// intentionally support rapid repeated taps.
  final Duration tapThrottleDuration;

  bool get _disabled => onPress == null && onLongPress == null;

  @override
  State<UiKitPressable> createState() => _UiKitPressableState();
}

class _UiKitPressableState extends State<UiKitPressable> {
  bool _pressed = false;
  bool _hovered = false;
  bool _tapThrottled = false;
  Timer? _tapThrottleTimer;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  void _setHovered(bool value) {
    if (_hovered != value) setState(() => _hovered = value);
  }

  void _handleTap() {
    final onPress = widget.onPress;
    if (onPress == null || _tapThrottled) return;

    final duration = widget.tapThrottleDuration;
    if (duration > Duration.zero) {
      _tapThrottled = true;
      _tapThrottleTimer?.cancel();
      _tapThrottleTimer = Timer(duration, () {
        _tapThrottled = false;
        _tapThrottleTimer = null;
      });
    }
    onPress();
  }

  @override
  void dispose() {
    _tapThrottleTimer?.cancel();
    super.dispose();
  }

  Set<UiKitPressableState> get _states => {
    if (_hovered) UiKitPressableState.hovered,
    if (_pressed) UiKitPressableState.pressed,
    if (widget._disabled) UiKitPressableState.disabled,
    if (widget.selected) UiKitPressableState.selected,
  };

  @override
  Widget build(BuildContext context) {
    final disabled = widget._disabled;

    return Semantics(
      button: true,
      enabled: !disabled,
      selected: widget.selected,
      checked: widget.checked,
      toggled: widget.toggled,
      label: widget.semanticsLabel,
      excludeSemantics: widget.excludeSemantics,
      child: MouseRegion(
        cursor:
            widget.mouseCursor ??
            (disabled ? SystemMouseCursors.basic : SystemMouseCursors.click),
        onEnter: disabled ? null : (_) => _setHovered(true),
        onExit: disabled ? null : (_) => _setHovered(false),
        child: GestureDetector(
          behavior: widget.hitTestBehavior,
          onTapDown: disabled ? null : (_) => _setPressed(true),
          onTapCancel: disabled ? null : () => _setPressed(false),
          onTapUp: disabled ? null : (_) => _setPressed(false),
          onTap: disabled ? null : _handleTap,
          onLongPress: disabled ? null : widget.onLongPress,
          child: Padding(
            padding: widget.hitSlop,
            child: widget.builder(context, _states, widget.child),
          ),
        ),
      ),
    );
  }
}
