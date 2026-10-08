import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/pressable/ui_kit_pressable.dart";
import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

enum UiKitStatTrend { up, down, neutral }

enum UiKitStatTileLayout { labelFirst, valueFirst }

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
    this.layout = UiKitStatTileLayout.labelFirst,
    this.valueStyle,
    this.labelStyle,
    this.valueColor,
    this.minHeight,
    this.showBorder = true,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.borderRadius,
    this.descriptionStyle,
    this.trendColor,
    this.iconColor,
    super.key,
  }) : assert(borderWidth > 0);

  final String label;
  final String value;
  final String? description;
  final IconData? icon;
  final UiKitStatTrend? trend;
  final String? trendLabel;
  final VoidCallback? onTap;
  final UiKitStatTileLayout layout;
  final TextStyle? valueStyle;
  final TextStyle? labelStyle;
  final Color? valueColor;
  final double? minHeight;
  final bool showBorder;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double? borderRadius;
  final TextStyle? descriptionStyle;
  final Color? trendColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final effectiveTrendColor =
        trendColor ??
        switch (trend) {
          UiKitStatTrend.up => theme.success,
          UiKitStatTrend.down => theme.error,
          null || UiKitStatTrend.neutral => theme.textMuted,
        };
    final labelView = Text(
      label,
      style: labelStyle ?? theme.bodyMedium.copyWith(color: theme.textMuted),
    );
    final valueView = Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: (valueStyle ?? theme.title.copyWith(fontSize: 24)).copyWith(
        color: valueColor,
      ),
    );
    final header = Row(
      children: [
        Expanded(child: labelView),
        if (icon != null) Icon(icon, color: iconColor ?? theme.primary),
      ],
    );
    final content = Padding(
      padding: padding ?? EdgeInsets.all(theme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (layout == UiKitStatTileLayout.labelFirst) header else valueView,
          SizedBox(height: theme.spacingSm),
          if (layout == UiKitStatTileLayout.labelFirst) valueView else header,
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
                      color: effectiveTrendColor,
                    ),
                  if (trend != null) SizedBox(width: theme.spacing2xs),
                  Text(
                    trendLabel!,
                    style: (descriptionStyle ?? theme.caption).copyWith(
                      color: effectiveTrendColor,
                    ),
                  ),
                ],
                if (trendLabel != null && description != null)
                  SizedBox(width: theme.spacingSm),
                if (description != null)
                  Flexible(
                    child: Text(
                      description!,
                      style: descriptionStyle ?? theme.caption,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
    final tile = ConstrainedBox(
      constraints: minHeight == null
          ? const BoxConstraints()
          : BoxConstraints(minHeight: minHeight!),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.surface,
          border: showBorder
              ? Border.all(
                  color: borderColor ?? theme.border,
                  width: borderWidth,
                )
              : null,
          borderRadius: BorderRadius.circular(borderRadius ?? theme.radiusLg),
        ),
        child: content,
      ),
    );
    if (onTap == null) {
      return Semantics(label: "$label: $value", child: tile);
    }
    return UiKitPressable(
      onPress: onTap,
      semanticsLabel: "$label: $value",
      builder: (context, states, child) => tile,
    );
  }
}
