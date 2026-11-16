import "package:material_ui/material_ui.dart";

import "annotation_tool.dart";

/// Shape picker button for the Screen Draw toolbar — idle (hand)/select/
/// rectangle/circle/arrow/line/tooltip.
class ShapeButton extends StatelessWidget {
  const ShapeButton({
    required this.shape,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final Shape shape;
  final bool selected;
  final VoidCallback onTap;

  IconData get _icon => switch (shape) {
    Shape.idle => Icons.pan_tool_outlined,
    Shape.select => Icons.near_me_outlined,
    Shape.rectangle => Icons.crop_square,
    Shape.circle => Icons.circle_outlined,
    Shape.arrow => Icons.north_east,
    Shape.line => Icons.horizontal_rule,
    Shape.tooltip => Icons.chat_bubble_outline,
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
