import "package:flutter/material.dart";

class MobileDevToolExpandablePanel extends StatefulWidget {
  const MobileDevToolExpandablePanel({
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    super.key,
  });

  final String title;
  final Widget child;
  final bool initiallyExpanded;

  @override
  State<MobileDevToolExpandablePanel> createState() =>
      _MobileDevToolExpandablePanelState();
}

class _MobileDevToolExpandablePanelState
    extends State<MobileDevToolExpandablePanel> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(widget.title, style: textTheme.titleSmall),
                ),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
        ),
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: _expanded ? widget.child : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
