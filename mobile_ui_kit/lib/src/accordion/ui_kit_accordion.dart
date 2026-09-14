import "package:flutter/widgets.dart";

import "package:mobile_ui_kit/src/accordion/ui_kit_accordion_item.dart";
import "package:mobile_ui_kit/src/pressable/ui_kit_pressable.dart";

/// Accordion headless — thay `FAccordion`/`FAccordionControl.lifted`/
/// `FAccordionItem`. Value là `Set<String>` id-based (không index-based).
///
/// Package chỉ lo behavior (expand/collapse state, animation, disabled
/// gating) — app-layer tự vẽ trailing icon/chevron qua [trailingBuilder]
/// (mặc định `null` → không có trailing, caller tự đặt icon trong [title]
/// nếu cần).
class UiKitAccordion extends StatelessWidget {
  const UiKitAccordion({
    required this.items,
    required this.expandedIds,
    required this.onChanged,
    this.dividerColor,
    this.titlePadding = EdgeInsets.zero,
    this.expandDuration = const Duration(milliseconds: 250),
    this.collapseDuration = const Duration(milliseconds: 250),
    this.trailingBuilder,
    super.key,
  });

  final List<UiKitAccordionItem> items;

  final Set<String> expandedIds;

  final ValueChanged<Set<String>> onChanged;

  final Color? dividerColor;

  final EdgeInsetsGeometry titlePadding;

  final Duration expandDuration;

  final Duration collapseDuration;

  /// App-layer tự vẽ chevron/trailing icon theo `expanded` state.
  final Widget Function(BuildContext context, bool expanded)? trailingBuilder;

  void _toggle(UiKitAccordionItem item) {
    if (item.disabled) return;

    final expanded = expandedIds.contains(item.id);
    final next = Set<String>.from(expandedIds);
    if (expanded) {
      next.remove(item.id);
    } else {
      next.add(item.id);
    }
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0 && dividerColor != null)
            DecoratedBox(
              decoration: BoxDecoration(color: dividerColor),
              child: const SizedBox(height: 1, width: double.infinity),
            ),
          _UiKitAccordionItemView(
            item: items[i],
            expanded: expandedIds.contains(items[i].id),
            titlePadding: titlePadding,
            expandDuration: expandDuration,
            collapseDuration: collapseDuration,
            trailingBuilder: trailingBuilder,
            onToggle: () => _toggle(items[i]),
          ),
        ],
      ],
    );
  }
}

class _UiKitAccordionItemView extends StatelessWidget {
  const _UiKitAccordionItemView({
    required this.item,
    required this.expanded,
    required this.titlePadding,
    required this.expandDuration,
    required this.collapseDuration,
    required this.trailingBuilder,
    required this.onToggle,
  });

  final UiKitAccordionItem item;
  final bool expanded;
  final EdgeInsetsGeometry titlePadding;
  final Duration expandDuration;
  final Duration collapseDuration;
  final Widget Function(BuildContext context, bool expanded)? trailingBuilder;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final header = Opacity(
      opacity: item.disabled ? 0.4 : 1,
      child: Padding(
        padding: titlePadding,
        child: Row(
          children: [
            Expanded(child: item.title),
            if (trailingBuilder != null) trailingBuilder!(context, expanded),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UiKitPressable(
          onPress: item.disabled ? null : onToggle,
          selected: expanded,
          builder: (context, states, child) => header,
        ),
        AnimatedSize(
          duration: expanded ? expandDuration : collapseDuration,
          child: expanded
              ? IgnorePointer(ignoring: item.disabled, child: item.content)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
