import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/icon/ui_kit_icon.dart";
import "package:mobile_ui_kit/src/pressable/ui_kit_pressable.dart";
import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

enum UiKitListItemSize { md, lg }

enum UiKitListItemDivider { none, full, inset }

class UiKitListItem extends StatelessWidget {
  const UiKitListItem({
    required this.title,
    this.description,
    this.titleMaxLines = 1,
    this.descriptionMaxLines = 1,
    this.size,
    this.leading,
    this.trailing,
    this.selected = false,
    this.divider = UiKitListItemDivider.none,
    this.onTap,
    this.hideChevron = false,
    this.disabled = false,
    this.semanticLabel,
    this.minHeight,
    this.padding,
    this.selectedColor,
    this.dividerColor,
    this.dividerThickness = 1,
    this.dividerInset,
    this.titleStyle,
    this.descriptionStyle,
    this.contentGap,
    this.trailingGap,
    super.key,
  }) : assert(dividerThickness > 0);

  final String title;
  final String? description;
  final int? titleMaxLines;
  final int? descriptionMaxLines;
  final UiKitListItemSize? size;
  final Widget? leading;
  final Widget? trailing;
  final bool selected;
  final UiKitListItemDivider divider;
  final VoidCallback? onTap;
  final bool hideChevron;
  final bool disabled;
  final String? semanticLabel;
  final double? minHeight;
  final EdgeInsetsGeometry? padding;
  final Color? selectedColor;
  final Color? dividerColor;
  final double dividerThickness;
  final double? dividerInset;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
  final double? contentGap;
  final double? trailingGap;

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final itemSize =
        size ??
        (description == null ? UiKitListItemSize.md : UiKitListItemSize.lg);
    final isDisabled = disabled && onTap != null;
    final end =
        trailing ??
        (onTap != null && !hideChevron
            ? const UiKitIcon(Icons.chevron_right, color: UiKitIconColor.muted)
            : null);
    final row = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: BoxConstraints(
            minHeight:
                minHeight ?? (itemSize == UiKitListItemSize.md ? 56 : 72),
          ),
          color: selected
              ? selectedColor ?? theme.primaryBg
              : Colors.transparent,
          padding:
              padding ??
              EdgeInsets.symmetric(
                horizontal: theme.spacingLg,
                vertical: theme.spacingMd,
              ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                SizedBox(width: contentGap ?? theme.spacingMd),
              ],
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: titleMaxLines,
                      overflow: titleMaxLines == null
                          ? TextOverflow.clip
                          : TextOverflow.ellipsis,
                      style: (titleStyle ?? theme.bodyMedium).copyWith(
                        color: isDisabled ? theme.textDisabled : theme.text,
                      ),
                    ),
                    if (description != null) ...[
                      SizedBox(height: theme.spacing2xs),
                      Text(
                        description!,
                        maxLines: descriptionMaxLines,
                        overflow: descriptionMaxLines == null
                            ? TextOverflow.clip
                            : TextOverflow.ellipsis,
                        style: (descriptionStyle ?? theme.caption).copyWith(
                          color: isDisabled ? theme.textDisabled : theme.text,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (end != null) ...[
                SizedBox(width: trailingGap ?? theme.spacingMd),
                end,
              ],
            ],
          ),
        ),
        if (divider != UiKitListItemDivider.none)
          Container(
            height: dividerThickness,
            margin: EdgeInsets.only(
              left: divider == UiKitListItemDivider.inset
                  ? dividerInset ?? theme.spacingLg
                  : 0,
            ),
            color: dividerColor ?? theme.border,
          ),
      ],
    );
    if (onTap == null) return row;
    return UiKitPressable(
      onPress: isDisabled ? null : onTap,
      selected: selected,
      semanticsLabel: semanticLabel ?? title,
      builder: (context, states, child) =>
          Opacity(opacity: isDisabled ? .4 : 1, child: row),
    );
  }
}
