import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

enum UiKitIconSize { xs, sm, md, lg, xl, xxl }

enum UiKitIconColor {
  defaultColor,
  muted,
  inverse,
  primary,
  success,
  warning,
  error,
  info,
}

class UiKitIcon extends StatelessWidget {
  const UiKitIcon(
    this.icon, {
    this.size = UiKitIconSize.md,
    this.color = UiKitIconColor.defaultColor,
    this.semanticLabel,
    super.key,
  });

  final IconData icon;
  final UiKitIconSize size;
  final UiKitIconColor color;
  final String? semanticLabel;

  double get _size => switch (size) {
    UiKitIconSize.xs => 12,
    UiKitIconSize.sm => 16,
    UiKitIconSize.md => 20,
    UiKitIconSize.lg => 24,
    UiKitIconSize.xl => 32,
    UiKitIconSize.xxl => 40,
  };

  Color _color(UiKitThemeData theme) => switch (color) {
    UiKitIconColor.defaultColor => theme.text,
    UiKitIconColor.muted => theme.textMuted,
    UiKitIconColor.inverse => theme.textInverse,
    UiKitIconColor.primary => theme.primary,
    UiKitIconColor.success => theme.success,
    UiKitIconColor.warning => theme.warning,
    UiKitIconColor.error => theme.error,
    UiKitIconColor.info => theme.info,
  };

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    return Icon(
      icon,
      size: _size,
      color: _color(theme),
      semanticLabel: semanticLabel,
    );
  }
}
