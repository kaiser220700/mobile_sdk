import "package:flutter/widgets.dart";

import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

/// Solid line divider headless — thay `FDivider`. Không xử lý padding/margin
/// hay label; đó là việc của app-layer (`AppDivider`).
class UiKitDivider extends StatelessWidget {
  const UiKitDivider({
    this.axis = Axis.horizontal,
    this.color,
    this.thickness = 1,
    super.key,
  });

  final Axis axis;

  final Color? color;

  final double thickness;

  @override
  Widget build(BuildContext context) {
    final lineColor = color ?? UiKitTheme.of(context).border;
    if (axis == Axis.horizontal) {
      return DecoratedBox(
        decoration: BoxDecoration(color: lineColor),
        child: SizedBox(height: thickness, width: double.infinity),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(color: lineColor),
      child: SizedBox(width: thickness, height: double.infinity),
    );
  }
}
