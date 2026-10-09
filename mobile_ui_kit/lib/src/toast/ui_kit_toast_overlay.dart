import "dart:async";

import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/toast/ui_kit_toast_queue.dart";
import "package:mobile_ui_kit/src/toast/ui_kit_toast_surface.dart";

/// Widget mount 1 lần (thường ở root, cạnh `child` chính của app) — lắng
/// nghe [queue], hiển thị toast tuần tự và tự advance khi `duration` hết.
///
/// Legacy [UiKitToastRequest.builder] requests preserve their app-owned
/// visual and interaction. [UiKitToastRequest.content] requests receive the
/// SDK-owned surface, safe area, motion, tap and swipe-to-dismiss behavior.
class UiKitToastOverlay extends StatefulWidget {
  const UiKitToastOverlay({
    required this.queue,
    required this.child,
    this.alignment = Alignment.topCenter,
    this.animationDuration = const Duration(milliseconds: 200),
    super.key,
  });

  final UiKitToastQueue queue;
  final Widget child;
  final Alignment alignment;
  final Duration animationDuration;

  @override
  State<UiKitToastOverlay> createState() => _UiKitToastOverlayState();
}

class _UiKitToastOverlayState extends State<UiKitToastOverlay> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    widget.queue.addListener(_handleChange);
    _scheduleAutoDismiss();
  }

  void _handleChange() {
    _scheduleAutoDismiss();
    setState(() {});
  }

  void _scheduleAutoDismiss() {
    _timer?.cancel();
    final request = widget.queue.current;
    if (request == null || request.duration == Duration.zero) return;
    _timer = Timer(request.duration, widget.queue.dismissCurrent);
  }

  @override
  void didUpdateWidget(covariant UiKitToastOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.queue != widget.queue) {
      oldWidget.queue.removeListener(_handleChange);
      widget.queue.addListener(_handleChange);
      _scheduleAutoDismiss();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.queue.removeListener(_handleChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.queue.current;

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Align(
          alignment: widget.alignment,
          child: IgnorePointer(
            ignoring: request == null,
            child: AnimatedSwitcher(
              duration: widget.animationDuration,
              child: request == null
                  ? const SizedBox.shrink(key: ValueKey("ui-kit-toast-empty"))
                  : KeyedSubtree(
                      key: ValueKey(request),
                      child: request.content != null
                          ? UiKitToastSurface(
                              request: request,
                              onDismiss: widget.queue.dismissCurrent,
                              animationDuration: widget.animationDuration,
                            )
                          : Builder(builder: request.builder),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
