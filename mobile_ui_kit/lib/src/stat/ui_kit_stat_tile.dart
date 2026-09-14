import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

enum UiKitStatTrend { up, down, neutral }

/// Compact metric tile for dashboards and summary screens.
class UiKitStatTile extends StatelessWidget {
  const UiKitStatTile({
    required this.label,
    required this.value,
    this.description,
    this.icon,
    this.trend,
    this.trendLabel,
    this.onTap,
    super.key,
  });

  final String label;
  final String value;
  final String? description;
  final IconData? icon;
  final UiKitStatTrend? trend;
  final String? trendLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final trendColor = switch (trend) {
      UiKitStatTrend.up => theme.success,
      UiKitStatTrend.down => theme.error,
      null || UiKitStatTrend.neutral => theme.textMuted,
    };
    final content = Padding(
      padding: EdgeInsets.all(theme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.bodyMedium.copyWith(color: theme.textMuted),
                ),
              ),
              if (icon != null) Icon(icon, color: theme.primary),
            ],
          ),
          SizedBox(height: theme.spacingSm),
          Text(value, style: theme.title.copyWith(fontSize: 24)),
          if (trendLabel != null || description != null) ...[
            SizedBox(height: theme.spacingXs),
            Row(
              children: [
                if (trendLabel != null) ...[
                  if (trend != null)
                    Icon(
                      switch (trend) {
                        UiKitStatTrend.up => Icons.trending_up,
                        UiKitStatTrend.down => Icons.trending_down,
                        UiKitStatTrend.neutral => Icons.trending_flat,
                        null => Icons.trending_flat,
                      },
                      size: 16,
                      color: trendColor,
                    ),
                  if (trend != null) SizedBox(width: theme.spacing2xs),
                  Text(
                    trendLabel!,
                    style: theme.caption.copyWith(color: trendColor),
                  ),
                ],
                if (trendLabel != null && description != null)
                  SizedBox(width: theme.spacingSm),
                if (description != null)
                  Flexible(child: Text(description!, style: theme.caption)),
              ],
            ),
          ],
        ],
      ),
    );
    return Semantics(
      label: "$label: $value",
      button: onTap != null,
      child: Container(
        decoration: BoxDecoration(
          color: theme.surface,
          border: Border.all(color: theme.border),
          borderRadius: BorderRadius.circular(theme.radiusLg),
        ),
        child: onTap == null
            ? content
            : InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(theme.radiusLg),
                child: content,
              ),
      ),
    );
  }
}
