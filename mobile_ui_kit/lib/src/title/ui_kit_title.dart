import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

enum UiKitTitleHeadingSize { xl, xxl, lg, sm }

enum UiKitTitleDescriptionSize { xl, lg, sm }

class UiKitTitle extends StatelessWidget {
  const UiKitTitle({
    required this.text,
    this.description,
    this.align = TextAlign.start,
    this.headingSize = UiKitTitleHeadingSize.xl,
    this.descriptionSize = UiKitTitleDescriptionSize.lg,
    this.descriptionSpacing,
    this.isRequired = false,
    this.bottomSpacing = 0,
    this.headingStyle,
    this.descriptionStyle,
    this.headingColor,
    this.descriptionColor,
    this.requiredColor,
    super.key,
  });

  final String text;
  final String? description;
  final TextAlign align;
  final UiKitTitleHeadingSize headingSize;
  final UiKitTitleDescriptionSize descriptionSize;
  final double? descriptionSpacing;
  final bool isRequired;
  final double bottomSpacing;
  final TextStyle? headingStyle;
  final TextStyle? descriptionStyle;
  final Color? headingColor;
  final Color? descriptionColor;
  final Color? requiredColor;

  TextStyle _heading(UiKitThemeData theme) => switch (headingSize) {
    UiKitTitleHeadingSize.sm ||
    UiKitTitleHeadingSize.xl => theme.bodyMedium.copyWith(fontSize: 16),
    UiKitTitleHeadingSize.lg => theme.title.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w600,
    ),
    UiKitTitleHeadingSize.xxl => theme.title.copyWith(fontSize: 32),
  };

  TextStyle _description(UiKitThemeData theme) => switch (descriptionSize) {
    UiKitTitleDescriptionSize.sm => theme.caption.copyWith(
      color: theme.textMuted,
    ),
    UiKitTitleDescriptionSize.lg => theme.body.copyWith(color: theme.textMuted),
    UiKitTitleDescriptionSize.xl => theme.bodyLarge.copyWith(
      color: theme.textMuted,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final crossAxis = align == TextAlign.center
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing),
      child: Column(
        crossAxisAlignment: crossAxis,
        children: [
          Text.rich(
            TextSpan(
              text: text,
              style: (headingStyle ?? _heading(theme)).copyWith(
                color: headingColor ?? theme.text,
              ),
              children: isRequired
                  ? [
                      TextSpan(
                        text: " *",
                        style: TextStyle(color: requiredColor ?? theme.error),
                      ),
                    ]
                  : null,
            ),
            textAlign: align,
          ),
          if (description != null) ...[
            SizedBox(height: descriptionSpacing ?? theme.spacingSm),
            Text(
              description!,
              textAlign: align,
              style: (descriptionStyle ?? _description(theme)).copyWith(
                color: descriptionColor ?? theme.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
