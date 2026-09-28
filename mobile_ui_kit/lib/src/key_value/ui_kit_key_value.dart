import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

enum UiKitKeyValueLayout { inline, stacked }

/// Label/value row for settings, metadata and detail screens.
class UiKitKeyValue extends StatelessWidget {
  const UiKitKeyValue({
    required this.label,
    required this.value,
    this.valueWidget,
    this.onCopy,
    this.compact = false,
    this.layout = UiKitKeyValueLayout.inline,
    this.leading,
    this.showDivider = false,
    this.first = false,
    this.emptyValue,
    this.labelStyle,
    this.valueStyle,
    super.key,
  });

  final String label;
  final String value;
  final Widget? valueWidget;
  final VoidCallback? onCopy;
  final bool compact;
  final UiKitKeyValueLayout layout;
  final Widget? leading;
  final bool showDivider;
  final bool first;
  final String? emptyValue;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final effectiveValue = value.isEmpty && emptyValue != null
        ? emptyValue!
        : value;
    final empty = value.isEmpty && emptyValue != null;
    final valueView =
        valueWidget ??
        Text(
          effectiveValue,
          style: (valueStyle ?? theme.bodyMedium).copyWith(
            color: empty ? theme.textMuted : null,
          ),
        );
    final labelView = Text(
      label,
      style: labelStyle ?? theme.body.copyWith(color: theme.textMuted),
    );
    if (layout == UiKitKeyValueLayout.stacked) {
      return Container(
        padding: EdgeInsets.only(
          top: first ? 0 : (compact ? theme.spacingXs : theme.spacingSm),
          bottom: compact ? theme.spacingXs : theme.spacingSm,
        ),
        decoration: showDivider && !first
            ? BoxDecoration(
                border: Border(top: BorderSide(color: theme.border)),
              )
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leading != null) ...[
              leading!,
              SizedBox(width: theme.spacingSm),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  labelView,
                  SizedBox(height: theme.spacingXs),
                  valueView,
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: compact ? theme.spacingXs : theme.spacingSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: labelView),
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
