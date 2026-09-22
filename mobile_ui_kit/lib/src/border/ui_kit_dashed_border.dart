import "package:flutter/widgets.dart";

/// Draws a dashed rounded border around arbitrary host content.
class UiKitDashedBorder extends StatelessWidget {
  const UiKitDashedBorder({
    required this.child,
    required this.color,
    this.strokeWidth = 1,
    this.dashLength = 5,
    this.gapLength = 3,
    this.borderRadius = BorderRadius.zero,
    this.padding = EdgeInsets.zero,
    super.key,
  }) : assert(strokeWidth > 0),
       assert(dashLength > 0),
       assert(gapLength >= 0);

  final Widget child;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final BorderRadius borderRadius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _DashedBorderPainter(
      color: color,
      strokeWidth: strokeWidth,
      dashLength: dashLength,
      gapLength: gapLength,
      borderRadius: borderRadius,
    ),
    child: Padding(padding: padding, child: child),
  );
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
    required this.borderRadius,
  });

  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = strokeWidth / 2;
    final rect =
        Offset(inset, inset) &
        Size(size.width - strokeWidth, size.height - strokeWidth);
    if (rect.width <= 0 || rect.height <= 0) return;
    final path = Path()..addRRect(borderRadius.toRRect(rect));
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      dashLength != oldDelegate.dashLength ||
      gapLength != oldDelegate.gapLength ||
      borderRadius != oldDelegate.borderRadius;
}
