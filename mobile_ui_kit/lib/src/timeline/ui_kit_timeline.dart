import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

enum UiKitTimelineStatus { completed, current, upcoming, error }

@immutable
class UiKitTimelineItem {
  const UiKitTimelineItem({
    required this.title,
    this.description,
    this.time,
    this.status = UiKitTimelineStatus.upcoming,
    this.icon,
  });

  final String title;
  final String? description;
  final String? time;
  final UiKitTimelineStatus status;
  final IconData? icon;
}

/// Vertical timeline with completed/current/upcoming states.
class UiKitTimeline extends StatelessWidget {
  const UiKitTimeline({
    required this.items,
    this.indicatorSize = 24,
    this.indicatorColumnWidth = 28,
    this.iconSize = 15,
    this.connectorWidth = 1,
    this.contentGap,
    this.itemSpacing,
    this.completedColor,
    this.currentColor,
    this.upcomingColor,
    this.errorColor,
    this.connectorColor,
    this.titleStyle,
    this.descriptionStyle,
    this.timeStyle,
    super.key,
  }) : assert(
         indicatorSize > 0 && indicatorColumnWidth > 0 && connectorWidth > 0,
       );

  final List<UiKitTimelineItem> items;
  final double indicatorSize;
  final double indicatorColumnWidth;
  final double iconSize;
  final double connectorWidth;
  final double? contentGap;
  final double? itemSpacing;
  final Color? completedColor;
  final Color? currentColor;
  final Color? upcomingColor;
  final Color? errorColor;
  final Color? connectorColor;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
  final TextStyle? timeStyle;

  Color _color(UiKitThemeData theme, UiKitTimelineStatus status) =>
      switch (status) {
        UiKitTimelineStatus.completed => completedColor ?? theme.success,
        UiKitTimelineStatus.current => currentColor ?? theme.primary,
        UiKitTimelineStatus.upcoming => upcomingColor ?? theme.borderStrong,
        UiKitTimelineStatus.error => errorColor ?? theme.error,
      };

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    return Column(
      children: [
        for (var index = 0; index < items.length; index++)
          _TimelineRow(
            item: items[index],
            isLast: index == items.length - 1,
            color: _color(theme, items[index].status),
            indicatorSize: indicatorSize,
            indicatorColumnWidth: indicatorColumnWidth,
            iconSize: iconSize,
            connectorWidth: connectorWidth,
            contentGap: contentGap ?? theme.spacingMd,
            itemSpacing: itemSpacing ?? theme.spacingLg,
            connectorColor: connectorColor ?? theme.border,
            titleStyle: titleStyle ?? theme.bodyMedium,
            descriptionStyle: descriptionStyle ?? theme.caption,
            timeStyle: timeStyle ?? theme.caption,
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.item,
    required this.isLast,
    required this.color,
    required this.indicatorSize,
    required this.indicatorColumnWidth,
    required this.iconSize,
    required this.connectorWidth,
    required this.contentGap,
    required this.itemSpacing,
    required this.connectorColor,
    required this.titleStyle,
    required this.descriptionStyle,
    required this.timeStyle,
  });

  final UiKitTimelineItem item;
  final bool isLast;
  final Color color;
  final double indicatorSize;
  final double indicatorColumnWidth;
  final double iconSize;
  final double connectorWidth;
  final double contentGap;
  final double itemSpacing;
  final Color connectorColor;
  final TextStyle titleStyle;
  final TextStyle descriptionStyle;
  final TextStyle timeStyle;

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: indicatorColumnWidth,
            child: Column(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox.square(
                    dimension: indicatorSize,
                    child: Icon(
                      item.icon ?? Icons.check,
                      size: iconSize,
                      color: theme.textInverse,
                    ),
                  ),
                ),
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
                  Row(
                    children: [
                      Expanded(child: Text(item.title, style: titleStyle)),
                      if (item.time != null) Text(item.time!, style: timeStyle),
                    ],
                  ),
                  if (item.description != null) ...[
                    SizedBox(height: theme.spacing2xs),
                    Text(item.description!, style: descriptionStyle),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
