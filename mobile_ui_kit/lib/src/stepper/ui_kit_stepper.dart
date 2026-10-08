import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/pressable/ui_kit_pressable.dart";
import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

@immutable
class UiKitStep {
  const UiKitStep({
    required this.title,
    this.subtitle,
    this.icon,
    this.enabled = true,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool enabled;
}

/// Vertical stepper for multi-step flows. Content remains owned by the host.
class UiKitStepper extends StatelessWidget {
  const UiKitStepper({
    required this.steps,
    required this.currentIndex,
    this.onStepTapped,
    this.indicatorSize = 28,
    this.rowHeight = 64,
    this.connectorWidth = 1,
    this.contentGap,
    this.itemSpacing,
    this.activeColor,
    this.inactiveColor,
    this.disabledColor,
    this.connectorColor,
    this.titleStyle,
    this.subtitleStyle,
    super.key,
  }) : assert(indicatorSize > 0 && rowHeight > 0 && connectorWidth > 0);

  final List<UiKitStep> steps;
  final int currentIndex;
  final ValueChanged<int>? onStepTapped;
  final double indicatorSize;
  final double rowHeight;
  final double connectorWidth;
  final double? contentGap;
  final double? itemSpacing;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? disabledColor;
  final Color? connectorColor;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    return Column(
      children: [
        for (var index = 0; index < steps.length; index++)
          _StepRow(
            step: steps[index],
            index: index,
            currentIndex: currentIndex,
            isLast: index == steps.length - 1,
            onTap: steps[index].enabled && onStepTapped != null
                ? () => onStepTapped!(index)
                : null,
            theme: theme,
            indicatorSize: indicatorSize,
            rowHeight: rowHeight,
            connectorWidth: connectorWidth,
            contentGap: contentGap ?? theme.spacingMd,
            itemSpacing: itemSpacing ?? theme.spacingLg,
            activeColor: activeColor ?? theme.primary,
            inactiveColor: inactiveColor ?? theme.borderStrong,
            disabledColor: disabledColor ?? theme.textDisabled,
            connectorColor: connectorColor ?? theme.border,
            titleStyle: titleStyle ?? theme.bodyMedium,
            subtitleStyle: subtitleStyle ?? theme.caption,
          ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.index,
    required this.currentIndex,
    required this.isLast,
    required this.onTap,
    required this.theme,
    required this.indicatorSize,
    required this.rowHeight,
    required this.connectorWidth,
    required this.contentGap,
    required this.itemSpacing,
    required this.activeColor,
    required this.inactiveColor,
    required this.disabledColor,
    required this.connectorColor,
    required this.titleStyle,
    required this.subtitleStyle,
  });

  final UiKitStep step;
  final int index;
  final int currentIndex;
  final bool isLast;
  final VoidCallback? onTap;
  final UiKitThemeData theme;
  final double indicatorSize;
  final double rowHeight;
  final double connectorWidth;
  final double contentGap;
  final double itemSpacing;
  final Color activeColor;
  final Color inactiveColor;
  final Color disabledColor;
  final Color connectorColor;
  final TextStyle titleStyle;
  final TextStyle subtitleStyle;

  @override
  Widget build(BuildContext context) {
    final completed = index < currentIndex;
    final current = index == currentIndex;
    final active = completed || current;
    final color = !step.enabled
        ? disabledColor
        : active
        ? activeColor
        : inactiveColor;
    final indicator = DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: SizedBox.square(
        dimension: indicatorSize,
        child: Center(
          child: completed
              ? Icon(Icons.check, size: 17, color: theme.textInverse)
              : step.icon != null
              ? Icon(step.icon, size: 16, color: theme.textInverse)
              : Text(
                  "${index + 1}",
                  style: theme.bodyMedium.copyWith(color: theme.textInverse),
                ),
        ),
      ),
    );
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: indicatorSize,
          child: Column(
            children: [
              indicator,
              if (!isLast)
                Expanded(
                  child: Container(
                    width: connectorWidth,
                    color: connectorColor,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: contentGap),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : itemSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: titleStyle.copyWith(
                    color: step.enabled ? theme.text : disabledColor,
                  ),
                ),
                if (step.subtitle != null) ...[
                  SizedBox(height: theme.spacing2xs),
                  Text(step.subtitle!, style: subtitleStyle),
                ],
              ],
            ),
          ),
        ),
      ],
    );
    return SizedBox(
      height: isLast ? null : rowHeight,
      child: onTap == null
          ? row
          : UiKitPressable(
              onPress: onTap,
              semanticsLabel: step.title,
              builder: (context, states, child) => row,
            ),
    );
  }
}
