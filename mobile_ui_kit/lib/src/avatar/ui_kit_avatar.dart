import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

enum UiKitAvatarSize { xs, sm, md, lg, xl }

enum UiKitAvatarShape { circle, rounded }

enum UiKitAvatarStatus { online, offline, away, busy }

class UiKitAvatar extends StatelessWidget {
  const UiKitAvatar({
    this.imageUrl,
    this.initials,
    this.icon = Icons.person,
    this.size = UiKitAvatarSize.md,
    this.shape = UiKitAvatarShape.circle,
    this.status,
    this.ring = false,
    this.semanticsLabel,
    this.customSize,
    this.fontSize,
    this.iconSize,
    this.statusSize,
    this.roundedRadius,
    this.backgroundColor,
    this.initialsColor,
    this.iconColor,
    this.statusColor,
    this.ringColor,
    this.ringWidth = 2,
    this.statusBorderColor,
    this.statusBorderWidth = 2,
    super.key,
  }) : assert(
         customSize == null || customSize > 0,
         "customSize must be positive.",
       ),
       assert(ringWidth > 0 && statusBorderWidth > 0);

  final String? imageUrl;
  final String? initials;
  final IconData icon;
  final UiKitAvatarSize size;
  final UiKitAvatarShape shape;
  final UiKitAvatarStatus? status;
  final bool ring;
  final String? semanticsLabel;
  final double? customSize;
  final double? fontSize;
  final double? iconSize;
  final double? statusSize;
  final double? roundedRadius;
  final Color? backgroundColor;
  final Color? initialsColor;
  final Color? iconColor;
  final Color? statusColor;
  final Color? ringColor;
  final double ringWidth;
  final Color? statusBorderColor;
  final double statusBorderWidth;

  double get _size =>
      customSize ??
      switch (size) {
        UiKitAvatarSize.xs => 20,
        UiKitAvatarSize.sm => 32,
        UiKitAvatarSize.md => 40,
        UiKitAvatarSize.lg => 56,
        UiKitAvatarSize.xl => 80,
      };
  double get _fontSize =>
      fontSize ??
      switch (size) {
        UiKitAvatarSize.xs => 10,
        UiKitAvatarSize.sm => 14,
        UiKitAvatarSize.md => 16,
        UiKitAvatarSize.lg => 20,
        UiKitAvatarSize.xl => 28,
      };
  double get _iconSize =>
      iconSize ??
      switch (size) {
        UiKitAvatarSize.xs => 12,
        UiKitAvatarSize.sm => 16,
        UiKitAvatarSize.md => 20,
        UiKitAvatarSize.lg => 24,
        UiKitAvatarSize.xl => 40,
      };
  double get _statusSize =>
      statusSize ??
      switch (size) {
        UiKitAvatarSize.xs => 6,
        UiKitAvatarSize.sm => 8,
        UiKitAvatarSize.md => 10,
        UiKitAvatarSize.lg => 14,
        UiKitAvatarSize.xl => 20,
      };
  Color _statusColor(UiKitThemeData theme) =>
      statusColor ??
      switch (status!) {
        UiKitAvatarStatus.online => theme.success,
        UiKitAvatarStatus.offline => theme.textMuted,
        UiKitAvatarStatus.away => theme.warning,
        UiKitAvatarStatus.busy => theme.error,
      };

  BorderRadius _radius(UiKitThemeData theme) => shape == UiKitAvatarShape.circle
      ? BorderRadius.circular(_size / 2)
      : BorderRadius.circular(roundedRadius ?? theme.radiusLg);

  Widget _fallback(UiKitThemeData theme) => DecoratedBox(
    decoration: BoxDecoration(
      color:
          backgroundColor ??
          (initials == null ? theme.surfaceMuted : theme.primaryBg),
    ),
    child: Center(
      child: initials == null
          ? Icon(icon, size: _iconSize, color: iconColor ?? theme.textMuted)
          : Text(
              initials!,
              style: TextStyle(
                fontSize: _fontSize,
                fontWeight: FontWeight.w600,
                color: initialsColor ?? theme.primary,
              ),
            ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final core = ClipRRect(
      borderRadius: _radius(theme),
      child: SizedBox.square(
        dimension: _size,
        child: imageUrl == null
            ? _fallback(theme)
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallback(theme),
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : _fallback(theme),
              ),
      ),
    );
    Widget result = ring
        ? Container(
            padding: EdgeInsets.all(ringWidth),
            decoration: BoxDecoration(
              shape: shape == UiKitAvatarShape.circle
                  ? BoxShape.circle
                  : BoxShape.rectangle,
              borderRadius: shape == UiKitAvatarShape.circle
                  ? null
                  : BorderRadius.circular(
                      (roundedRadius ?? theme.radiusLg) + ringWidth,
                    ),
              border: Border.all(
                color: ringColor ?? theme.primary,
                width: ringWidth,
              ),
            ),
            child: core,
          )
        : core;
    if (status != null) {
      result = Stack(
        clipBehavior: Clip.none,
        children: [
          result,
          Positioned(
            bottom: -(_statusSize * .15),
            right: -(_statusSize * .15),
            child: Container(
              width: _statusSize,
              height: _statusSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _statusColor(theme),
                border: Border.all(
                  color: statusBorderColor ?? theme.surface,
                  width: statusBorderWidth,
                ),
              ),
            ),
          ),
        ],
      );
    }
    return Semantics(label: semanticsLabel, image: true, child: result);
  }
}
