import "package:flutter/material.dart";
import "package:skeletonizer/skeletonizer.dart";

import "package:mobile_ui_kit/src/pressable/ui_kit_pressable.dart";
import "package:mobile_ui_kit/src/pressable/ui_kit_pressable_state.dart";
import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

/// Toggle chip for filtering a list or table.
class UiKitFilterChip extends StatelessWidget {
  const UiKitFilterChip({
    required this.label,
    this.selected = false,
    this.onSelected,
    this.leadingIcon,
    this.selectedIcon = Icons.check,
    this.trailingText,
    this.enabled = true,
    this.semanticsLabel,
    this.height,
    this.touchHeight,
    this.horizontalPadding,
    this.gap,
    this.borderRadius,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.disabledBackgroundColor,
    this.disabledSelectedBackgroundColor,
    this.borderColor,
    this.selectedBorderColor,
    this.disabledBorderColor,
    this.disabledSelectedBorderColor,
    this.foregroundColor,
    this.selectedForegroundColor,
    this.disabledForegroundColor,
    this.labelStyle,
    this.trailingStyle,
    this.animationDuration = const Duration(milliseconds: 150),
    this.tapThrottleDuration = const Duration(milliseconds: 300),
    this.skeletonLeaf = false,
    super.key,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final IconData? leadingIcon;
  final IconData? selectedIcon;
  final String? trailingText;
  final bool enabled;
  final String? semanticsLabel;
  final double? height;
  final double? touchHeight;
  final double? horizontalPadding;
  final double? gap;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? selectedBackgroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledSelectedBackgroundColor;
  final Color? borderColor;
  final Color? selectedBorderColor;
  final Color? disabledBorderColor;
  final Color? disabledSelectedBorderColor;
  final Color? foregroundColor;
  final Color? selectedForegroundColor;
  final Color? disabledForegroundColor;
  final TextStyle? labelStyle;
  final TextStyle? trailingStyle;
  final Duration animationDuration;
  final Duration tapThrottleDuration;
  final bool skeletonLeaf;

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final canTap = enabled && onSelected != null;
    final foreground = !enabled
        ? disabledForegroundColor ?? theme.textDisabled
        : selected
        ? selectedForegroundColor ?? theme.primary
        : foregroundColor ?? theme.text;
    final background = !enabled
        ? selected
              ? disabledSelectedBackgroundColor ?? theme.surfaceMuted
              : disabledBackgroundColor ?? theme.surfaceMuted
        : selected
        ? selectedBackgroundColor ?? theme.primaryBg
        : backgroundColor ?? theme.surface;
    final border = !enabled
        ? selected
              ? disabledSelectedBorderColor ?? theme.border
              : disabledBorderColor ?? theme.border
        : selected
        ? selectedBorderColor ?? theme.primary
        : borderColor ?? theme.border;
    final visualHeight = height ?? theme.touchMinTarget;
    final targetHeight = touchHeight ?? visualHeight;
    final itemGap = gap ?? theme.spacingXs;
    final hasLeading =
        (selected && selectedIcon != null) || leadingIcon != null;
    final visual = AnimatedContainer(
      duration: animationDuration,
      height: visualHeight,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding ?? theme.spacingMd,
      ),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(borderRadius ?? theme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasLeading)
            Icon(
              selected && selectedIcon != null ? selectedIcon : leadingIcon,
              size: 16,
              color: foreground,
            ),
          if (hasLeading) SizedBox(width: itemGap),
          Text(
            label,
            style: (labelStyle ?? theme.bodyMedium).copyWith(color: foreground),
          ),
          if (trailingText != null) SizedBox(width: itemGap),
          if (trailingText != null)
            Text(
              trailingText!,
              style: (trailingStyle ?? labelStyle ?? theme.bodyMedium).copyWith(
                color: foreground,
              ),
            ),
        ],
      ),
    );
    return UiKitPressable(
      onPress: canTap ? () => onSelected!(!selected) : null,
      selected: selected,
      toggled: selected,
      semanticsLabel: semanticsLabel ?? label,
      tapThrottleDuration: tapThrottleDuration,
      builder: (context, states, child) {
        final pressed = states.contains(UiKitPressableState.pressed);
        final child = pressed && canTap
            ? ColorFiltered(
                colorFilter: ColorFilter.mode(
                  theme.primary.withValues(alpha: .08),
                  BlendMode.srcATop,
                ),
                child: visual,
              )
            : visual;
        return SizedBox(
          height: targetHeight,
          child: Center(
            widthFactor: 1,
            child: skeletonLeaf ? Skeleton.leaf(child: child) : child,
          ),
        );
      },
    );
  }
}
