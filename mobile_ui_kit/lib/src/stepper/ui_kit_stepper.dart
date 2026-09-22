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
    super.key,
  });

  final List<UiKitStep> steps;
  final int currentIndex;
  final ValueChanged<int>? onStepTapped;

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
  });

  final UiKitStep step;
  final int index;
  final int currentIndex;
  final bool isLast;
  final VoidCallback? onTap;
  final UiKitThemeData theme;

  @override
  Widget build(BuildContext context) {
    final completed = index < currentIndex;
    final current = index == currentIndex;
    final active = completed || current;
    final color = !step.enabled
        ? theme.textDisabled
        : active
        ? theme.primary
        : theme.borderStrong;
    final indicator = DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: SizedBox.square(
        dimension: 28,
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
          width: 28,
          child: Column(
            children: [
              indicator,
              if (!isLast)
                Expanded(child: Container(width: 1, color: theme.border)),
            ],
          ),
        ),
        SizedBox(width: theme.spacingMd),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : theme.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: theme.bodyMedium.copyWith(
                    color: step.enabled ? theme.text : theme.textDisabled,
                  ),
                ),
                if (step.subtitle != null) ...[
                  SizedBox(height: theme.spacing2xs),
                  Text(step.subtitle!, style: theme.caption),
                ],
              ],
            ),
          ),
        ),
      ],
    );
    return SizedBox(
      height: isLast ? null : 64,
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
