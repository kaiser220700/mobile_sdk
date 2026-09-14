import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

enum UiKitBadgeVariant { solid, soft, outline, dot }

enum UiKitBadgeSemantic { neutral, primary, success, warning, error, info }

enum UiKitBadgeSize { sm, md, lg }

enum UiKitBadgeShape { pill, rounded }

class UiKitBadge extends StatelessWidget {
  const UiKitBadge({
    this.label,
    this.count,
    this.maxCount = 99,
    this.icon,
    this.variant = UiKitBadgeVariant.soft,
    this.semantic = UiKitBadgeSemantic.neutral,
    this.size = UiKitBadgeSize.md,
    this.shape = UiKitBadgeShape.pill,
    this.semanticsLabel,
    super.key,
  }) : assert(label == null || count == null, "Use label or count, not both.");

  /// Text-only badge/status pill.
  const UiKitBadge.text({
    required String label,
    UiKitBadgeVariant variant = UiKitBadgeVariant.soft,
    UiKitBadgeSemantic semantic = UiKitBadgeSemantic.neutral,
    UiKitBadgeSize size = UiKitBadgeSize.md,
    UiKitBadgeShape shape = UiKitBadgeShape.pill,
    String? semanticsLabel,
    Key? key,
  }) : this(
         label: label,
         variant: variant,
         semantic: semantic,
         size: size,
         shape: shape,
         semanticsLabel: semanticsLabel,
         key: key,
       );

  /// Badge/status pill with a leading icon.
  const UiKitBadge.textIcon({
    required String label,
    required IconData icon,
    UiKitBadgeVariant variant = UiKitBadgeVariant.soft,
    UiKitBadgeSemantic semantic = UiKitBadgeSemantic.neutral,
    UiKitBadgeSize size = UiKitBadgeSize.md,
    UiKitBadgeShape shape = UiKitBadgeShape.pill,
    String? semanticsLabel,
    Key? key,
  }) : this(
         label: label,
         icon: icon,
         variant: variant,
         semantic: semantic,
         size: size,
         shape: shape,
         semanticsLabel: semanticsLabel,
         key: key,
       );

  /// Icon-only badge. Use [semanticsLabel] to keep it accessible.
  const UiKitBadge.icon({
    required IconData icon,
    required String semanticsLabel,
    UiKitBadgeVariant variant = UiKitBadgeVariant.soft,
    UiKitBadgeSemantic semantic = UiKitBadgeSemantic.neutral,
    UiKitBadgeSize size = UiKitBadgeSize.md,
    UiKitBadgeShape shape = UiKitBadgeShape.pill,
    Key? key,
  }) : this(
         icon: icon,
         variant: variant,
         semantic: semantic,
         size: size,
         shape: shape,
         semanticsLabel: semanticsLabel,
         key: key,
       );

  final String? label;
  final int? count;
  final int maxCount;
  final IconData? icon;
  final UiKitBadgeVariant variant;
  final UiKitBadgeSemantic semantic;
  final UiKitBadgeSize size;
  final UiKitBadgeShape shape;
  final String? semanticsLabel;

  String? get _text =>
      count == null ? label : (count! > maxCount ? "$maxCount+" : "$count");

  Color _solidColor(UiKitThemeData theme) => switch (semantic) {
    UiKitBadgeSemantic.neutral => theme.textMuted,
    UiKitBadgeSemantic.primary => theme.primary,
    UiKitBadgeSemantic.success => theme.success,
    UiKitBadgeSemantic.warning => theme.warning,
    UiKitBadgeSemantic.error => theme.error,
    UiKitBadgeSemantic.info => theme.info,
  };

  ({Color background, Color foreground, Color? border}) _colors(
    UiKitThemeData theme,
  ) {
    if (variant == UiKitBadgeVariant.solid ||
        variant == UiKitBadgeVariant.dot) {
      return (
        background: _solidColor(theme),
        foreground: theme.textInverse,
        border: null,
      );
    }
    if (variant == UiKitBadgeVariant.outline) {
      return (
        background: Colors.transparent,
        foreground: semantic == UiKitBadgeSemantic.neutral
            ? theme.text
            : _solidColor(theme),
        border: semantic == UiKitBadgeSemantic.neutral
            ? theme.border
            : _solidColor(theme),
      );
    }
    final background = switch (semantic) {
      UiKitBadgeSemantic.neutral => theme.surfaceMuted,
      UiKitBadgeSemantic.primary => theme.primaryBg,
      UiKitBadgeSemantic.success => theme.successBg,
      UiKitBadgeSemantic.warning => theme.warningBg,
      UiKitBadgeSemantic.error => theme.errorBg,
      UiKitBadgeSemantic.info => theme.infoBg,
    };
    return (
      background: background,
      foreground: semantic == UiKitBadgeSemantic.neutral
          ? theme.text
          : _solidColor(theme),
      border: null,
    );
  }

  double get _height => switch (size) {
    UiKitBadgeSize.sm => 20,
    UiKitBadgeSize.md => 24,
    UiKitBadgeSize.lg => 32,
  };
  double get _padding => switch (size) {
    UiKitBadgeSize.sm => 8,
    UiKitBadgeSize.md => 12,
    UiKitBadgeSize.lg => 16,
  };
  TextStyle _textStyle(UiKitThemeData theme) =>
      (size == UiKitBadgeSize.lg ? theme.bodyLarge : theme.bodyMedium).copyWith(
        fontWeight: FontWeight.w600,
        height: 1,
      );

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final colors = _colors(theme);
    if (variant == UiKitBadgeVariant.dot) {
      return Semantics(
        label: semanticsLabel,
        child: SizedBox.square(
          dimension: 8,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.background,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }
    final text = _text;
    return Semantics(
      label: semanticsLabel,
      child: UnconstrainedBox(
        child: Container(
          height: _height,
          padding: EdgeInsets.symmetric(horizontal: _padding),
          decoration: BoxDecoration(
            color: colors.background,
            border: colors.border == null
                ? null
                : Border.all(color: colors.border!),
            borderRadius: BorderRadius.circular(
              shape == UiKitBadgeShape.pill ? theme.radiusFull : theme.radiusSm,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                Icon(icon, size: _iconSize, color: colors.foreground),
              if (icon != null && text != null)
                SizedBox(width: theme.spacingXs),
              if (text != null)
                Text(
                  text,
                  style: _textStyle(theme).copyWith(color: colors.foreground),
                ),
            ],
          ),
        ),
      ),
    );
  }

  double get _iconSize => switch (size) {
    UiKitBadgeSize.sm => 12,
    UiKitBadgeSize.md => 16,
    UiKitBadgeSize.lg => 20,
  };
}
