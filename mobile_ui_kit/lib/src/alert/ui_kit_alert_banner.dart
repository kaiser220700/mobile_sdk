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
    super.key,
  });

  final String title;
  final String? description;
  final UiKitAlertSemantic semantic;
  final IconData? icon;
  final bool hideIcon;
  final UiKitAlertAction? action;
  final VoidCallback? onClose;

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
    return Semantics(
      liveRegion: true,
      label: "$title${description == null ? "" : ". $description"}",
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: theme.spacingMd,
          horizontal: theme.spacingLg,
        ),
        decoration: BoxDecoration(
          color: colors.background,
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(theme.radiusMd),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!hideIcon) ...[
              Icon(icon ?? colors.icon, color: colors.foreground, size: 20),
              SizedBox(width: theme.spacingMd),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.bodyMedium.copyWith(color: theme.text),
                  ),
                  if (description != null) ...[
                    SizedBox(height: theme.spacing2xs),
                    Text(
                      description!,
                      style: theme.caption.copyWith(color: theme.textMuted),
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
                        style: theme.bodyMedium.copyWith(
                          color: colors.foreground,
                        ),
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
                tooltip: "Close",
              ),
          ],
        ),
      ),
    );
  }
}
