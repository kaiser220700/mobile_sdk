import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";
import "package:mobile_ui_kit/src/toast/ui_kit_toast_queue.dart";
import "package:mobile_ui_kit/src/toast/ui_kit_toast_type.dart";

/// The SDK-owned presentation for [UiKitToastRequest.content].
///
/// It includes safe-area placement, tap semantics, and a drag-to-dismiss
/// interaction. Swipe up, left or right dismisses at 48 logical pixels or a
/// 300 logical-pixels-per-second fling; a shorter drag or downward swipe
/// returns to its original position.
class UiKitToastSurface extends StatefulWidget {
  UiKitToastSurface({
    required this.request,
    required this.onDismiss,
    this.animationDuration = const Duration(milliseconds: 200),
    super.key,
  }) : assert(request.content != null);

  final UiKitToastRequest request;
  final VoidCallback onDismiss;
  final Duration animationDuration;

  @override
  State<UiKitToastSurface> createState() => _UiKitToastSurfaceState();
}

class _UiKitToastSurfaceState extends State<UiKitToastSurface>
    with TickerProviderStateMixin {
  static const _dismissDistance = 48.0;
  static const _dismissVelocity = 300.0;
  static const _axisActivationDistance = 12.0;

  late final AnimationController _returnController = AnimationController(
    vsync: this,
    duration: widget.animationDuration,
  )..addListener(_tickReturn);
  late final AnimationController _entranceController = AnimationController(
    vsync: this,
    duration: _content.entranceDuration,
  );
  Offset _dragOffset = Offset.zero;
  Offset _returnStart = Offset.zero;
  Offset _axisActivationOffset = Offset.zero;
  _ToastDragAxis? _dragAxis;
  var _entranceStarted = false;

  UiKitToastContent get _content => widget.request.content!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) ||
        _content.entrance != UiKitToastEntrance.slideFromTop ||
        _content.entranceDuration == Duration.zero) {
      _entranceController.value = 1;
      return;
    }
    if (!_entranceStarted) {
      _entranceStarted = true;
      _entranceController.forward();
    }
  }

  void _tickReturn() {
    setState(() {
      _dragOffset = Offset.lerp(
        _returnStart,
        Offset.zero,
        Curves.easeOut.transform(_returnController.value),
      )!;
    });
  }

  void _handlePanStart(DragStartDetails details) {
    _returnController.stop();
    _axisActivationOffset = Offset.zero;
    _dragAxis = null;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final lockDownward =
        _content.dragBehavior == UiKitToastDragBehavior.lockDownward;
    if (!lockDownward) {
      setState(() => _dragOffset += details.delta);
      return;
    }
    if (_dragAxis == null) {
      _axisActivationOffset += details.delta;
      if (_axisActivationOffset.distance < _axisActivationDistance) return;
      _dragAxis =
          _axisActivationOffset.dy < 0 &&
              _axisActivationOffset.dy.abs() >= _axisActivationOffset.dx.abs()
          ? _ToastDragAxis.vertical
          : _ToastDragAxis.horizontal;
      final activationDelta = _dragAxis == _ToastDragAxis.vertical
          ? Offset(0, _beyondActivationRange(_axisActivationOffset.dy))
          : Offset(_beyondActivationRange(_axisActivationOffset.dx), 0);
      _applyDragDelta(activationDelta);
      return;
    }
    final horizontalDelta = _dragAxis == _ToastDragAxis.vertical
        ? 0.0
        : details.delta.dx;
    final verticalDelta =
        _dragAxis == _ToastDragAxis.horizontal || details.delta.dy > 0
        ? 0.0
        : details.delta.dy;
    _applyDragDelta(Offset(horizontalDelta, verticalDelta));
  }

  double _beyondActivationRange(double value) {
    final distance = value.abs() - _axisActivationDistance;
    return distance > 0 ? distance * value.sign : 0.0;
  }

  void _applyDragDelta(Offset delta) {
    if (delta == Offset.zero) return;
    setState(() => _dragOffset += delta);
  }

  bool _shouldDismiss(DragEndDetails details) {
    final offset = _dragOffset;
    final velocity = details.velocity.pixelsPerSecond;
    final lockDownward =
        _content.dragBehavior == UiKitToastDragBehavior.lockDownward;
    if (lockDownward && _dragAxis == null) return false;
    final horizontalVelocity = _dragAxis == _ToastDragAxis.vertical
        ? 0.0
        : velocity.dx;
    final verticalVelocity =
        lockDownward &&
            (_dragAxis == _ToastDragAxis.horizontal || velocity.dy > 0)
        ? 0.0
        : velocity.dy;
    final horizontal = horizontalVelocity.abs() > verticalVelocity.abs()
        ? true
        : verticalVelocity.abs() > horizontalVelocity.abs()
        ? false
        : offset.dx.abs() >= offset.dy.abs();
    if (horizontal) {
      return offset.dx.abs() >= _dismissDistance ||
          horizontalVelocity.abs() >= _dismissVelocity;
    }
    return offset.dy < 0 &&
        (-offset.dy >= _dismissDistance || -velocity.dy >= _dismissVelocity);
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_shouldDismiss(details)) {
      widget.onDismiss();
      return;
    }
    _returnStart = _dragOffset;
    _returnController.forward(from: 0);
  }

  void _handleTap() {
    _content.onTap?.call();
    if (_content.onTap != null) widget.onDismiss();
  }

  @override
  void dispose() {
    _returnController
      ..removeListener(_tickReturn)
      ..dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final appearance = _content.appearance;
    final tone = _tone(theme, widget.request.type);
    final backgroundColor = appearance?.backgroundColor ?? tone.background;
    final titleColor = appearance?.titleColor ?? theme.text;
    final messageColor = appearance?.messageColor ?? theme.textMuted;
    final leadingColor = appearance?.leadingIconColor ?? tone.foreground;
    final trailingColor = appearance?.trailingIndicatorColor ?? theme.textMuted;
    final leading = appearance?.leading;
    final leadingIcon =
        appearance?.leadingIcon ?? _leadingIcon(widget.request.type);
    final trailingIcon =
        appearance?.trailingIndicator ??
        (_content.onTap == null ? Icons.close : Icons.chevron_right);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          theme.spacingLg,
          theme.spacingSm,
          theme.spacingLg,
          theme.spacingSm,
        ),
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
              .chain(CurveTween(curve: _content.entranceCurve))
              .animate(_entranceController),
          child: Transform.translate(
            offset: _dragOffset,
            child: Semantics(
              container: true,
              label:
                  _content.semanticLabel ??
                  "${_content.title}: ${_content.message}",
              button: _content.onTap != null,
              onTap: _content.onTap == null ? null : _handleTap,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _content.onTap == null ? null : _handleTap,
                onPanStart: _handlePanStart,
                onPanUpdate: _handlePanUpdate,
                onPanEnd: _handlePanEnd,
                child: Material(
                  key: const ValueKey("ui-kit-toast-surface"),
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(theme.radiusLg),
                  elevation: 6,
                  child: Padding(
                    padding: EdgeInsets.all(theme.spacingMd),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Center(
                            child:
                                leading ??
                                Icon(leadingIcon, color: leadingColor),
                          ),
                        ),
                        SizedBox(width: theme.spacingSm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _content.title,
                                style: theme.bodySemibold.copyWith(
                                  color: titleColor,
                                ),
                              ),
                              SizedBox(height: theme.spacing2xs),
                              Text(
                                _content.message,
                                style: theme.body.copyWith(color: messageColor),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: theme.spacingSm),
                        Icon(trailingIcon, color: trailingColor),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _ToastTone _tone(UiKitThemeData theme, UiKitToastType type) => switch (type) {
    UiKitToastType.normal => _ToastTone(theme.surface, theme.primary),
    UiKitToastType.warning => _ToastTone(theme.warningBg, theme.warning),
    UiKitToastType.success => _ToastTone(theme.successBg, theme.success),
    UiKitToastType.error => _ToastTone(theme.errorBg, theme.error),
  };

  IconData _leadingIcon(UiKitToastType type) => switch (type) {
    UiKitToastType.normal => Icons.info_outline,
    UiKitToastType.warning => Icons.warning_amber_outlined,
    UiKitToastType.success => Icons.check_circle_outline,
    UiKitToastType.error => Icons.error_outline,
  };
}

class _ToastTone {
  const _ToastTone(this.background, this.foreground);

  final Color background;
  final Color foreground;
}

enum _ToastDragAxis { horizontal, vertical }
