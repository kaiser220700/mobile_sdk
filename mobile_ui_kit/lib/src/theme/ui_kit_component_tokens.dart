import "dart:ui" show lerpDouble;

import "package:material_ui/material_ui.dart";

/// Component dimensions. Per-widget overrides take precedence.
@immutable
class UiKitComponentSizes {
  const UiKitComponentSizes({
    this.rowMd = 56,
    this.rowLg = 72,
    this.chipHeight = 48,
    this.statMinHeight = 0,
    this.dotSize = 8,
    this.controlSm = 32,
    this.controlMd = 44,
    this.controlLg = 52,
    this.iconSm = 16,
    this.iconMd = 20,
    this.iconLg = 24,
    this.otpWidth = 44,
    this.otpHeight = 48,
    this.timelineIndicator = 24,
    this.timelineColumn = 28,
    this.timelineIcon = 15,
  }) : assert(
         rowMd > 0 &&
             rowLg > 0 &&
             chipHeight > 0 &&
             statMinHeight >= 0 &&
             dotSize > 0 &&
             controlSm > 0 &&
             controlMd > 0 &&
             controlLg > 0 &&
             iconSm > 0 &&
             iconMd > 0 &&
             iconLg > 0 &&
             otpWidth > 0 &&
             otpHeight > 0 &&
             timelineIndicator > 0 &&
             timelineColumn > 0 &&
             timelineIcon > 0,
       );

  final double rowMd;
  final double rowLg;
  final double chipHeight;
  final double statMinHeight;
  final double dotSize;
  final double controlSm;
  final double controlMd;
  final double controlLg;
  final double iconSm;
  final double iconMd;
  final double iconLg;
  final double otpWidth;
  final double otpHeight;
  final double timelineIndicator;
  final double timelineColumn;
  final double timelineIcon;

  UiKitComponentSizes copyWith({
    double? rowMd,
    double? rowLg,
    double? chipHeight,
    double? statMinHeight,
    double? dotSize,
    double? controlSm,
    double? controlMd,
    double? controlLg,
    double? iconSm,
    double? iconMd,
    double? iconLg,
    double? otpWidth,
    double? otpHeight,
    double? timelineIndicator,
    double? timelineColumn,
    double? timelineIcon,
  }) => UiKitComponentSizes(
    rowMd: rowMd ?? this.rowMd,
    rowLg: rowLg ?? this.rowLg,
    chipHeight: chipHeight ?? this.chipHeight,
    statMinHeight: statMinHeight ?? this.statMinHeight,
    dotSize: dotSize ?? this.dotSize,
    controlSm: controlSm ?? this.controlSm,
    controlMd: controlMd ?? this.controlMd,
    controlLg: controlLg ?? this.controlLg,
    iconSm: iconSm ?? this.iconSm,
    iconMd: iconMd ?? this.iconMd,
    iconLg: iconLg ?? this.iconLg,
    otpWidth: otpWidth ?? this.otpWidth,
    otpHeight: otpHeight ?? this.otpHeight,
    timelineIndicator: timelineIndicator ?? this.timelineIndicator,
    timelineColumn: timelineColumn ?? this.timelineColumn,
    timelineIcon: timelineIcon ?? this.timelineIcon,
  );

  UiKitComponentSizes lerp(UiKitComponentSizes other, double t) =>
      UiKitComponentSizes(
        rowMd: lerpDouble(rowMd, other.rowMd, t)!,
        rowLg: lerpDouble(rowLg, other.rowLg, t)!,
        chipHeight: lerpDouble(chipHeight, other.chipHeight, t)!,
        statMinHeight: lerpDouble(statMinHeight, other.statMinHeight, t)!,
        dotSize: lerpDouble(dotSize, other.dotSize, t)!,
        controlSm: lerpDouble(controlSm, other.controlSm, t)!,
        controlMd: lerpDouble(controlMd, other.controlMd, t)!,
        controlLg: lerpDouble(controlLg, other.controlLg, t)!,
        iconSm: lerpDouble(iconSm, other.iconSm, t)!,
        iconMd: lerpDouble(iconMd, other.iconMd, t)!,
        iconLg: lerpDouble(iconLg, other.iconLg, t)!,
        otpWidth: lerpDouble(otpWidth, other.otpWidth, t)!,
        otpHeight: lerpDouble(otpHeight, other.otpHeight, t)!,
        timelineIndicator: lerpDouble(
          timelineIndicator,
          other.timelineIndicator,
          t,
        )!,
        timelineColumn: lerpDouble(timelineColumn, other.timelineColumn, t)!,
        timelineIcon: lerpDouble(timelineIcon, other.timelineIcon, t)!,
      );
}

/// Durations and easing for component transitions. Interaction throttling is
/// deliberately separate. Reduced motion always resolves to zero duration.
@immutable
class UiKitMotionTokens {
  const UiKitMotionTokens({
    this.fast = const Duration(milliseconds: 150),
    this.base = const Duration(milliseconds: 200),
    this.slow = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  final Duration fast;
  final Duration base;
  final Duration slow;
  final Curve curve;

  UiKitMotionTokens copyWith({
    Duration? fast,
    Duration? base,
    Duration? slow,
    Curve? curve,
  }) => UiKitMotionTokens(
    fast: fast ?? this.fast,
    base: base ?? this.base,
    slow: slow ?? this.slow,
    curve: curve ?? this.curve,
  );

  UiKitMotionTokens lerp(UiKitMotionTokens other, double t) =>
      UiKitMotionTokens(
        fast: Duration(
          microseconds: lerpDouble(
            fast.inMicroseconds,
            other.fast.inMicroseconds,
            t,
          )!.round(),
        ),
        base: Duration(
          microseconds: lerpDouble(
            base.inMicroseconds,
            other.base.inMicroseconds,
            t,
          )!.round(),
        ),
        slow: Duration(
          microseconds: lerpDouble(
            slow.inMicroseconds,
            other.slow.inMicroseconds,
            t,
          )!.round(),
        ),
        curve: t < .5 ? curve : other.curve,
      );

  Duration resolve(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) || duration.isNegative
      ? Duration.zero
      : duration;
}
