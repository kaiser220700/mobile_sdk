import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

/// A compact count pill. Hosts provide tokens when the neutral defaults do not
/// match their design system.
class UiKitCountBadge extends StatelessWidget {
  const UiKitCountBadge({
    required this.count,
    this.maxCount = 99,
    this.height,
    this.minWidth,
    this.maxWidth,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
    this.textHeightBehavior,
    this.semanticsLabel,
    super.key,
  });

  final int count;
  final int maxCount;
  final double? height;
  final double? minWidth;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;
  final TextHeightBehavior? textHeightBehavior;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final label = count > maxCount ? "$maxCount+" : "$count";
    final visualHeight = height ?? 20;
    return Semantics(
      label: semanticsLabel ?? label,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth ?? visualHeight,
          maxWidth: maxWidth ?? visualHeight * 2,
          minHeight: visualHeight,
          maxHeight: visualHeight,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor ?? theme.error,
            borderRadius: BorderRadius.circular(theme.radiusFull),
          ),
          child: Padding(
            padding:
                padding ?? EdgeInsets.symmetric(horizontal: theme.spacingXs),
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.clip,
                textHeightBehavior: textHeightBehavior,
                style: (textStyle ?? theme.caption).copyWith(
                  color: foregroundColor ?? theme.textInverse,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
