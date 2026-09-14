import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

enum UiKitCheckboxSize { sm, md, lg }

class UiKitCheckbox extends StatelessWidget {
  const UiKitCheckbox({
    required this.value,
    this.indeterminate = false,
    this.onChanged,
    this.label,
    this.description,
    this.inlineDescription = false,
    this.size = UiKitCheckboxSize.md,
    this.error = false,
    this.disabled = false,
    this.semanticsLabel,
    super.key,
  });

  final bool value;
  final bool indeterminate;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final String? description;
  final bool inlineDescription;
  final UiKitCheckboxSize size;
  final bool error;
  final bool disabled;
  final String? semanticsLabel;

  bool get _disabled => disabled || onChanged == null;
  double get _size => switch (size) {
    UiKitCheckboxSize.sm => 16,
    UiKitCheckboxSize.md => 20,
    UiKitCheckboxSize.lg => 24,
  };

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final selected = value || indeterminate;
    final control = SizedBox(
      width: theme.touchMinTarget,
      height: theme.touchMinTarget,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            color: _disabled
                ? (selected ? theme.textDisabled : Colors.transparent)
                : (selected ? theme.primary : Colors.transparent),
            border: Border.all(
              color: _disabled
                  ? theme.textDisabled
                  : (error
                        ? theme.error
                        : (selected ? theme.primary : theme.borderControl)),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(theme.radiusSm),
          ),
          child: selected
              ? Icon(
                  indeterminate ? Icons.remove : Icons.check,
                  size: 16,
                  color: _disabled ? theme.textDisabled : theme.textInverse,
                )
              : null,
        ),
      ),
    );
    final content = Row(
      children: [
        control,
        if (label != null)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: theme.spacingSm),
              child: _label(theme),
            ),
          ),
      ],
    );
    return Semantics(
      container: true,
      checked: selected,
      enabled: !_disabled,
      label: semanticsLabel ?? label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _disabled ? null : () => onChanged!(!value),
        child: content,
      ),
    );
  }

  Widget _label(UiKitThemeData theme) {
    final labelStyle = theme.bodyMedium.copyWith(
      color: _disabled ? theme.textDisabled : theme.text,
    );
    final descriptionStyle = theme.caption.copyWith(
      color: _disabled ? theme.textDisabled : theme.textMuted,
    );
    if (description == null) return Text(label!, style: labelStyle);
    if (inlineDescription)
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(text: label, style: labelStyle),
            TextSpan(text: "  $description", style: descriptionStyle),
          ],
        ),
      );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label!, style: labelStyle),
        SizedBox(height: theme.spacing2xs),
        Text(description!, style: descriptionStyle),
      ],
    );
  }
}
