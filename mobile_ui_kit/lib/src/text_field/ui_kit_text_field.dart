import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

enum UiKitTextFieldType { text, password, phone, textarea, select }

enum UiKitTextFieldVariant { normal, success, error }

/// Text input visual with app-overridable theme tokens.
class UiKitTextField extends StatefulWidget {
  const UiKitTextField({
    required this.controller,
    required this.label,
    this.type = UiKitTextFieldType.text,
    this.variant = UiKitTextFieldVariant.normal,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.iconLeft,
    this.iconRight,
    this.suffixText,
    this.onIconRightPressed,
    this.onChanged,
    this.onTap,
    this.selectOpen = false,
    this.focusNode,
    this.enabled = true,
    this.isRequired = false,
    this.maxLength,
    this.minLines = 3,
    this.maxLines = 8,
    this.dialCode = "+84",
    this.onDialCodePressed,
    this.obscureText = false,
    this.showPasswordLabel,
    this.hidePasswordLabel,
    this.autofillHints,
    this.textInputAction,
    this.keyboardType,
    this.inputFormatters,
    this.labelColor,
    super.key,
  }) : assert(
         type != UiKitTextFieldType.select || onTap != null,
         "Select fields need onTap.",
       ),
       assert(
         minLines > 0 && maxLines >= minLines,
         "maxLines must be >= minLines and both positive.",
       );

  final TextEditingController controller;
  final String label;
  final UiKitTextFieldType type;
  final UiKitTextFieldVariant variant;
  final String? placeholder;
  final String? helperText;
  final String? errorText;
  final IconData? iconLeft;
  final IconData? iconRight;
  final String? suffixText;
  final VoidCallback? onIconRightPressed;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool selectOpen;
  final FocusNode? focusNode;
  final bool enabled;
  final bool isRequired;
  final int? maxLength;
  final int minLines;
  final int maxLines;
  final String dialCode;
  final VoidCallback? onDialCodePressed;
  final bool obscureText;
  final String? showPasswordLabel;
  final String? hidePasswordLabel;
  final List<String>? autofillHints;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Color? labelColor;

  @override
  State<UiKitTextField> createState() => _UiKitTextFieldState();
}

class _UiKitTextFieldState extends State<UiKitTextField> {
  late bool _obscure =
      widget.obscureText || widget.type == UiKitTextFieldType.password;

  @override
  void didUpdateWidget(covariant UiKitTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText ||
        oldWidget.type != widget.type) {
      _obscure =
          widget.obscureText || widget.type == UiKitTextFieldType.password;
    }
  }

  bool get _password =>
      widget.type == UiKitTextFieldType.password || widget.obscureText;
  bool get _textarea => widget.type == UiKitTextFieldType.textarea;
  Color _borderColor(UiKitThemeData theme) =>
      widget.errorText != null || widget.variant == UiKitTextFieldVariant.error
      ? theme.error
      : widget.variant == UiKitTextFieldVariant.success
      ? theme.success
      : theme.border;

  OutlineInputBorder _border(
    UiKitThemeData theme,
    Color color, {
    double width = 1,
  }) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(theme.radiusMd),
    borderSide: BorderSide(color: color, width: width),
  );

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final enabled = widget.enabled;
    final labelStyle = theme.bodyMedium.copyWith(
      color: widget.labelColor ?? (enabled ? theme.text : theme.textDisabled),
    );
    final suffix = _password
        ? IconButton(
            onPressed: enabled
                ? () => setState(() => _obscure = !_obscure)
                : null,
            icon: Icon(
              _obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            tooltip:
                (_obscure
                    ? widget.showPasswordLabel
                    : widget.hidePasswordLabel) ??
                widget.label,
          )
        : widget.iconRight == null
        ? null
        : IconButton(
            onPressed: enabled ? widget.onIconRightPressed : null,
            icon: Icon(widget.iconRight),
            tooltip: widget.label,
          );
    final prefix = widget.type == UiKitTextFieldType.phone
        ? InkWell(
            onTap: enabled ? widget.onDialCodePressed : null,
            child: Padding(
              padding: EdgeInsets.only(
                left: theme.spacingMd,
                right: theme.spacingSm,
              ),
              child: Center(
                child: Text(
                  widget.dialCode,
                  style: theme.body.copyWith(
                    color: enabled ? theme.text : theme.textDisabled,
                  ),
                ),
              ),
            ),
          )
        : widget.iconLeft == null
        ? null
        : Padding(
            padding: EdgeInsets.only(left: theme.spacingMd),
            child: Icon(widget.iconLeft, color: theme.textMuted),
          );
    final decoration = InputDecoration(
      filled: true,
      fillColor: enabled ? theme.surface : theme.surfaceMuted,
      hintText: widget.placeholder,
      hintStyle: theme.body.copyWith(color: theme.textMuted),
      prefixIcon: prefix,
      suffixIcon: suffix,
      suffixText: widget.suffixText,
      suffixStyle: theme.body.copyWith(color: theme.textMuted),
      contentPadding: EdgeInsets.symmetric(
        horizontal: theme.spacingMd,
        vertical: theme.spacingMd,
      ),
      enabledBorder: _border(theme, _borderColor(theme)),
      focusedBorder: _border(theme, _borderColor(theme), width: 2),
      disabledBorder: _border(theme, theme.border),
      errorBorder: _border(theme, theme.error),
      focusedErrorBorder: _border(theme, theme.error, width: 2),
      errorText: widget.errorText,
      helperText: widget.errorText == null ? widget.helperText : null,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: widget.label,
            style: labelStyle,
            children: widget.isRequired
                ? [
                    TextSpan(
                      text: " *",
                      style: TextStyle(
                        color: theme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]
                : null,
          ),
        ),
        SizedBox(height: theme.spacingXs),
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          enabled: enabled,
          readOnly: widget.type == UiKitTextFieldType.select,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          obscureText: _obscure,
          maxLength: widget.maxLength,
          minLines: _textarea ? widget.minLines : 1,
          maxLines: _textarea ? widget.maxLines : 1,
          keyboardType:
              widget.keyboardType ??
              (widget.type == UiKitTextFieldType.phone
                  ? TextInputType.phone
                  : null),
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          autofillHints: widget.autofillHints,
          decoration: widget.type == UiKitTextFieldType.select
              ? decoration.copyWith(
                  suffixIcon: Icon(
                    widget.selectOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                )
              : decoration,
        ),
      ],
    );
  }
}

class UiKitUnitTextField extends StatelessWidget {
  const UiKitUnitTextField({
    required this.controller,
    required this.label,
    required this.unit,
    this.placeholder,
    this.onChanged,
    this.isRequired = false,
    this.errorText,
    this.inputFormatters,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String unit;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final bool isRequired;
  final String? errorText;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) => UiKitTextField(
    controller: controller,
    label: label,
    placeholder: placeholder,
    suffixText: unit,
    errorText: errorText,
    isRequired: isRequired,
    keyboardType: TextInputType.number,
    inputFormatters: inputFormatters,
    onChanged: onChanged,
  );
}
