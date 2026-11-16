import "dart:ui" show lerpDouble;

import "package:material_ui/material_ui.dart";

/// Neutral visual defaults for apps that have not registered a theme.
///
/// These defaults keep the package usable on its own without assuming a
/// product brand. Apps can override them globally with [UiKitThemeData].
abstract final class UiKitTheme {
  static const primary = Color(0xFF2563EB);
  static const primaryBg = Color(0xFFEFF6FF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF8FAFC);
  static const text = Color(0xFF0F172A);
  static const textMuted = Color(0xFF475569);
  static const textDisabled = Color(0xFF94A3B8);
  static const textInverse = Color(0xFFFFFFFF);
  static const success = Color(0xFF15803D);
  static const successBg = Color(0xFFF0FDF4);
  static const warning = Color(0xFFB45309);
  static const warningBg = Color(0xFFFFFBEB);
  static const error = Color(0xFFB91C1C);
  static const errorBg = Color(0xFFFEF2F2);
  static const info = Color(0xFF0369A1);
  static const infoBg = Color(0xFFF0F9FF);
  static const border = Color(0xFFE2E8F0);
  static const borderStrong = Color(0xFFCBD5E1);
  static const borderControl = Color(0xFF64748B);
  static const focusRing = Color(0xFF93C5FD);

  static const spacing2xs = 2.0;
  static const spacingXs = 4.0;
  static const spacingSm = 8.0;
  static const spacingMd = 12.0;
  static const spacingLg = 16.0;
  static const spacingXl = 24.0;
  static const radiusSm = 6.0;
  static const radiusMd = 12.0;
  static const radiusLg = 16.0;
  static const radiusXl = 24.0;
  static const radiusFull = 9999.0;
  static const touchMinTarget = 48.0;

  static const body = TextStyle(fontSize: 14, height: 1.5, color: text);
  static const bodyMedium = TextStyle(
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w500,
    color: text,
  );
  static const bodySemibold = TextStyle(
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w600,
    color: text,
  );
  static const bodyLarge = TextStyle(fontSize: 16, height: 1.5, color: text);
  static const caption = TextStyle(fontSize: 12, height: 1.5, color: textMuted);
  static const button = TextStyle(
    fontSize: 14,
    height: 1,
    fontWeight: FontWeight.w600,
  );
  static const buttonLarge = TextStyle(
    fontSize: 16,
    height: 1,
    fontWeight: FontWeight.w600,
  );
  static const title = TextStyle(
    fontSize: 24,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: text,
  );

