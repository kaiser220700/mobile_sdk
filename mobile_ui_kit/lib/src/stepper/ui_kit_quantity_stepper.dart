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
    super.key,
  }) : assert(step > 0),
       assert(min == null || max == null || min <= max);

  final int value;
  final ValueChanged<int>? onChanged;
  final int? min;
  final int? max;
  final int step;
  final String semanticsLabel;

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
          border: Border.all(color: theme.border),
          borderRadius: BorderRadius.circular(theme.radiusMd),
          color: theme.surface,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Button(
              icon: Icons.remove,
              label: "Decrease $semanticsLabel",
              enabled: _canDecrease,
              onPressed: () => onChanged!(value - step),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 40),
              child: Text(
                "$value",
                textAlign: TextAlign.center,
                style: theme.bodyMedium.copyWith(color: theme.text),
              ),
            ),
            _Button(
              icon: Icons.add,
              label: "Increase $semanticsLabel",
              enabled: _canIncrease,
              onPressed: () => onChanged!(value + step),
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
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    return UiKitPressable(
      onPress: enabled ? onPressed : null,
      semanticsLabel: label,
      tapThrottleDuration: Duration.zero,
      builder: (context, states, child) => SizedBox.square(
        dimension: theme.touchMinTarget,
        child: Icon(
          icon,
          size: 18,
          color: enabled ? theme.text : theme.textDisabled,
        ),
      ),
    );
  }
}
