import "dart:async";

import "package:flutter/material.dart";

/// Animation "vào danh sách" cho từng item — fade + slide-in, tự stagger
/// theo [index] (item càng xa đầu danh sách càng trễ, tối đa
/// [maxStaggeredItems] nấc). Headless hoá lại đúng cơ chế của
/// `AppListEntrance` (app-layer): mỗi item tự quản 1 `AnimationController`
/// riêng, không dùng `AnimatedList`.
class UiKitListEntrance extends StatefulWidget {
  const UiKitListEntrance({
    required this.child,
    required this.index,
    this.shouldAnimate = true,
    this.onEntranceStarted,
    this.duration = const Duration(milliseconds: 280),
    this.staggerDelay = const Duration(milliseconds: 45),
    this.maxStaggeredItems = 8,
    this.curve = Curves.easeOutCubic,
    this.beginOffset = const Offset(-.12, 0),
    super.key,
  });

  final Widget child;
  final int index;
  final bool shouldAnimate;
  final VoidCallback? onEntranceStarted;
  final Duration duration;
  final Duration staggerDelay;
  final int maxStaggeredItems;
  final Curve curve;
  final Offset beginOffset;

  @override
  State<UiKitListEntrance> createState() => _UiKitListEntranceState();
}

class _UiKitListEntranceState extends State<UiKitListEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: widget.duration,
    vsync: this,
  );
  Timer? _timer;

  bool get _shouldPlay {
    final reducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return widget.shouldAnimate && !reducedMotion;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  void _start() {
    if (!mounted) return;
    if (!_shouldPlay) {
      _controller.value = 1;
      return;
    }
    widget.onEntranceStarted?.call();
    _controller.value = 0;
    final staggeredIndex = widget.index.clamp(0, widget.maxStaggeredItems);
    _timer = Timer(widget.staggerDelay * staggeredIndex, () {
      if (mounted) unawaited(_controller.forward());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _controller, curve: widget.curve);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: widget.beginOffset,
          end: Offset.zero,
        ).animate(curved),
        child: widget.child,
      ),
    );
  }
}
