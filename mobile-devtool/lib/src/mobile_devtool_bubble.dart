import "dart:ui";

import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "mobile_devtool_controller.dart";
import "mobile_devtool_drag_tap_detector.dart";
import "mobile_devtool_theme.dart";
import "mobile_devtool_ui_state.dart";

/// Draggable launcher bubble mounted over the whole app — tap opens the root
/// menu, drag repositions it, and it fades after a period of inactivity.
class MobileDevToolBubble extends StatelessWidget {
  const MobileDevToolBubble({
    required this.controller,
    required this.position,
    required this.idle,
    required this.onTap,
    this.accentColor,
    super.key,
  });

  final MobileDevToolController controller;
  final MobileDevToolBubblePosition position;
  final MobileDevToolBubbleIdle idle;
  final VoidCallback onTap;
  final Color? accentColor;

  static const double _diameter = 48;
  static const double _edgeMargin = 12;

  Offset _clamp(BuildContext context, Offset position) {
    final mediaQuery = MediaQuery.of(context);
    final viewPadding = mediaQuery.viewPadding;
    final bottomInset = viewPadding.bottom > mediaQuery.viewInsets.bottom
        ? viewPadding.bottom
        : mediaQuery.viewInsets.bottom;
    const minX = _edgeMargin;
    final maxX = (mediaQuery.size.width - _diameter - _edgeMargin).clamp(
      minX,
      double.infinity,
    );
    final minY = viewPadding.top + _edgeMargin;
    final maxY =
        (mediaQuery.size.height - bottomInset - _diameter - _edgeMargin).clamp(
          minY,
          double.infinity,
        );
    return Offset(position.dx.clamp(minX, maxX), position.dy.clamp(minY, maxY));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller, position, idle]),
      builder: (context, _) {
        final clampedPosition = _clamp(context, position.value);

        return Stack(
          children: [
            Positioned(
              left: clampedPosition.dx,
              top: clampedPosition.dy,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: idle.value ? .45 : 1,
                child: MobileDevToolDragTapDetector(
                  onDragStart: idle.interact,
                  onDragUpdate: (delta) =>
                      position.value = _clamp(context, position.value + delta),
                  onDragEnd: idle.interact,
                  onTap: () {
                    idle.interact();
                    onTap();
                  },
                  child: RepaintBoundary(
                    child: _Bubble(
                      count: controller.networkEntries.length,
                      diameter: _diameter,
                      accentColor: accentColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.count,
    required this.diameter,
    this.accentColor,
  });

  final int count;
  final double diameter;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? MobileDevToolTheme.primary;
    return Material(
      color: Colors.transparent,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: MobileDevToolTheme.bubbleShadow,
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: MobileDevToolTheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: MobileDevToolTheme.primary),
              ),
              child: Center(
                child: Icon(LucideIcons.scanSearch, color: color, size: 24),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
