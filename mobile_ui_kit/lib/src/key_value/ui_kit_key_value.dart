import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

/// Label/value row for settings, metadata and detail screens.
class UiKitKeyValue extends StatelessWidget {
  const UiKitKeyValue({
    required this.label,
    required this.value,
    this.valueWidget,
    this.onCopy,
    this.compact = false,
    super.key,
  });

  final String label;
  final String value;
  final Widget? valueWidget;
  final VoidCallback? onCopy;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final valueView = valueWidget ?? Text(value, style: theme.bodyMedium);
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: compact ? theme.spacingXs : theme.spacingSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.body.copyWith(color: theme.textMuted),
            ),
          ),
          SizedBox(width: theme.spacingLg),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: valueView),
                if (onCopy != null) ...[
                  SizedBox(width: theme.spacingXs),
                  IconButton(
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy_outlined, size: 16),
                    visualDensity: VisualDensity.compact,
                    tooltip: "Copy $label",
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
