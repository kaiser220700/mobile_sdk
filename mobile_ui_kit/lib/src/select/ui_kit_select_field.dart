import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/pressable/ui_kit_pressable.dart";
import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

/// Select field primitive. The host owns the option sheet/menu and feeds the
/// selected value back through [value] and [onTap].
class UiKitSelectField extends StatelessWidget {
  const UiKitSelectField({
    required this.label,
    required this.onTap,
    this.value,
    this.placeholder = "Select...",
    this.helperText,
    this.errorText,
    this.leading,
    this.open = false,
    this.enabled = true,
    this.isRequired = false,
    this.semanticsLabel,
    this.height,
    this.padding,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderWidth = 1,
    this.focusedBorderWidth = 2,
    this.borderRadius,
    this.labelStyle,
    this.valueStyle,
    this.helperStyle,
    this.trailing,
    this.animationDuration = const Duration(milliseconds: 150),
    super.key,
  }) : assert(borderWidth > 0 && focusedBorderWidth > 0);

  final String label;
  final String? value;
  final String placeholder;
  final String? helperText;
  final String? errorText;
  final Widget? leading;
  final VoidCallback? onTap;
  final bool open;
  final bool enabled;
  final bool isRequired;
  final String? semanticsLabel;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final double borderWidth;
  final double focusedBorderWidth;
  final double? borderRadius;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final TextStyle? helperStyle;
  final Widget? trailing;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final foreground = enabled ? theme.text : theme.textDisabled;
    final effectiveBorderColor = errorText == null
        ? borderColor ?? theme.border
        : errorBorderColor ?? theme.error;
    final displayValue = value ?? placeholder;
    final hasValue = value != null && value!.isNotEmpty;
    final field = AnimatedContainer(
      duration: animationDuration,
      constraints: BoxConstraints(minHeight: height ?? theme.touchMinTarget),
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: theme.spacingMd,
            vertical: theme.spacingSm,
          ),
      decoration: BoxDecoration(
        color: enabled
            ? backgroundColor ?? theme.surface
            : disabledBackgroundColor ?? theme.surfaceMuted,
        border: Border.all(
          color: open
              ? focusedBorderColor ?? effectiveBorderColor
              : effectiveBorderColor,
          width: open ? focusedBorderWidth : borderWidth,
        ),
        borderRadius: BorderRadius.circular(borderRadius ?? theme.radiusMd),
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            IconTheme.merge(
              data: IconThemeData(color: theme.textMuted),
              child: leading!,
            ),
            SizedBox(width: theme.spacingSm),
          ],
          Expanded(
            child: Text(
              displayValue,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (valueStyle ?? theme.body).copyWith(
                color: hasValue ? foreground : theme.textMuted,
              ),
            ),
          ),
          SizedBox(width: theme.spacingSm),
          trailing ??
              Icon(
                open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: foreground,
              ),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: (labelStyle ?? theme.bodyMedium).copyWith(
              color: enabled ? theme.text : theme.textDisabled,
            ),
            children: isRequired
                ? [
                    TextSpan(
                      text: " *",
                      style: TextStyle(color: theme.error),
                    ),
                  ]
                : null,
          ),
        ),
        SizedBox(height: theme.spacingXs),
        UiKitPressable(
          onPress: enabled ? onTap : null,
          semanticsLabel: semanticsLabel ?? "$label: $displayValue",
          builder: (context, states, child) => field,
        ),
        if (errorText != null || helperText != null) ...[
          SizedBox(height: theme.spacingXs),
          Text(
            errorText ?? helperText!,
            style: (helperStyle ?? theme.caption).copyWith(
              color: errorText == null ? theme.textMuted : theme.error,
            ),
          ),
        ],
      ],
    );
  }
}
