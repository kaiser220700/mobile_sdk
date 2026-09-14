import "package:flutter/widgets.dart";

import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

/// Determinate progress bar headless — thay `FDeterminateProgress`. Animate
/// khi [value] thay đổi (không animate ở lần mount đầu tiên).
class UiKitDeterminateProgress extends StatefulWidget {
  const UiKitDeterminateProgress({
    required this.value,
    this.height = 8,
    this.trackColor,
    this.fillColor,
    this.borderRadius,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeOut,
    this.semanticsLabel,
    super.key,
  });

  final double value;

  final double height;

  final Color? trackColor;

  final Color? fillColor;

  final BorderRadius? borderRadius;

  final Duration duration;

  final Curve curve;

  final String? semanticsLabel;

  @override
  State<UiKitDeterminateProgress> createState() =>
      _UiKitDeterminateProgressState();
}

class _UiKitDeterminateProgressState extends State<UiKitDeterminateProgress> {
  late double _previousValue = widget.value;

  @override
  void didUpdateWidget(covariant UiKitDeterminateProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final radius = widget.borderRadius ?? BorderRadius.zero;

    return Semantics(
      label: widget.semanticsLabel,
      value: "${(widget.value * 100).round()}%",
      child: ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          height: widget.height,
          child: Stack(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: widget.trackColor ?? theme.border,
                  borderRadius: radius,
                ),
                child: const SizedBox.expand(),
              ),
              TweenAnimationBuilder<double>(
                key: ValueKey(widget.value),
                tween: Tween<double>(begin: _previousValue, end: widget.value),
                duration: widget.duration,
                curve: widget.curve,
                builder: (context, animatedValue, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: animatedValue.clamp(0.0, 1.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: widget.fillColor ?? theme.primary,
                        borderRadius: radius,
                      ),
                      child: SizedBox(height: widget.height),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
