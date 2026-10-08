import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

enum UiKitAlertSemantic { success, warning, error, info, neutral }

class UiKitAlertAction {
  const UiKitAlertAction({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;
}

class UiKitAlertBanner extends StatelessWidget {
  const UiKitAlertBanner({
    required this.title,
    this.description,
    this.semantic = UiKitAlertSemantic.info,
    this.icon,
    this.hideIcon = false,
    this.action,
    this.onClose,
    this.backgroundColor,
    this.borderColor,
    this.foregroundColor,
    this.padding,
    this.borderWidth = 1,
    this.borderRadius,
    this.iconSize = 20,
    this.iconGap,
    this.titleStyle,
    this.descriptionStyle,
    this.closeTooltip = "Close",
    super.key,
  }) : assert(borderWidth > 0 && iconSize > 0);

  final String title;
  final String? description;
  final UiKitAlertSemantic semantic;
  final IconData? icon;
  final bool hideIcon;
  final UiKitAlertAction? action;
  final VoidCallback? onClose;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final double borderWidth;
  final double? borderRadius;
  final double iconSize;
  final double? iconGap;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
  final String closeTooltip;

  ({Color background, Color border, Color foreground, IconData icon}) _colors(
    UiKitThemeData theme,
  ) => switch (semantic) {
    UiKitAlertSemantic.success => (
      background: theme.successBg,
      border: theme.success,
      foreground: theme.success,
      icon: Icons.check_circle_outline,
    ),
    UiKitAlertSemantic.warning => (
      background: theme.warningBg,
      border: theme.warning,
      foreground: theme.warning,
      icon: Icons.warning_amber_outlined,
    ),
    UiKitAlertSemantic.error => (
      background: theme.errorBg,
      border: theme.error,
      foreground: theme.error,
      icon: Icons.cancel_outlined,
    ),
    UiKitAlertSemantic.info => (
      background: theme.infoBg,
      border: theme.info,
      foreground: theme.info,
      icon: Icons.info_outline,
    ),
    UiKitAlertSemantic.neutral => (
      background: theme.surfaceMuted,
      border: theme.borderStrong,
      foreground: theme.textMuted,
      icon: Icons.info_outline,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final colors = _colors(theme);
    final background = backgroundColor ?? colors.background;
    final border = borderColor ?? colors.border;
    final foreground = foregroundColor ?? colors.foreground;
    return Semantics(
      liveRegion: true,
      label: "$title${description == null ? "" : ". $description"}",
      child: Container(
        width: double.infinity,
        padding:
            padding ??
            EdgeInsets.symmetric(
              vertical: theme.spacingMd,
              horizontal: theme.spacingLg,
            ),
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: border, width: borderWidth),
          borderRadius: BorderRadius.circular(borderRadius ?? theme.radiusMd),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!hideIcon) ...[
              Icon(icon ?? colors.icon, color: foreground, size: iconSize),
              SizedBox(width: iconGap ?? theme.spacingMd),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: (titleStyle ?? theme.bodyMedium).copyWith(
                      color: theme.text,
                    ),
                  ),
                  if (description != null) ...[
                    SizedBox(height: theme.spacing2xs),
                    Text(
                      description!,
                      style: (descriptionStyle ?? theme.caption).copyWith(
                        color: theme.textMuted,
                      ),
                    ),
                  ],
                  if (action != null) ...[
                    SizedBox(height: theme.spacingSm),
                    TextButton(
                      onPressed: action!.onPressed,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        action!.label,
                        style: theme.bodyMedium.copyWith(color: foreground),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onClose != null)
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close, size: 18),
                color: theme.textMuted,
                tooltip: closeTooltip,
              ),
          ],
        ),
      ),
    );
  }
}
