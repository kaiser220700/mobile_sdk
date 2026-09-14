import "package:flutter/material.dart";

class MobileDevToolExpandableSecretText extends StatelessWidget {
  const MobileDevToolExpandableSecretText({
    required this.value,
    required this.collapsedValue,
    required this.expanded,
    required this.onToggle,
    required this.onDoubleTap,
    this.expandWidget,
    this.collapseWidget,
    super.key,
  });

  final String value;
  final String collapsedValue;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onDoubleTap;
  final Widget? expandWidget;
  final Widget? collapseWidget;

  static const _textStyle = TextStyle(fontFamily: "monospace");

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final actionWidget = expanded
        ? collapseWidget ?? _fallbackAction("Thu gọn", accent)
        : expandWidget ?? _fallbackAction("Xem thêm", accent);

    return Semantics(
      button: true,
      label: expanded ? "Thu gọn" : "Xem thêm",
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onToggle,
        onDoubleTap: onDoubleTap,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: expanded ? value : collapsedValue,
                style: _textStyle,
              ),
              const TextSpan(text: "  "),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: actionWidget,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackAction(String label, Color color) => Text(
    label,
    style: TextStyle(fontWeight: FontWeight.w600, color: color),
  );
}