  /// Complete light theme synchronizing Material and kit semantic tokens.
  static ThemeData material({UiKitThemeData tokens = UiKitThemeData.defaults}) {
    final scheme = ColorScheme.light(
      primary: tokens.primary,
      onPrimary: tokens.textInverse,
      primaryContainer: tokens.primaryBg,
      onPrimaryContainer: tokens.text,
      secondary: tokens.primary,
      onSecondary: tokens.textInverse,
      secondaryContainer: tokens.primaryBg,
      onSecondaryContainer: tokens.primary,
      error: tokens.error,
      onError: tokens.textInverse,
      errorContainer: tokens.errorBg,
      onErrorContainer: tokens.error,
      surface: tokens.surface,
      onSurface: tokens.text,
      onSurfaceVariant: tokens.textMuted,
      outline: tokens.borderControl,
      outlineVariant: tokens.border,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    return base.copyWith(
      scaffoldBackgroundColor: tokens.surfaceMuted,
      extensions: [tokens],
      textTheme: base.textTheme.copyWith(
        bodyMedium: tokens.body,
        bodyLarge: tokens.bodyLarge,
        bodySmall: tokens.caption,
        titleLarge: tokens.title,
        titleMedium: tokens.bodySemibold,
        labelLarge: tokens.button.copyWith(color: tokens.text),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.surface,
        foregroundColor: tokens.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.surface,
        contentPadding: EdgeInsets.all(tokens.spacingLg),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          borderSide: BorderSide(color: tokens.borderControl),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          borderSide: BorderSide(color: tokens.primary, width: 2),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(tokens.radiusXl),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: tokens.border,
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Reads the app-provided UI Kit theme, falling back to the package
  /// defaults when the app has not registered one.
  static UiKitThemeData of(BuildContext context) =>
      Theme.of(context).extension<UiKitThemeData>() ?? UiKitThemeData.defaults;
}

/// Runtime theme for the UI Kit.
///
/// Register this extension in the host app's [ThemeData] to override the
/// package defaults globally:
///
/// ```dart
/// ThemeData(
///   extensions: [
///     UiKitThemeData.fromDefaults(primary: Colors.indigo),
///   ],
/// )
/// ```
///
/// The main constructor requires a complete token set so a partially-defined
/// theme cannot silently fall back to package colors. For intentional partial
/// overrides, use [UiKitThemeData.fromDefaults].
@immutable
class UiKitThemeData extends ThemeExtension<UiKitThemeData> {
  const UiKitThemeData({
    required this.primary,
    required this.primaryBg,
    required this.surface,
    required this.surfaceMuted,
    required this.text,
    required this.textMuted,
    required this.textDisabled,
    required this.textInverse,
    required this.success,
    required this.successBg,
    required this.warning,
    required this.warningBg,
    required this.error,
    required this.errorBg,
    required this.info,
    required this.infoBg,
    required this.border,
    required this.borderStrong,
    required this.borderControl,
    required this.focusRing,
    required this.spacing2xs,
    required this.spacingXs,
    required this.spacingSm,
    required this.spacingMd,
    required this.spacingLg,
    required this.spacingXl,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusXl,
    required this.radiusFull,
    required this.touchMinTarget,
    required this.body,
    required this.bodyMedium,
    required this.bodySemibold,
    required this.bodyLarge,
    required this.caption,
    required this.button,
    required this.buttonLarge,
    required this.title,
  });

  /// Creates the package-neutral complete default theme.
  const UiKitThemeData._defaults()
    : this(
        primary: UiKitTheme.primary,
        primaryBg: UiKitTheme.primaryBg,
        surface: UiKitTheme.surface,
        surfaceMuted: UiKitTheme.surfaceMuted,
        text: UiKitTheme.text,
        textMuted: UiKitTheme.textMuted,
        textDisabled: UiKitTheme.textDisabled,
        textInverse: UiKitTheme.textInverse,
        success: UiKitTheme.success,
        successBg: UiKitTheme.successBg,
        warning: UiKitTheme.warning,
        warningBg: UiKitTheme.warningBg,
        error: UiKitTheme.error,
        errorBg: UiKitTheme.errorBg,
        info: UiKitTheme.info,
        infoBg: UiKitTheme.infoBg,
        border: UiKitTheme.border,
        borderStrong: UiKitTheme.borderStrong,
        borderControl: UiKitTheme.borderControl,
        focusRing: UiKitTheme.focusRing,
        spacing2xs: UiKitTheme.spacing2xs,
        spacingXs: UiKitTheme.spacingXs,
        spacingSm: UiKitTheme.spacingSm,
        spacingMd: UiKitTheme.spacingMd,
        spacingLg: UiKitTheme.spacingLg,
        spacingXl: UiKitTheme.spacingXl,
        radiusSm: UiKitTheme.radiusSm,
        radiusMd: UiKitTheme.radiusMd,
        radiusLg: UiKitTheme.radiusLg,
        radiusXl: UiKitTheme.radiusXl,
        radiusFull: UiKitTheme.radiusFull,
        touchMinTarget: UiKitTheme.touchMinTarget,
        body: UiKitTheme.body,
        bodyMedium: UiKitTheme.bodyMedium,
        bodySemibold: UiKitTheme.bodySemibold,
        bodyLarge: UiKitTheme.bodyLarge,
        caption: UiKitTheme.caption,
        button: UiKitTheme.button,
        buttonLarge: UiKitTheme.buttonLarge,
        title: UiKitTheme.title,
      );

  /// Creates a theme by explicitly overriding selected package defaults.
  ///
  /// This is the opt-in escape hatch for apps that do not need to define the
  /// complete token set required by [UiKitThemeData].
  const UiKitThemeData.fromDefaults({
    Color primary = UiKitTheme.primary,
    Color primaryBg = UiKitTheme.primaryBg,
    Color surface = UiKitTheme.surface,
    Color surfaceMuted = UiKitTheme.surfaceMuted,
    Color text = UiKitTheme.text,
    Color textMuted = UiKitTheme.textMuted,
    Color textDisabled = UiKitTheme.textDisabled,
    Color textInverse = UiKitTheme.textInverse,
    Color success = UiKitTheme.success,
    Color successBg = UiKitTheme.successBg,
    Color warning = UiKitTheme.warning,
    Color warningBg = UiKitTheme.warningBg,
    Color error = UiKitTheme.error,
    Color errorBg = UiKitTheme.errorBg,
    Color info = UiKitTheme.info,
    Color infoBg = UiKitTheme.infoBg,
    Color border = UiKitTheme.border,
    Color borderStrong = UiKitTheme.borderStrong,
    Color borderControl = UiKitTheme.borderControl,
    Color focusRing = UiKitTheme.focusRing,
    double spacing2xs = UiKitTheme.spacing2xs,
    double spacingXs = UiKitTheme.spacingXs,
    double spacingSm = UiKitTheme.spacingSm,
    double spacingMd = UiKitTheme.spacingMd,
    double spacingLg = UiKitTheme.spacingLg,
    double spacingXl = UiKitTheme.spacingXl,
    double radiusSm = UiKitTheme.radiusSm,
    double radiusMd = UiKitTheme.radiusMd,
    double radiusLg = UiKitTheme.radiusLg,
    double radiusXl = UiKitTheme.radiusXl,
    double radiusFull = UiKitTheme.radiusFull,
    double touchMinTarget = UiKitTheme.touchMinTarget,
    TextStyle body = UiKitTheme.body,
    TextStyle bodyMedium = UiKitTheme.bodyMedium,
    TextStyle bodySemibold = UiKitTheme.bodySemibold,
    TextStyle bodyLarge = UiKitTheme.bodyLarge,
    TextStyle caption = UiKitTheme.caption,
    TextStyle button = UiKitTheme.button,
    TextStyle buttonLarge = UiKitTheme.buttonLarge,
    TextStyle title = UiKitTheme.title,
  }) : this(
         primary: primary,
         primaryBg: primaryBg,
         surface: surface,
         surfaceMuted: surfaceMuted,
         text: text,
         textMuted: textMuted,
         textDisabled: textDisabled,
         textInverse: textInverse,
         success: success,
         successBg: successBg,
         warning: warning,
         warningBg: warningBg,
         error: error,
         errorBg: errorBg,
         info: info,
         infoBg: infoBg,
         border: border,
         borderStrong: borderStrong,
         borderControl: borderControl,
         focusRing: focusRing,
         spacing2xs: spacing2xs,
         spacingXs: spacingXs,
         spacingSm: spacingSm,
         spacingMd: spacingMd,
         spacingLg: spacingLg,
         spacingXl: spacingXl,
         radiusSm: radiusSm,
         radiusMd: radiusMd,
         radiusLg: radiusLg,
         radiusXl: radiusXl,
         radiusFull: radiusFull,
         touchMinTarget: touchMinTarget,
         body: body,
         bodyMedium: bodyMedium,
         bodySemibold: bodySemibold,
         bodyLarge: bodyLarge,
         caption: caption,
         button: button,
         buttonLarge: buttonLarge,
         title: title,
       );

  static const defaults = UiKitThemeData._defaults();

  final Color primary;
  final Color primaryBg;
  final Color surface;
  final Color surfaceMuted;
  final Color text;
  final Color textMuted;
  final Color textDisabled;
  final Color textInverse;
  final Color success;
  final Color successBg;
  final Color warning;
  final Color warningBg;
  final Color error;
  final Color errorBg;
  final Color info;
  final Color infoBg;
  final Color border;
  final Color borderStrong;
  final Color borderControl;
  final Color focusRing;

  final double spacing2xs;
  final double spacingXs;
  final double spacingSm;
  final double spacingMd;
  final double spacingLg;
  final double spacingXl;
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusXl;
  final double radiusFull;
  final double touchMinTarget;

  final TextStyle body;
  final TextStyle bodyMedium;
  final TextStyle bodySemibold;
  final TextStyle bodyLarge;
  final TextStyle caption;
  final TextStyle button;
  final TextStyle buttonLarge;
  final TextStyle title;

  @override
  UiKitThemeData copyWith({
    Color? primary,
    Color? primaryBg,
    Color? surface,
    Color? surfaceMuted,
    Color? text,
    Color? textMuted,
    Color? textDisabled,
    Color? textInverse,
    Color? success,
    Color? successBg,
    Color? warning,
    Color? warningBg,
    Color? error,
    Color? errorBg,
    Color? info,
    Color? infoBg,
    Color? border,
    Color? borderStrong,
    Color? borderControl,
    Color? focusRing,
    double? spacing2xs,
    double? spacingXs,
    double? spacingSm,
    double? spacingMd,
    double? spacingLg,
    double? spacingXl,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusXl,
    double? radiusFull,
    double? touchMinTarget,
    TextStyle? body,
    TextStyle? bodyMedium,
    TextStyle? bodySemibold,
    TextStyle? bodyLarge,
    TextStyle? caption,
    TextStyle? button,
    TextStyle? buttonLarge,
    TextStyle? title,
  }) => UiKitThemeData(
    primary: primary ?? this.primary,
    primaryBg: primaryBg ?? this.primaryBg,
    surface: surface ?? this.surface,
    surfaceMuted: surfaceMuted ?? this.surfaceMuted,
    text: text ?? this.text,
    textMuted: textMuted ?? this.textMuted,
    textDisabled: textDisabled ?? this.textDisabled,
    textInverse: textInverse ?? this.textInverse,
    success: success ?? this.success,
    successBg: successBg ?? this.successBg,
    warning: warning ?? this.warning,
    warningBg: warningBg ?? this.warningBg,
    error: error ?? this.error,
    errorBg: errorBg ?? this.errorBg,
    info: info ?? this.info,
    infoBg: infoBg ?? this.infoBg,
    border: border ?? this.border,
    borderStrong: borderStrong ?? this.borderStrong,
    borderControl: borderControl ?? this.borderControl,
    focusRing: focusRing ?? this.focusRing,
    spacing2xs: spacing2xs ?? this.spacing2xs,
    spacingXs: spacingXs ?? this.spacingXs,
    spacingSm: spacingSm ?? this.spacingSm,
    spacingMd: spacingMd ?? this.spacingMd,
    spacingLg: spacingLg ?? this.spacingLg,
    spacingXl: spacingXl ?? this.spacingXl,
    radiusSm: radiusSm ?? this.radiusSm,
    radiusMd: radiusMd ?? this.radiusMd,
    radiusLg: radiusLg ?? this.radiusLg,
    radiusXl: radiusXl ?? this.radiusXl,
    radiusFull: radiusFull ?? this.radiusFull,
    touchMinTarget: touchMinTarget ?? this.touchMinTarget,
    body: body ?? this.body,
    bodyMedium: bodyMedium ?? this.bodyMedium,
    bodySemibold: bodySemibold ?? this.bodySemibold,
    bodyLarge: bodyLarge ?? this.bodyLarge,
    caption: caption ?? this.caption,
    button: button ?? this.button,
    buttonLarge: buttonLarge ?? this.buttonLarge,
    title: title ?? this.title,
  );

  @override
  UiKitThemeData lerp(covariant UiKitThemeData? other, double t) {
    if (other == null) return this;
    return UiKitThemeData(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryBg: Color.lerp(primaryBg, other.primaryBg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      text: Color.lerp(text, other.text, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      success: Color.lerp(success, other.success, t)!,
      successBg: Color.lerp(successBg, other.successBg, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorBg: Color.lerp(errorBg, other.errorBg, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoBg: Color.lerp(infoBg, other.infoBg, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      borderControl: Color.lerp(borderControl, other.borderControl, t)!,
      focusRing: Color.lerp(focusRing, other.focusRing, t)!,
      spacing2xs: lerpDouble(spacing2xs, other.spacing2xs, t)!,
      spacingXs: lerpDouble(spacingXs, other.spacingXs, t)!,
      spacingSm: lerpDouble(spacingSm, other.spacingSm, t)!,
      spacingMd: lerpDouble(spacingMd, other.spacingMd, t)!,
      spacingLg: lerpDouble(spacingLg, other.spacingLg, t)!,
      spacingXl: lerpDouble(spacingXl, other.spacingXl, t)!,
      radiusSm: lerpDouble(radiusSm, other.radiusSm, t)!,
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t)!,
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t)!,
      radiusXl: lerpDouble(radiusXl, other.radiusXl, t)!,
      radiusFull: lerpDouble(radiusFull, other.radiusFull, t)!,
      touchMinTarget: lerpDouble(touchMinTarget, other.touchMinTarget, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      bodySemibold: TextStyle.lerp(bodySemibold, other.bodySemibold, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      button: TextStyle.lerp(button, other.button, t)!,
      buttonLarge: TextStyle.lerp(buttonLarge, other.buttonLarge, t)!,
      title: TextStyle.lerp(title, other.title, t)!,
    );
  }
}
