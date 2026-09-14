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
  const UiKitTimeline({required this.items, super.key});

  final List<UiKitTimelineItem> items;

  Color _color(UiKitThemeData theme, UiKitTimelineStatus status) =>
      switch (status) {
        UiKitTimelineStatus.completed => theme.success,
        UiKitTimelineStatus.current => theme.primary,
        UiKitTimelineStatus.upcoming => theme.borderStrong,
        UiKitTimelineStatus.error => theme.error,
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
  });

  final UiKitTimelineItem item;
  final bool isLast;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox.square(
                    dimension: 24,
                    child: Icon(
                      item.icon ?? Icons.check,
                      size: 15,
                      color: theme.textInverse,
                    ),
                  ),
                ),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.title, style: theme.bodyMedium),
                      ),
                      if (item.time != null)
                        Text(item.time!, style: theme.caption),
                    ],
                  ),
                  if (item.description != null) ...[
                    SizedBox(height: theme.spacing2xs),
                    Text(item.description!, style: theme.caption),
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
