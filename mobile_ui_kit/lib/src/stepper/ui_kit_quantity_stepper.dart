import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/pressable/ui_kit_pressable.dart";
import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

/// Controlled increment/decrement input for quantities and numeric settings.
class UiKitQuantityStepper extends StatelessWidget {
  const UiKitQuantityStepper({
    required this.value,
    required this.onChanged,
    this.min,
    this.max,
    this.step = 1,
    this.semanticsLabel = "Quantity",
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.borderRadius,
    this.buttonSize,
    this.valueMinWidth = 40,
    this.iconSize = 18,
    this.enabledColor,
    this.disabledColor,
    this.valueStyle,
    super.key,
  }) : assert(step > 0),
       assert(min == null || max == null || min <= max),
       assert(borderWidth > 0 && (buttonSize == null || buttonSize > 0)),
       assert(valueMinWidth > 0 && iconSize > 0);

  final int value;
  final ValueChanged<int>? onChanged;
  final int? min;
  final int? max;
  final int step;
  final String semanticsLabel;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double? borderRadius;
  final double? buttonSize;
  final double valueMinWidth;
  final double iconSize;
  final Color? enabledColor;
  final Color? disabledColor;
  final TextStyle? valueStyle;

  bool get _canDecrease =>
      onChanged != null && (min == null || value - step >= min!);
  bool get _canIncrease =>
      onChanged != null && (max == null || value + step <= max!);

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    return Semantics(
      label: semanticsLabel,
      value: "$value",
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor ?? theme.border,
            width: borderWidth,
          ),
          borderRadius: BorderRadius.circular(borderRadius ?? theme.radiusMd),
          color: backgroundColor ?? theme.surface,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Button(
              icon: Icons.remove,
              label: "Decrease $semanticsLabel",
              enabled: _canDecrease,
              onPressed: () => onChanged!(value - step),
              size: buttonSize ?? theme.touchMinTarget,
              iconSize: iconSize,
              enabledColor: enabledColor ?? theme.text,
              disabledColor: disabledColor ?? theme.textDisabled,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: valueMinWidth),
              child: Text(
                "$value",
                textAlign: TextAlign.center,
                style: (valueStyle ?? theme.bodyMedium).copyWith(
                  color: enabledColor ?? theme.text,
                ),
              ),
            ),
            _Button(
              icon: Icons.add,
              label: "Increase $semanticsLabel",
              enabled: _canIncrease,
              onPressed: () => onChanged!(value + step),
              size: buttonSize ?? theme.touchMinTarget,
              iconSize: iconSize,
              enabledColor: enabledColor ?? theme.text,
              disabledColor: disabledColor ?? theme.textDisabled,
            ),
          ],
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onPressed,
    required this.size,
    required this.iconSize,
    required this.enabledColor,
    required this.disabledColor,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;
  final Color enabledColor;
  final Color disabledColor;

  @override
  Widget build(BuildContext context) {
    return UiKitPressable(
      onPress: enabled ? onPressed : null,
      semanticsLabel: label,
      tapThrottleDuration: Duration.zero,
      builder: (context, states, child) => SizedBox.square(
        dimension: size,
        child: Icon(
          icon,
          size: iconSize,
          color: enabled ? enabledColor : disabledColor,
        ),
      ),
    );
  }
}
