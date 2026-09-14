import "package:flutter/material.dart";

/// Chrome-only visual constants for the SDK's default monochrome theme.
/// [MobileDevToolConfiguration.accentColor] still overrides the accent at
/// runtime — these are the fallback values used when the host does not brand
/// the SDK.
class MobileDevToolTheme {
  const MobileDevToolTheme._();

  /// Default accent and primary control color.
  static const Color primary = Colors.black;

  /// Default focus/selection ring.
  static const Color focusRing = Colors.black;

  /// Default background for every devtool surface.
  static const Color surface = Colors.white;

  /// White foreground used on black controls and as a panel separation ring.
  static const Color textInverse = Colors.white;

  /// Light neutral border and bottom-sheet drag handle color.
  static const Color borderStrong = Color(0xFFD6D6D6);

  /// Black scrim used behind modal surfaces.
  static const Color scrim = Colors.black;

  /// Fuzz Tap scrim: a light 25% black wash that keeps the app visible while
  /// making the floating panel easier to read.
  static const Color fuzzOverlayScrim = Color(0x40000000);

  /// Secondary text that remains readable on white.
  static const Color textMuted = Color(0xFF666666);

  /// Builds a light theme scoped to SDK-owned UI, independent of the host's
  /// light/dark theme. The host's typography and shape settings are retained.
  static ThemeData data(BuildContext context, {Color? accentColor}) {
    final hostTheme = Theme.of(context);
    final accent = accentColor ?? primary;
    final colorScheme = hostTheme.colorScheme.copyWith(
      brightness: Brightness.light,
      primary: accent,
      onPrimary: Colors.white,
      primaryContainer: Colors.white,
      onPrimaryContainer: Colors.black,
      secondary: accent,
      onSecondary: Colors.white,
      secondaryContainer: Colors.white,
      onSecondaryContainer: Colors.black,
      surface: surface,
      onSurface: Colors.black,
      surfaceTint: Colors.transparent,
      surfaceContainerHighest: const Color(0xFFF2F2F2),
      onSurfaceVariant: Colors.black,
      outline: borderStrong,
      error: const Color(0xFFB3261E),
      onError: Colors.white,
    );

    return hostTheme.copyWith(
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      canvasColor: surface,
      cardColor: surface,
      dialogTheme: hostTheme.dialogTheme.copyWith(backgroundColor: surface),
      popupMenuTheme: hostTheme.popupMenuTheme.copyWith(
        color: surface,
        surfaceTintColor: Colors.transparent,
      ),
      dividerColor: borderStrong,
      hintColor: textMuted,
      disabledColor: const Color(0xFF999999),
      textTheme: hostTheme.textTheme.apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
        decorationColor: Colors.black,
      ),
      iconTheme: const IconThemeData(color: Colors.black),
      applyElevationOverlayColor: false,
    );
  }

  /// Matches `AppSizes.radiusXl` — bottom sheet top corners.
  static const double radiusXl = 20;

  /// Matches `AppSizes.radiusLg` — floating toolbar/panel corners.
  static const double radiusLg = 12;

  /// Matches `AppSizes.radiusMd`.
  static const double radiusMd = 8;

  /// Matches `AppSizes.radiusFull` — drag handle pill.
  static const double radiusFull = 9999;

  /// Soft black shadows used behind the launcher bubble.
  static const List<BoxShadow> bubbleShadow = [
    BoxShadow(color: Color(0x26000000), offset: Offset(0, 4), blurRadius: 8),
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 2), blurRadius: 4),
  ];

  /// `showModalBottomSheet` params matching `AppBottomSheet.show` chrome —
  /// transparent scaffold background + scrim, so the actual Material surface
  /// (rounded top corners) is drawn by the builder itself via [surfaceRadius].
  static const Color bottomSheetBarrierColor = Color(
    0x66000000,
  ); // scrim @ .4 alpha

  static const BorderRadius surfaceRadius = BorderRadius.vertical(
    top: Radius.circular(radiusXl),
  );
}
