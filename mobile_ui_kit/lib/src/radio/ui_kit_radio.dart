import "package:flutter/widgets.dart";

import "package:mobile_ui_kit/src/pressable/ui_kit_pressable.dart";
import "package:mobile_ui_kit/src/pressable/ui_kit_pressable_state.dart";
import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

/// Radio control thay `FRadio`.
///
/// Colors passed through the constructor override the runtime UI Kit theme.
class UiKitRadio extends StatelessWidget {
  const UiKitRadio({
    required this.value,
    this.onChanged,
    this.enabled = true,
    this.indicatorSize = 12,
    this.borderColor,
    this.selectedColor,
    this.disabledColor,
    this.label,
    this.semanticsLabel,
    this.borderWidth = 1.5,
    this.controlPadding = 4,
    this.labelGap,
    this.animationDuration = const Duration(milliseconds: 150),
    super.key,
  }) : assert(indicatorSize > 0 && borderWidth > 0 && controlPadding >= 0);

  final bool value;

  final ValueChanged<bool>? onChanged;

  final bool enabled;

  final double indicatorSize;

  /// Màu viền khi unchecked.
  final Color? borderColor;

  /// Màu viền + indicator dot khi checked.
  final Color? selectedColor;

  /// Override border/indicator color khi `!enabled`.
  final Color? disabledColor;

  final Widget? label;

  final String? semanticsLabel;

  final double borderWidth;
  final double controlPadding;
  final double? labelGap;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final defaultBorderColor = borderColor ?? theme.borderControl;
    final defaultSelectedColor = selectedColor ?? theme.primary;
    final circleDiameter = indicatorSize + (controlPadding * 2);

    return UiKitPressable(
      onPress: (!enabled || onChanged == null)
          ? null
          : () => onChanged!(!value),
      selected: value,
      semanticsLabel: semanticsLabel,
      builder: (context, states, child) {
        final disabled = states.contains(UiKitPressableState.disabled);
        final effectiveColor = disabled
            ? (disabledColor ?? defaultBorderColor)
            : (value ? defaultSelectedColor : defaultBorderColor);

        final circle = Container(
          width: circleDiameter,
          height: circleDiameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: effectiveColor, width: borderWidth),
          ),
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: animationDuration,
            width: value ? indicatorSize : 0,
            height: value ? indicatorSize : 0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: effectiveColor,
            ),
          ),
        );

        if (label == null) return circle;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            circle,
            SizedBox(width: labelGap ?? theme.spacingSm),
            label!,
          ],
        );
      },
    );
  }
}
