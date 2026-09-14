import "package:flutter/widgets.dart";

/// Data holder cho 1 item của [UiKitAccordion] — `disabled` là field native
/// (khác `FAccordionItem` của forui thiếu field này).
@immutable
class UiKitAccordionItem {
  const UiKitAccordionItem({
    required this.id,
    required this.title,
    required this.content,
    this.disabled = false,
  });

  final String id;

  final Widget title;

  final Widget content;

  final bool disabled;
}
