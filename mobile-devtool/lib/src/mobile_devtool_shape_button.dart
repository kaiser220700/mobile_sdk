import "package:flutter/material.dart";

import "mobile_devtool_annotation_tool.dart";

/// Shape picker button for the Screen Draw toolbar — idle (hand)/select/
/// rectangle/circle/arrow/line/tooltip.
class MobileDevToolShapeButton extends StatelessWidget {
  const MobileDevToolShapeButton({
    required this.shape,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final MobileDevToolAnnotationShape shape;
  final bool selected;
  final VoidCallback onTap;

  IconData get _icon => switch (shape) {
    MobileDevToolAnnotationShape.idle => Icons.pan_tool_outlined,
    MobileDevToolAnnotationShape.select => Icons.near_me_outlined,
    MobileDevToolAnnotationShape.rectangle => Icons.crop_square,
    MobileDevToolAnnotationShape.circle => Icons.circle_outlined,
    MobileDevToolAnnotationShape.arrow => Icons.north_east,
    MobileDevToolAnnotationShape.line => Icons.horizontal_rule,
    MobileDevToolAnnotationShape.tooltip => Icons.chat_bubble_outline,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? scheme.primaryContainer : scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        side: BorderSide(
          color: selected ? scheme.primary : Theme.of(context).dividerColor,
        ),
      ),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            _icon,
            size: 20,
            color: selected ? scheme.primary : Theme.of(context).hintColor,
          ),
        ),
      ),
    );
  }
}
