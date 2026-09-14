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
    this.hitSlop = EdgeInsets.zero,
    this.semanticsLabel,
    this.excludeSemantics = false,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.mouseCursor,
    this.autofocus = false,
    this.focusNode,
    super.key,
  });

  final UiKitPressableBuilder builder;
  final VoidCallback? onPress;
  final VoidCallback? onLongPress;
  final Widget? child;
  final bool selected;
  final EdgeInsets hitSlop;
  final String? semanticsLabel;
  final bool excludeSemantics;
  final HitTestBehavior hitTestBehavior;
  final MouseCursor? mouseCursor;
  final bool autofocus;
  final FocusNode? focusNode;

  bool get _disabled => onPress == null && onLongPress == null;

  @override
  State<UiKitPressable> createState() => _UiKitPressableState();
}

class _UiKitPressableState extends State<UiKitPressable> {
  bool _pressed = false;
  bool _hovered = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  void _setHovered(bool value) {
    if (_hovered != value) setState(() => _hovered = value);
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
          onTap: disabled ? null : widget.onPress,
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
