import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/pressable/ui_kit_pressable.dart";
import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

enum UiKitCheckboxSize { sm, md, lg }

class UiKitCheckbox extends StatelessWidget {
  const UiKitCheckbox({
    required this.value,
    this.indeterminate = false,
    this.onChanged,
    this.label,
    this.description,
    this.inlineDescription = false,
    this.size = UiKitCheckboxSize.md,
    this.error = false,
    this.disabled = false,
    this.semanticsLabel,
    this.controlSize,
    this.touchTargetSize,
    this.borderWidth = 1.5,
    this.borderRadius,
    this.selectedColor,
    this.unselectedBorderColor,
    this.errorColor,
    this.disabledColor,
    this.checkColor,
    this.labelStyle,
    this.descriptionStyle,
    this.gap,
    this.animationDuration = const Duration(milliseconds: 150),
    super.key,
  }) : assert(borderWidth > 0);

  final bool value;
  final bool indeterminate;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final String? description;
  final bool inlineDescription;
  final UiKitCheckboxSize size;
  final bool error;
  final bool disabled;
  final String? semanticsLabel;
  final double? controlSize;
  final double? touchTargetSize;
  final double borderWidth;
  final double? borderRadius;
  final Color? selectedColor;
  final Color? unselectedBorderColor;
  final Color? errorColor;
  final Color? disabledColor;
  final Color? checkColor;
  final TextStyle? labelStyle;
  final TextStyle? descriptionStyle;
  final double? gap;
  final Duration animationDuration;

  bool get _disabled => disabled || onChanged == null;
  double get _size => switch (size) {
    UiKitCheckboxSize.sm => 16,
    UiKitCheckboxSize.md => 20,
    UiKitCheckboxSize.lg => 24,
  };

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final selected = value || indeterminate;
    final control = SizedBox(
      width: touchTargetSize ?? theme.touchMinTarget,
      height: touchTargetSize ?? theme.touchMinTarget,
      child: Center(
        child: AnimatedContainer(
          duration: animationDuration,
          width: controlSize ?? _size,
          height: controlSize ?? _size,
          decoration: BoxDecoration(
            color: _disabled
                ? (selected
                      ? disabledColor ?? theme.textDisabled
                      : Colors.transparent)
                : (selected
                      ? selectedColor ?? theme.primary
                      : Colors.transparent),
            border: Border.all(
              color: _disabled
                  ? disabledColor ?? theme.textDisabled
                  : (error
                        ? errorColor ?? theme.error
                        : (selected
                              ? selectedColor ?? theme.primary
                              : unselectedBorderColor ?? theme.borderControl)),
              width: borderWidth,
            ),
            borderRadius: BorderRadius.circular(borderRadius ?? theme.radiusSm),
          ),
          child: selected
              ? Icon(
                  indeterminate ? Icons.remove : Icons.check,
                  size: 16,
                  color: _disabled
                      ? disabledColor ?? theme.textDisabled
                      : checkColor ?? theme.textInverse,
                )
              : null,
        ),
      ),
    );
    final content = Row(
      children: [
        control,
        if (label != null)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: gap ?? theme.spacingSm),
              child: _label(theme),
            ),
          ),
      ],
    );
    return UiKitPressable(
      onPress: _disabled ? null : () => onChanged!(!value),
      checked: selected,
      semanticsLabel: semanticsLabel ?? label,
      builder: (context, states, child) => content,
    );
  }

  Widget _label(UiKitThemeData theme) {
    final labelStyle = (this.labelStyle ?? theme.bodyMedium).copyWith(
      color: _disabled ? theme.textDisabled : theme.text,
    );
    final descriptionStyle = (this.descriptionStyle ?? theme.caption).copyWith(
      color: _disabled ? theme.textDisabled : theme.textMuted,
    );
    if (description == null) return Text(label!, style: labelStyle);
    if (inlineDescription)
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(text: label, style: labelStyle),
            TextSpan(text: "  $description", style: descriptionStyle),
          ],
        ),
      );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label!, style: labelStyle),
        SizedBox(height: theme.spacing2xs),
        Text(description!, style: descriptionStyle),
      ],
    );
  }
}
