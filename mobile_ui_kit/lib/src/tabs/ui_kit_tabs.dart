import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/pressable/ui_kit_pressable.dart";
import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

enum UiKitTabsVariant { underline, pill }

enum UiKitTabsLayout { equal, auto }

class UiKitTabBadge {
  const UiKitTabBadge({this.count, this.dot = false, this.semanticsLabel})
    : assert(count == null || count > 0, "count must be greater than zero.");
  final int? count;
  final bool dot;
  final String? semanticsLabel;
  bool get visible => dot || (count != null && count! > 0);
}

class UiKitTabItem {
  const UiKitTabItem({
    required this.id,
    required this.label,
    this.icon,
    this.badge,
    this.disabled = false,
  });
  final String id;
  final String label;
  final IconData? icon;
  final UiKitTabBadge? badge;
  final bool disabled;
}

class UiKitTabs extends StatelessWidget {
  const UiKitTabs({
    required this.items,
    required this.activeId,
    required this.onChanged,
    this.variant = UiKitTabsVariant.underline,
    this.layout = UiKitTabsLayout.equal,
    this.semanticsLabel,
    super.key,
  }) : assert(items.length >= 2, "Tabs need at least two items.");
  final List<UiKitTabItem> items;
  final String activeId;
  final ValueChanged<String> onChanged;
  final UiKitTabsVariant variant;
  final UiKitTabsLayout layout;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final row = Row(
      mainAxisSize: layout == UiKitTabsLayout.auto
          ? MainAxisSize.min
          : MainAxisSize.max,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (variant == UiKitTabsVariant.pill && i > 0)
            SizedBox(width: theme.spacingSm),
          if (layout == UiKitTabsLayout.equal)
            Expanded(child: _item(items[i], theme))
          else
            _item(items[i], theme),
        ],
      ],
    );
    return Semantics(
      label: semanticsLabel,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: variant == UiKitTabsVariant.underline
              ? Border(bottom: BorderSide(color: theme.border))
              : null,
        ),
        child: SizedBox(
          height: 44,
          child: layout == UiKitTabsLayout.auto
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: row,
                )
              : row,
        ),
      ),
    );
  }

  Widget _item(UiKitTabItem item, UiKitThemeData theme) {
    final active = item.id == activeId;
    final foreground = item.disabled
        ? theme.textDisabled
        : (active
              ? (variant == UiKitTabsVariant.pill
                    ? theme.textInverse
                    : theme.primary)
              : theme.textMuted);
    return UiKitPressable(
      onPress: item.disabled || active ? null : () => onChanged(item.id),
      selected: active,
      semanticsLabel: item.badge?.semanticsLabel == null
          ? item.label
          : "${item.label}, ${item.badge!.semanticsLabel}",
      builder: (context, states, child) => Opacity(
        opacity: item.disabled ? .4 : 1,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: variant == UiKitTabsVariant.pill
                ? theme.spacingSm
                : theme.spacingMd,
          ),
          decoration: BoxDecoration(
            color: variant == UiKitTabsVariant.pill && active
                ? theme.primary
                : Colors.transparent,
            borderRadius: variant == UiKitTabsVariant.pill
                ? BorderRadius.circular(theme.radiusFull)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.icon != null) ...[
                Icon(item.icon, size: 20, color: foreground),
                SizedBox(width: theme.spacingXs),
              ],
              Text(
                item.label,
                style: (active ? theme.button : theme.bodyMedium).copyWith(
                  color: foreground,
                ),
              ),
              if (item.badge?.visible == true) ...[
                SizedBox(width: theme.spacingXs),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  height: 18,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: variant == UiKitTabsVariant.pill && active
                        ? theme.surface
                        : theme.primaryBg,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    item.badge!.dot ? "" : "${item.badge!.count}",
                    style: theme.caption.copyWith(
                      color: theme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
