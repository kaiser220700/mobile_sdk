import "dart:math" as math;
import "dart:ui";

import "package:flutter/material.dart";

import "mobile_devtool_annotation_canvas.dart";
import "mobile_devtool_annotation_tool.dart";
import "mobile_devtool_drag_tap_detector.dart";
import "mobile_devtool_shape_button.dart";
import "mobile_devtool_theme.dart";

const List<MobileDevToolAnnotationShape> _groupedShapes = [
  MobileDevToolAnnotationShape.rectangle,
  MobileDevToolAnnotationShape.circle,
  MobileDevToolAnnotationShape.arrow,
  MobileDevToolAnnotationShape.line,
];

/// Full-screen "Screen Draw" overlay — a draggable toolbar (collapsed icon or
/// expanded pill) plus the drawing canvas underneath it, driven entirely by
/// [tool].
class MobileDevToolAnnotationOverlay extends StatelessWidget {
  const MobileDevToolAnnotationOverlay({required this.tool, super.key});

  final MobileDevToolAnnotationTool tool;

  static const _collapsedDiameter = 48.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: tool,
      builder: (context, _) {
        final mediaQuery = MediaQuery.of(context);
        final defaultPosition = Offset(
          mediaQuery.size.width - _collapsedDiameter - 12,
          mediaQuery.size.height -
              mediaQuery.viewPadding.bottom -
              _collapsedDiameter -
              24,
        );
        final position = tool.toolbarPosition ?? defaultPosition;

        final toolbar = AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          reverseDuration: const Duration(milliseconds: 150),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            alignment: Alignment.topLeft,
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: tool.toolbarCollapsed
              ? _CollapsedIcon(
                  key: const ValueKey("collapsed"),
                  currentPosition: position,
                  tool: tool,
                )
              : MobileDevToolDragTapDetector(
                  key: const ValueKey("expanded-drag"),
                  onDragUpdate: (delta) =>
                      tool.toolbarPosition = position + delta,
                  child: _Toolbar(tool: tool),
                ),
        );
        final maxWidth = math.max(
          0.0,
          mediaQuery.size.width - (_CollapsedIcon._edgeMargin * 2),
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            MobileDevToolAnnotationCanvas(tool: tool),
            CustomSingleChildLayout(
              delegate: _AnnotationToolbarLayoutDelegate(
                requestedPosition: position,
                edgeMargin: _CollapsedIcon._edgeMargin,
                viewPadding: mediaQuery.viewPadding,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: toolbar,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CollapsedIcon extends StatelessWidget {
  const _CollapsedIcon({
    required this.currentPosition,
    required this.tool,
    super.key,
  });

  final Offset currentPosition;
  final MobileDevToolAnnotationTool tool;

  static const _diameter = 48.0;
  static const _edgeMargin = 12.0;

  Offset _clamp(BuildContext context, Offset position) {
    final mediaQuery = MediaQuery.of(context);
    final viewPadding = mediaQuery.viewPadding;
    const minX = _edgeMargin;
    final maxX = (mediaQuery.size.width - _diameter - _edgeMargin).clamp(
      minX,
      double.infinity,
    );
    final minY = viewPadding.top + _edgeMargin;
    final maxY =
        (mediaQuery.size.height - viewPadding.bottom - _diameter - _edgeMargin)
            .clamp(minY, double.infinity);
    return Offset(position.dx.clamp(minX, maxX), position.dy.clamp(minY, maxY));
  }

  @override
  Widget build(BuildContext context) {
    return MobileDevToolDragTapDetector(
      onDragUpdate: (delta) =>
          tool.toolbarPosition = _clamp(context, currentPosition + delta),
      onTap: tool.toggleToolbarCollapsed,
      child: const Material(
        elevation: 4,
        color: MobileDevToolTheme.surface,
        shape: CircleBorder(),
        child: SizedBox(
          width: _diameter,
          height: _diameter,
          child: Icon(Icons.edit_outlined),
        ),
      ),
    );
  }
}

class _AnnotationToolbarLayoutDelegate extends SingleChildLayoutDelegate {
  const _AnnotationToolbarLayoutDelegate({
    required this.requestedPosition,
    required this.edgeMargin,
    required this.viewPadding,
  });

  final Offset requestedPosition;
  final double edgeMargin;
  final EdgeInsets viewPadding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final minX = edgeMargin;
    final maxX = math.max(minX, size.width - childSize.width - edgeMargin);
    final minY = math.max(edgeMargin, viewPadding.top + edgeMargin);
    final maxY = math.max(
      minY,
      size.height - viewPadding.bottom - childSize.height - edgeMargin,
    );
    return Offset(
      requestedPosition.dx.clamp(minX, maxX).toDouble(),
      requestedPosition.dy.clamp(minY, maxY).toDouble(),
    );
  }

  @override
  bool shouldRelayout(covariant _AnnotationToolbarLayoutDelegate oldDelegate) =>
      requestedPosition != oldDelegate.requestedPosition ||
      edgeMargin != oldDelegate.edgeMargin ||
      viewPadding != oldDelegate.viewPadding;
}

class _Toolbar extends StatefulWidget {
  const _Toolbar({required this.tool});

  final MobileDevToolAnnotationTool tool;

  @override
  State<_Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<_Toolbar> {
  bool _overflowActive = false;

  void _selectShape(MobileDevToolAnnotationShape shape) {
    setState(() => _overflowActive = false);
    widget.tool.selectShape(shape);
  }

  @override
  Widget build(BuildContext context) {
    final tool = widget.tool;
    final isGroupedShapeActive = _groupedShapes.contains(tool.activeShape);
    final isTooltipActive =
        tool.activeShape == MobileDevToolAnnotationShape.tooltip;
    final hasSecondRow =
        isGroupedShapeActive || isTooltipActive || _overflowActive;
    const radius = BorderRadius.all(
      Radius.circular(MobileDevToolTheme.radiusLg),
    );

    return DecoratedBox(
      // Ring shadow trắng + viền sáng mỏng để tách toolbar khỏi app phía sau
      // (nền toolbar bán trong suốt) — cùng công thức với panel Fuzz Tap.
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: MobileDevToolTheme.textInverse.withValues(alpha: .35),
            blurRadius: 16,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(
            color: MobileDevToolTheme.textInverse.withValues(alpha: .4),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: _GlassPanel(
          borderRadius: radius,
          // `Material` bọc toàn bộ nội dung — thiếu nó khiến `IconButton` bên
          // dưới (more_vert/close/undo/delete) crash "No Material widget
          // found" vì toolbar này mount trực tiếp trong `Overlay`, không có
          // `Material` ancestor nào từ `MaterialApp` phía trên.
          child: Material(
            type: MaterialType.transparency,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _shapeButtonPadding(
                          MobileDevToolShapeButton(
                            shape: MobileDevToolAnnotationShape.idle,
                            selected:
                                tool.activeShape ==
                                MobileDevToolAnnotationShape.idle,
                            onTap: () =>
                                _selectShape(MobileDevToolAnnotationShape.idle),
                          ),
                        ),
                        _shapeButtonPadding(
                          MobileDevToolShapeButton(
                            shape: MobileDevToolAnnotationShape.select,
                            selected:
                                tool.activeShape ==
                                MobileDevToolAnnotationShape.select,
                            onTap: () => _selectShape(
                              MobileDevToolAnnotationShape.select,
                            ),
                          ),
                        ),
                        _shapeButtonPadding(
                          MobileDevToolShapeButton(
                            shape: isGroupedShapeActive
                                ? tool.activeShape
                                : _groupedShapes.first,
                            selected: isGroupedShapeActive,
                            onTap: () => _selectShape(
                              isGroupedShapeActive
                                  ? tool.activeShape
                                  : _groupedShapes.first,
                            ),
                          ),
                        ),
                        _shapeButtonPadding(
                          MobileDevToolShapeButton(
                            shape: MobileDevToolAnnotationShape.tooltip,
                            selected: isTooltipActive,
                            onTap: () => _selectShape(
                              MobileDevToolAnnotationShape.tooltip,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.more_vert,
                            color: _overflowActive
                                ? MobileDevToolTheme.primary
                                : null,
                          ),
                          tooltip: "Thêm",
                          onPressed: () => setState(
                            () => _overflowActive = !_overflowActive,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.unfold_less),
                          tooltip: "Thu gọn",
                          onPressed: tool.toggleToolbarCollapsed,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: "Đóng Screen Draw",
                          onPressed: tool.hideOverlay,
                        ),
                      ],
                    ),
                  ),
                  if (hasSecondRow)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: .8),
                          borderRadius: BorderRadius.circular(
                            MobileDevToolTheme.radiusMd,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: _overflowActive
                                  ? [
                                      IconButton(
                                        icon: const Icon(Icons.undo),
                                        tooltip: "Undo",
                                        onPressed:
                                            tool.visibleAnnotations.isEmpty
                                            ? null
                                            : tool.removeLast,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        tooltip: "Clear trang này",
                                        onPressed:
                                            tool.visibleAnnotations.isEmpty
                                            ? null
                                            : tool.clear,
                                      ),
                                    ]
                                  : [
                                      if (isGroupedShapeActive)
                                        for (final shape in _groupedShapes)
                                          _shapeButtonPadding(
                                            _ShapeChip(
                                              shape: shape,
                                              tool: tool,
                                            ),
                                          ),
                                      if (isGroupedShapeActive)
                                        const SizedBox(width: 8),
                                      if (isGroupedShapeActive)
                                        for (final color in tool.colorPalette)
                                          _shapeButtonPadding(
                                            _ColorSwatch(
                                              color: color,
                                              selected:
                                                  color == tool.activeColor,
                                              onTap: () =>
                                                  tool.selectColor(color),
                                            ),
                                          ),
                                      if (isTooltipActive) ...[
                                        for (final color in tool.colorPalette)
                                          _shapeButtonPadding(
                                            _ColorSwatch(
                                              color: color,
                                              selected:
                                                  color == tool.activeTextColor,
                                              onTap: () =>
                                                  tool.selectTextColor(color),
                                            ),
                                          ),
                                        const SizedBox(width: 8),
                                        for (final size
                                            in mobileDevToolAnnotationFontSizeOptions)
                                          _shapeButtonPadding(
                                            _FontSizeButton(
                                              size: size,
                                              selected:
                                                  size == tool.activeFontSize,
                                              onTap: () =>
                                                  tool.selectFontSize(size),
                                            ),
                                          ),
                                      ],
                                    ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _shapeButtonPadding(Widget child) =>
      Padding(padding: const EdgeInsets.only(right: 4), child: child);
}

/// Hiệu ứng "kính mờ" (glassmorphism) cho nền toolbar — `BackdropFilter` blur
/// nội dung phía sau + lớp màu bán trong suốt phủ lên trên, khớp bản gốc
/// trong app trước khi tách sang SDK riêng.
class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.borderRadius, required this.child});

  final BorderRadius borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: const BoxDecoration(color: MobileDevToolTheme.surface),
          child: child,
        ),
      ),
    );
  }
}

class _ShapeChip extends StatelessWidget {
  const _ShapeChip({required this.shape, required this.tool});

  final MobileDevToolAnnotationShape shape;
  final MobileDevToolAnnotationTool tool;

  @override
  Widget build(BuildContext context) => MobileDevToolShapeButton(
    shape: shape,
    selected: shape == tool.activeShape,
    onTap: () => tool.selectShape(shape),
  );
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? MobileDevToolTheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class _FontSizeButton extends StatelessWidget {
  const _FontSizeButton({
    required this.size,
    required this.selected,
    required this.onTap,
  });

  final double size;
  final bool selected;
  final VoidCallback onTap;

  String get _label =>
      switch (mobileDevToolAnnotationFontSizeOptions.indexOf(size)) {
        0 => "S",
        2 => "L",
        _ => "M",
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? scheme.primaryContainer : scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: selected ? scheme.primary : Colors.transparent),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(8), child: Text(_label)),
      ),
    );
  }
}
