import "dart:math" as math;

import "package:flutter/material.dart";

import "mobile_devtool_annotation_tool.dart";

const _tooltipHint = "Nhập nội dung tooltip";
const _tooltipMinWidth = 200.0;
const _tooltipMaxWidth = 350.0;

/// Freehand drawing canvas shared by the full-screen overlay and any embedded
/// preview — pass the same [tool] instance so both stay in sync.
///
/// Annotations store "world" coordinates (local position + scroll offset at
/// draw time) and are always drawn at `world - current offset`, so they
/// track content when the user scrolls the real screen underneath
/// (best-effort — inaccurate if a screen has multiple independent
/// `Scrollable`s at once).
class MobileDevToolAnnotationCanvas extends StatefulWidget {
  const MobileDevToolAnnotationCanvas({required this.tool, super.key});

  final MobileDevToolAnnotationTool tool;

  @override
  State<MobileDevToolAnnotationCanvas> createState() =>
      _MobileDevToolAnnotationCanvasState();
}

class _MobileDevToolAnnotationCanvasState
    extends State<MobileDevToolAnnotationCanvas> {
  int? _editingAnnotationId;
  Offset? _editingPosition;
  final _editingController = TextEditingController();
  final _editingFocusNode = FocusNode();

  @override
  void dispose() {
    _editingController.dispose();
    _editingFocusNode.dispose();
    super.dispose();
  }

  Rect _boundingBoxOf(MobileDevToolAnnotation annotation, Offset scrollOffset) {
    final start = annotation.start - scrollOffset;
    final end = annotation.end - scrollOffset;
    if (annotation.shape == MobileDevToolAnnotationShape.tooltip) {
      final bubbleRect = _tooltipBubbleRect(
        start,
        annotation.text,
        fontSize:
            annotation.fontSize ?? mobileDevToolAnnotationFontSizeOptions[1],
      );
      return bubbleRect.inflate(4);
    }
    return Rect.fromPoints(start, end).inflate(8);
  }

  MobileDevToolAnnotation? _hitTestExistingTooltip(
    List<MobileDevToolAnnotation> annotations,
    Offset position,
    Offset scrollOffset,
  ) {
    for (final annotation in annotations.reversed) {
      if (annotation.shape != MobileDevToolAnnotationShape.tooltip) continue;
      if (_boundingBoxOf(annotation, scrollOffset).contains(position))
        return annotation;
    }
    return null;
  }

  MobileDevToolAnnotation? _hitTestAny(
    List<MobileDevToolAnnotation> annotations,
    Offset position,
    Offset scrollOffset,
  ) {
    for (final annotation in annotations.reversed) {
      if (_boundingBoxOf(annotation, scrollOffset).contains(position))
        return annotation;
    }
    return null;
  }

  void _handleTooltipTap(
    List<MobileDevToolAnnotation> annotations,
    Offset position,
  ) {
    final tool = widget.tool;
    final scrollOffset = tool.scrollOffset;
    final existing = _hitTestExistingTooltip(
      annotations,
      position,
      scrollOffset,
    );
    if (existing != null) {
      _editingController.text = existing.text;
      tool.selectTextColor(existing.textColor ?? Colors.white);
      tool.selectFontSize(
        existing.fontSize ?? mobileDevToolAnnotationFontSizeOptions[1],
      );
      setState(() {
        _editingAnnotationId = existing.id;
        _editingPosition = existing.start - scrollOffset;
      });
    } else {
      tool.begin(
        MobileDevToolAnnotationShape.tooltip,
        position,
        scrollOffset: scrollOffset,
        color: tool.activeColor,
        textColor: tool.activeTextColor,
        fontSize: tool.activeFontSize,
      );
      _editingController.text = "";
      setState(() {
        _editingAnnotationId = tool.lastId;
        _editingPosition = position;
      });
    }
    _editingFocusNode.requestFocus();
  }

  void _commitEditing() {
    final id = _editingAnnotationId;
    if (id != null) {
      widget.tool.setTooltipStyleForId(
        id,
        text: _editingController.text,
        textColor: widget.tool.activeTextColor,
        fontSize: widget.tool.activeFontSize,
      );
    }
    setState(() {
      _editingAnnotationId = null;
      _editingPosition = null;
    });
  }

  void _handleSelectTap(
    List<MobileDevToolAnnotation> annotations,
    Offset position,
    Offset scrollOffset,
  ) {
    final hit = _hitTestAny(annotations, position, scrollOffset);
    widget.tool.selectAnnotation(hit?.id);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.tool,
      builder: (context, _) {
        final tool = widget.tool;
        final annotations = tool.visibleAnnotations;
        final isIdle = tool.activeShape == MobileDevToolAnnotationShape.idle;
        final isSelect =
            tool.activeShape == MobileDevToolAnnotationShape.select;
        final isTooltip =
            tool.activeShape == MobileDevToolAnnotationShape.tooltip;
        final scrollOffset = tool.scrollOffset;
        final selectedId = isSelect ? tool.selectedId : null;

        final painter = CustomPaint(
          painter: MobileDevToolAnnotationPainter(
            annotations,
            scrollOffset: scrollOffset,
            selectedId: selectedId,
          ),
          size: Size.infinite,
        );

        if (isIdle) return IgnorePointer(child: painter);

        Widget canvas;
        if (isSelect) {
          canvas = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) => _handleSelectTap(
              annotations,
              details.localPosition,
              scrollOffset,
            ),
            child: painter,
          );
        } else {
          canvas = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: isTooltip
                ? null
                : (details) => tool.begin(
                    tool.activeShape,
                    details.localPosition,
                    scrollOffset: scrollOffset,
                    color: tool.activeColor,
                  ),
            onPanUpdate: isTooltip
                ? null
                : (details) => tool.updateLast(
                    details.localPosition,
                    scrollOffset: scrollOffset,
                  ),
            onTapDown: isTooltip ? (_) {} : null,
            onTapUp: isTooltip
                ? (details) =>
                      _handleTooltipTap(annotations, details.localPosition)
                : null,
            child: painter,
          );
        }

        final overlays = <Widget>[canvas];

        final editingPosition = _editingPosition;
        if (editingPosition != null) {
          overlays.add(
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _editingController,
              builder: (context, value, _) {
                final bubbleWidth = _tooltipBubbleRect(
                  editingPosition,
                  value.text,
                  fontSize: tool.activeFontSize,
                ).width;
                return Positioned(
                  left: editingPosition.dx - bubbleWidth / 2,
                  bottom:
                      MediaQuery.sizeOf(context).height - editingPosition.dy,
                  child: Material(
                    elevation: 4,
                    color: tool.activeColor,
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: bubbleWidth,
                      child: TextField(
                        controller: _editingController,
                        focusNode: _editingFocusNode,
                        autofocus: true,
                        maxLines: null,
                        style: TextStyle(
                          color: tool.activeTextColor,
                          fontSize: tool.activeFontSize,
                        ),
                        cursorColor: tool.activeTextColor,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.all(8),
                          border: InputBorder.none,
                          hintText: _tooltipHint,
                          hintStyle: TextStyle(
                            color: tool.activeTextColor.withValues(alpha: .6),
                          ),
                        ),
                        onSubmitted: (_) => _commitEditing(),
                        onTapOutside: (_) => _commitEditing(),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }

        if (selectedId != null) {
          final selected = annotations
              .where((a) => a.id == selectedId)
              .cast<MobileDevToolAnnotation?>()
              .firstWhere((a) => a != null, orElse: () => null);
          if (selected != null) {
            final box = _boundingBoxOf(selected, scrollOffset);
            overlays.add(
              Positioned(
                left: box.right - 16,
                top: box.top - 16,
                child: Material(
                  color: Theme.of(context).colorScheme.error,
                  shape: const CircleBorder(),
                  elevation: 4,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      tool.removeById(selectedId);
                      tool.selectAnnotation(null);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.delete, size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
            );
          }
        }

        if (overlays.length == 1) return canvas;
        return Stack(clipBehavior: Clip.none, children: overlays);
      },
    );
  }
}

Rect _tooltipBubbleRect(
  Offset anchor,
  String text, {
  required double fontSize,
}) {
  final label = text.isEmpty ? "?" : text;
  final textPainter = TextPainter(
    text: TextSpan(
      text: label,
      style: TextStyle(fontSize: fontSize),
    ),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: _tooltipMaxWidth - 16);
  final contentWidth = (textPainter.width + 16).clamp(
    _tooltipMinWidth,
    _tooltipMaxWidth,
  );
  return Rect.fromLTWH(
    anchor.dx - contentWidth / 2,
    anchor.dy - textPainter.height - 24,
    contentWidth,
    textPainter.height + 16,
  );
}

class MobileDevToolAnnotationPainter extends CustomPainter {
  MobileDevToolAnnotationPainter(
    this.annotations, {
    required this.scrollOffset,
    this.selectedId,
  });

  final List<MobileDevToolAnnotation> annotations;
  final Offset scrollOffset;
  final int? selectedId;

  static const _strokeWidth = 2.5;

  @override
  void paint(Canvas canvas, Size size) {
    for (final annotation in annotations) {
      final strokePaint = Paint()
        ..color = annotation.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth;
      final start = annotation.start - scrollOffset;
      final end = annotation.end - scrollOffset;
      switch (annotation.shape) {
        case MobileDevToolAnnotationShape.idle:
        case MobileDevToolAnnotationShape.select:
          break;
        case MobileDevToolAnnotationShape.rectangle:
          canvas.drawRect(Rect.fromPoints(start, end), strokePaint);
        case MobileDevToolAnnotationShape.circle:
          canvas.drawOval(Rect.fromPoints(start, end), strokePaint);
        case MobileDevToolAnnotationShape.arrow:
          _drawArrow(canvas, strokePaint, start, end);
        case MobileDevToolAnnotationShape.line:
          canvas.drawLine(start, end, strokePaint);
        case MobileDevToolAnnotationShape.tooltip:
          _drawTooltip(canvas, start, annotation);
      }

      if (annotation.id == selectedId) {
        final selectionRect =
            annotation.shape == MobileDevToolAnnotationShape.tooltip
            ? _tooltipBubbleRect(
                start,
                annotation.text,
                fontSize:
                    annotation.fontSize ??
                    mobileDevToolAnnotationFontSizeOptions[1],
              ).inflate(4)
            : Rect.fromPoints(start, end).inflate(8);
        canvas.drawRect(
          selectionRect,
          Paint()
            ..color = annotation.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
    }
  }

  void _drawArrow(Canvas canvas, Paint paint, Offset start, Offset end) {
    canvas.drawLine(start, end, paint);
    final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
    const headLength = 14.0;
    const headAngle = math.pi / 7;
    final path = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        end.dx - headLength * math.cos(angle - headAngle),
        end.dy - headLength * math.sin(angle - headAngle),
      )
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        end.dx - headLength * math.cos(angle + headAngle),
        end.dy - headLength * math.sin(angle + headAngle),
      );
    canvas.drawPath(path, paint);
  }

  /// Simplified bubble — a plain rounded rectangle rather than the app's
  /// nip-pointing custom shape, to keep the SDK free of that app widget.
  void _drawTooltip(
    Canvas canvas,
    Offset anchor,
    MobileDevToolAnnotation annotation,
  ) {
    final fontSize =
        annotation.fontSize ?? mobileDevToolAnnotationFontSizeOptions[1];
    final textColor = annotation.textColor ?? Colors.white;
    final bubbleRect = _tooltipBubbleRect(
      anchor,
      annotation.text,
      fontSize: fontSize,
    );
    final rrect = RRect.fromRectAndRadius(bubbleRect, const Radius.circular(8));
    canvas.drawRRect(rrect, Paint()..color = annotation.color);

    final label = annotation.text.isEmpty ? "?" : annotation.text;
    TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(color: textColor, fontSize: fontSize),
        ),
        textDirection: TextDirection.ltr,
      )
      ..layout(maxWidth: _tooltipMaxWidth - 16)
      ..paint(canvas, bubbleRect.topLeft + const Offset(8, 8));
  }

  @override
  bool shouldRepaint(MobileDevToolAnnotationPainter oldDelegate) =>
      oldDelegate.annotations != annotations ||
      oldDelegate.scrollOffset != scrollOffset ||
      oldDelegate.selectedId != selectedId;
}
