import "package:flutter/widgets.dart";

/// A `GestureDetector` that registers both `onPanUpdate` and `onTap` almost
/// always swallows the tap: `PanGestureRecognizer` and `TapGestureRecognizer`
/// both enter the gesture arena, and pan wins as soon as the finger moves
/// past `kTouchSlop` — which a touch on a small bubble almost always does.
/// The result: a draggable bubble needs several taps before it opens.
///
/// This registers ONLY a pan recognizer, then classifies the gesture itself:
/// total travel under [_tapSlop] on release counts as a tap. A single
/// recognizer never competes for the arena, so this fixes it.
class MobileDevToolDragTapDetector extends StatefulWidget {
  const MobileDevToolDragTapDetector({
    required this.child,
    this.onTap,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDragStart;
  final ValueChanged<Offset>? onDragUpdate;
  final VoidCallback? onDragEnd;

  @override
  State<MobileDevToolDragTapDetector> createState() =>
      _MobileDevToolDragTapDetectorState();
}

class _MobileDevToolDragTapDetectorState
    extends State<MobileDevToolDragTapDetector> {
  /// Smaller than `kTouchSlop` (18) so real drags stay responsive, but wide
  /// enough to absorb finger tremor on tap.
  static const double _tapSlop = 8;

  double _travelled = 0;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onPanDown: (_) => _travelled = 0,
    onPanStart: (_) => widget.onDragStart?.call(),
    onPanUpdate: (details) {
      _travelled += details.delta.distance;
      widget.onDragUpdate?.call(details.delta);
    },
    onPanEnd: (_) {
      widget.onDragEnd?.call();
      if (_travelled <= _tapSlop) widget.onTap?.call();
    },
    onPanCancel: () => _travelled = 0,
    child: widget.child,
  );
}
