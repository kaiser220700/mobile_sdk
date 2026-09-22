import "package:flutter/material.dart";

/// A host-configurable countdown with a tabular-figure default formatter.
class UiKitCountdown extends StatefulWidget {
  const UiKitCountdown({
    required this.duration,
    this.paused = false,
    this.showTenths = false,
    this.prefix,
    this.suffix,
    this.style,
    this.onTick,
    this.onComplete,
    this.formatter,
    super.key,
  });

  final Duration duration;
  final bool paused;
  final bool showTenths;
  final String? prefix;
  final String? suffix;
  final TextStyle? style;
  final ValueChanged<Duration>? onTick;
  final VoidCallback? onComplete;
  final String Function(Duration remaining)? formatter;

  @override
  State<UiKitCountdown> createState() => _UiKitCountdownState();
}

class _UiKitCountdownState extends State<UiKitCountdown>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _createController();
  }

  @override
  void didUpdateWidget(covariant UiKitCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _createController();
      return;
    }
    if (widget.paused) {
      _controller?.stop();
    } else {
      _controller?.forward();
    }
  }

  void _createController() {
    _controller?.dispose();
    _remaining = widget.duration.isNegative ? Duration.zero : widget.duration;
    if (_remaining == Duration.zero) {
      _controller = null;
      return;
    }
    _controller = AnimationController(vsync: this, duration: _remaining)
      ..addListener(_handleTick)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onComplete?.call();
      });
    if (!widget.paused) _controller!.forward();
  }

  void _handleTick() {
    final controller = _controller;
    if (controller == null) return;
    _remaining = Duration(
      microseconds: (widget.duration.inMicroseconds * (1 - controller.value))
          .round(),
    );
    widget.onTick?.call(_remaining);
    if (mounted) setState(() {});
  }

  String _format() {
    final formatter = widget.formatter;
    if (formatter != null) return formatter(_remaining);
    final hours = _remaining.inHours;
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);
    final base = hours > 0
        ? "${hours.toString().padLeft(2, "0")}:${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}"
        : "${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}";
    if (!widget.showTenths) return base;
    return "$base.${(_remaining.inMilliseconds.remainder(1000) ~/ 100)}";
  }

  @override
  Widget build(BuildContext context) => Text(
    "${widget.prefix ?? ""}${_format()}${widget.suffix ?? ""}",
    style:
        widget.style?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        ) ??
        Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
  );

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
