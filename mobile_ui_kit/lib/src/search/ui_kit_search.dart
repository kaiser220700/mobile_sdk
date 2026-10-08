import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

class UiKitSearch extends StatefulWidget {
  const UiKitSearch({
    required this.value,
    required this.onChanged,
    this.placeholder = "Search...",
    this.onSubmitted,
    this.onClear,
    this.showCancel = false,
    this.cancelLabel = "Cancel",
    this.onCancel,
    this.disabled = false,
    this.autoFocus = false,
    this.semanticsLabel,
    this.height = 52,
    this.padding,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.borderRadius,
    this.shadow,
    this.searchIcon = Icons.search,
    this.searchIconSize = 20,
    this.searchIconColor,
    this.textStyle,
    this.hintStyle,
    this.animationDuration = const Duration(milliseconds: 150),
    this.cancelSpacing,
    super.key,
  }) : assert(height > 0 && borderWidth > 0),
       assert(
         !showCancel || onCancel != null,
         "showCancel=true needs onCancel.",
       );

  final String value;
  final ValueChanged<String> onChanged;
  final String placeholder;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool showCancel;
  final String cancelLabel;
  final VoidCallback? onCancel;
  final bool disabled;
  final bool autoFocus;
  final String? semanticsLabel;
  final double height;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double? borderRadius;
  final List<BoxShadow>? shadow;
  final IconData searchIcon;
  final double searchIconSize;
  final Color? searchIconColor;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final Duration animationDuration;
  final double? cancelSpacing;

  @override
  State<UiKitSearch> createState() => _UiKitSearchState();
}

class _UiKitSearchState extends State<UiKitSearch> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );
  late final FocusNode _focusNode = FocusNode();

  @override
  void didUpdateWidget(covariant UiKitSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.value) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onClear?.call();
    if (widget.onClear == null) widget.onChanged("");
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final field = AnimatedBuilder(
      animation: Listenable.merge([_focusNode, _controller]),
      builder: (context, _) => AnimatedContainer(
        duration: widget.animationDuration,
        constraints: BoxConstraints(minHeight: widget.height),
        padding:
            widget.padding ?? EdgeInsets.symmetric(horizontal: theme.spacingMd),
        decoration: BoxDecoration(
          color: widget.disabled
              ? widget.disabledBackgroundColor ?? theme.surfaceMuted
              : widget.backgroundColor ?? theme.surface,
          borderRadius: BorderRadius.circular(
            widget.borderRadius ?? theme.radiusFull,
          ),
          border: _focusNode.hasFocus && !widget.disabled
              ? Border.all(
                  color: widget.borderColor ?? theme.focusRing,
                  width: widget.borderWidth,
                )
              : null,
          boxShadow: widget.disabled
              ? null
              : widget.shadow ??
                    const [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
        ),
        child: Row(
          children: [
            Icon(
              widget.searchIcon,
              size: widget.searchIconSize,
              color: widget.searchIconColor ?? theme.textMuted,
            ),
            SizedBox(width: theme.spacingSm),
            Expanded(
              child: Semantics(
                textField: true,
                label: widget.semanticsLabel ?? "Search",
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: !widget.disabled,
                  autofocus: widget.autoFocus,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  textInputAction: TextInputAction.search,
                  style: (widget.textStyle ?? theme.body).copyWith(
                    color: theme.text,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: widget.placeholder,
                    hintStyle: (widget.hintStyle ?? theme.body).copyWith(
                      color: theme.textMuted,
                    ),
                  ),
                ),
              ),
            ),
            if (_controller.text.isNotEmpty && !widget.disabled)
              IconButton(
                onPressed: _clear,
                icon: const Icon(Icons.close, size: 16),
                color: theme.textMuted,
                tooltip: "Clear search",
              ),
          ],
        ),
      ),
    );
    if (!widget.showCancel) return field;
    return Row(
      children: [
        Expanded(child: field),
        SizedBox(width: widget.cancelSpacing ?? theme.spacingMd),
        TextButton(onPressed: widget.onCancel, child: Text(widget.cancelLabel)),
      ],
    );
  }
}
