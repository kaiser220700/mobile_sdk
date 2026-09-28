import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/pressable/ui_kit_pressable.dart";
import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

class UiKitBottomNavigationItem {
  const UiKitBottomNavigationItem({
    required this.label,
    required this.iconBuilder,
    this.badge,
    this.semanticsLabel,
  });

  final String label;
  final Widget Function(Color color) iconBuilder;
  final Widget? badge;
  final String? semanticsLabel;
}

/// Bottom navigation with host-owned icons, labels, badges and tokens.
class UiKitBottomNavigation extends StatelessWidget {
  const UiKitBottomNavigation({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.height,
    this.safeArea = true,
    this.backgroundColor,
    this.borderColor,
    this.selectedColor,
    this.unselectedColor,
    this.selectedBackgroundColor,
    this.labelStyle,
    this.selectedLabelStyle,
    this.iconContainerSize,
    this.iconContainerHeight,
    this.badgeOffset,
    this.tapThrottleDuration,
    super.key,
  }) : assert(items.length > 1),
       assert(selectedIndex >= 0 && selectedIndex < items.length);

  final List<UiKitBottomNavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final double? height;
  final bool safeArea;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedBackgroundColor;
  final TextStyle? labelStyle;
  final TextStyle? selectedLabelStyle;
  final double? iconContainerSize;
  final double? iconContainerHeight;
  final double? badgeOffset;
  final Duration? tapThrottleDuration;

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final visualHeight = height ?? 64;
    final child = SizedBox(
      height: visualHeight,
      child: Row(
        children: [
          for (var index = 0; index < items.length; index++)
            Expanded(
              child: _Item(
                item: items[index],
                selected: index == selectedIndex,
                onTap: () => onSelected(index),
                selectedColor: selectedColor ?? theme.primary,
                unselectedColor: unselectedColor ?? theme.textMuted,
                selectedBackgroundColor:
                    selectedBackgroundColor ?? theme.primaryBg,
                labelStyle: labelStyle ?? theme.caption,
                selectedLabelStyle: selectedLabelStyle ?? theme.bodySemibold,
                iconContainerSize: iconContainerSize ?? 48,
                iconContainerHeight: iconContainerHeight ?? 28,
                badgeOffset: badgeOffset ?? theme.spacingXs,
                tapThrottleDuration:
                    tapThrottleDuration ?? const Duration(milliseconds: 300),
              ),
            ),
        ],
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.surface,
        border: Border(top: BorderSide(color: borderColor ?? theme.border)),
      ),
      child: safeArea ? SafeArea(top: false, child: child) : child,
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
    required this.selectedBackgroundColor,
    required this.labelStyle,
    required this.selectedLabelStyle,
    required this.iconContainerSize,
    required this.iconContainerHeight,
    required this.badgeOffset,
    required this.tapThrottleDuration,
  });
  final UiKitBottomNavigationItem item;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;
  final Color selectedBackgroundColor;
  final TextStyle labelStyle;
  final TextStyle selectedLabelStyle;
  final double iconContainerSize;
  final double iconContainerHeight;
  final double badgeOffset;
  final Duration tapThrottleDuration;
  @override
  Widget build(BuildContext context) {
    final color = selected ? selectedColor : unselectedColor;
    return UiKitPressable(
      onPress: onTap,
      tapThrottleDuration: tapThrottleDuration,
      semanticsLabel: item.semanticsLabel ?? item.label,
      builder: (context, states, child) => Semantics(
        selected: selected,
        button: true,
        excludeSemantics: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: selected ? selectedBackgroundColor : Colors.transparent,
                borderRadius: BorderRadius.circular(
                  UiKitTheme.of(context).radiusFull,
                ),
              ),
              child: SizedBox(
                width: iconContainerSize,
                height: iconContainerHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    item.iconBuilder(color),
                    if (item.badge != null)
                      Positioned(
                        right: 0,
                        top: -badgeOffset,
                        child: item.badge!,
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: UiKitTheme.of(context).spacingXs),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (selected ? selectedLabelStyle : labelStyle).copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
