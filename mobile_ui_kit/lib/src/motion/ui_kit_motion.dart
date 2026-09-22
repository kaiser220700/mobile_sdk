import "dart:math" as math;

import "package:flutter/widgets.dart";

/// Direction used by [UiKitFadeMotion] when its child enters the viewport.
enum UiKitMotionDirection { up, down, left, right }

/// A small, dependency-free fade and slide transition for UI Kit content.
///
/// Set [shown] to false to play the exit transition while keeping the child in
/// the tree. This makes it suitable for menus and inline status content where
/// the host owns visibility state.
class UiKitFadeMotion extends StatefulWidget {
  const UiKitFadeMotion({
    required this.child,
    this.shown = true,
    this.direction = UiKitMotionDirection.up,
    this.distance = 12,
    this.duration = const Duration(milliseconds: 180),
    this.curve = Curves.easeOutCubic,
    super.key,
  }) : assert(distance >= 0);

  final Widget child;
  final bool shown;
  final UiKitMotionDirection direction;
  final double distance;
  final Duration duration;
  final Curve curve;

  @override
  State<UiKitFadeMotion> createState() => _UiKitFadeMotionState();
}

class _UiKitFadeMotionState extends State<UiKitFadeMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.shown ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant UiKitFadeMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.shown != widget.shown) {
      widget.shown ? _controller.forward() : _controller.reverse();
    }
  }

  Offset _hiddenOffset() => switch (widget.direction) {
    UiKitMotionDirection.up => Offset(0, widget.distance),
    UiKitMotionDirection.down => Offset(0, -widget.distance),
    UiKitMotionDirection.left => Offset(widget.distance, 0),
    UiKitMotionDirection.right => Offset(-widget.distance, 0),
  };

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _controller, curve: widget.curve);
    return FadeTransition(
      opacity: curved,
      child: AnimatedBuilder(
        animation: curved,
        child: widget.child,
        builder: (context, child) => Transform.translate(
          offset: Offset.lerp(_hiddenOffset(), Offset.zero, curved.value)!,
          child: child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Applies a gentle repeating scale animation, useful for a waiting affordance
/// or an emphasized avatar. Disable [enabled] to render the child unchanged.
class UiKitBouncingMotion extends StatefulWidget {
  const UiKitBouncingMotion({
    required this.child,
    this.enabled = true,
    this.minScale = .96,
    this.maxScale = 1.04,
    this.duration = const Duration(milliseconds: 700),
    super.key,
  }) : assert(minScale > 0),
       assert(maxScale >= minScale);

  final Widget child;
  final bool enabled;
  final double minScale;
  final double maxScale;
  final Duration duration;

  @override
  State<UiKitBouncingMotion> createState() => _UiKitBouncingMotionState();
}

class _UiKitBouncingMotionState extends State<UiKitBouncingMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _sync();
  }

  @override
  void didUpdateWidget(covariant UiKitBouncingMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration)
      _controller.duration = widget.duration;
    if (oldWidget.enabled != widget.enabled) _sync();
  }

  void _sync() {
    if (widget.enabled) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) => Transform.scale(
        scale:
            widget.minScale +
            (widget.maxScale - widget.minScale) *
                Curves.easeInOut.transform(_controller.value),
        child: child,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// An animated highlight sweep. The host supplies colors so this primitive
/// follows its own design tokens rather than carrying a fixed palette.
class UiKitShimmer extends StatefulWidget {
  const UiKitShimmer({
    required this.child,
    required this.baseColor,
    required this.highlightColor,
    this.enabled = true,
    this.duration = const Duration(milliseconds: 1200),
    super.key,
  });

  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final bool enabled;
  final Duration duration;

  @override
  State<UiKitShimmer> createState() => _UiKitShimmerState();
}

class _UiKitShimmerState extends State<UiKitShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _sync();
  }

  @override
  void didUpdateWidget(covariant UiKitShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration)
      _controller.duration = widget.duration;
    if (oldWidget.enabled != widget.enabled) _sync();
  }

  void _sync() {
    if (widget.enabled) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final begin = Alignment(-1.5 + _controller.value * 3, 0);
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: begin,
            end: Alignment(begin.x + 1, 0),
            colors: [widget.baseColor, widget.highlightColor, widget.baseColor],
            stops: const [.25, .5, .75],
          ).createShader(bounds),
          child: child,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// A digit-like counter transition for values that change in place.
class UiKitFlipCounter extends StatelessWidget {
  const UiKitFlipCounter({
    required this.value,
    this.prefix = "",
    this.suffix = "",
    this.style,
    this.duration = const Duration(milliseconds: 220),
    super.key,
  });

  final Object value;
  final String prefix;
  final String suffix;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final text = "$prefix$value$suffix";
    return Semantics(
      liveRegion: true,
      label: text,
      child: AnimatedSwitcher(
        duration: duration,
        transitionBuilder: (child, animation) => AnimatedBuilder(
          animation: animation,
          child: child,
          builder: (context, child) {
            final angle = (1 - animation.value) * math.pi / 2;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, .001)
                ..rotateX(angle),
              child: child,
            );
          },
        ),
        child: Text(text, key: ValueKey(text), style: style),
      ),
    );
  }
}
