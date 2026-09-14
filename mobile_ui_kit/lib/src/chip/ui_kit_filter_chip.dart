import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

/// Toggle chip for filtering a list or table.
class UiKitFilterChip extends StatelessWidget {
  const UiKitFilterChip({
    required this.label,
    this.selected = false,
    this.onSelected,
    this.leadingIcon,
    this.selectedIcon = Icons.check,
    this.enabled = true,
    this.semanticsLabel,
    super.key,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final IconData? leadingIcon;
  final IconData? selectedIcon;
  final bool enabled;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final canTap = enabled && onSelected != null;
    final foreground = !enabled
        ? theme.textDisabled
        : selected
        ? theme.primary
        : theme.text;
    final background = !enabled
        ? theme.surfaceMuted
        : selected
        ? theme.primaryBg
        : theme.surface;
    return Semantics(
      button: true,
      toggled: selected,
      enabled: canTap,
      label: semanticsLabel ?? label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canTap ? () => onSelected!(!selected) : null,
          borderRadius: BorderRadius.circular(theme.radiusFull),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            constraints: BoxConstraints(minHeight: theme.touchMinTarget),
            padding: EdgeInsets.symmetric(horizontal: theme.spacingMd),
            decoration: BoxDecoration(
              color: background,
              border: Border.all(
                color: selected ? theme.primary : theme.border,
              ),
              borderRadius: BorderRadius.circular(theme.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected && selectedIcon != null)
                  Icon(selectedIcon, size: 16, color: foreground)
                else if (leadingIcon != null)
                  Icon(leadingIcon, size: 16, color: foreground),
                if ((selected && selectedIcon != null) || leadingIcon != null)
                  SizedBox(width: theme.spacingXs),
                Text(
                  label,
                  style: theme.bodyMedium.copyWith(color: foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
