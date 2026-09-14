import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

/// Select field primitive. The host owns the option sheet/menu and feeds the
/// selected value back through [value] and [onTap].
class UiKitSelectField extends StatelessWidget {
  const UiKitSelectField({
    required this.label,
    required this.onTap,
    this.value,
    this.placeholder = "Select...",
    this.helperText,
    this.errorText,
    this.leading,
    this.open = false,
    this.enabled = true,
    this.isRequired = false,
    this.semanticsLabel,
    super.key,
  });

  final String label;
  final String? value;
  final String placeholder;
  final String? helperText;
  final String? errorText;
  final Widget? leading;
  final VoidCallback? onTap;
  final bool open;
  final bool enabled;
  final bool isRequired;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final foreground = enabled ? theme.text : theme.textDisabled;
    final borderColor = errorText == null ? theme.border : theme.error;
    final displayValue = value ?? placeholder;
    final hasValue = value != null && value!.isNotEmpty;
    final field = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      constraints: BoxConstraints(minHeight: theme.touchMinTarget),
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacingMd,
        vertical: theme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: enabled ? theme.surface : theme.surfaceMuted,
        border: Border.all(color: borderColor, width: open ? 2 : 1),
        borderRadius: BorderRadius.circular(theme.radiusMd),
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            IconTheme.merge(
              data: IconThemeData(color: theme.textMuted),
              child: leading!,
            ),
            SizedBox(width: theme.spacingSm),
          ],
          Expanded(
            child: Text(
              displayValue,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.body.copyWith(
                color: hasValue ? foreground : theme.textMuted,
              ),
            ),
          ),
          SizedBox(width: theme.spacingSm),
          Icon(
            open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: foreground,
          ),
        ],
      ),
    );
    return Semantics(
      button: true,
      enabled: enabled && onTap != null,
      label: semanticsLabel ?? "$label: $displayValue",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: label,
              style: theme.bodyMedium.copyWith(
                color: enabled ? theme.text : theme.textDisabled,
              ),
              children: isRequired
                  ? [
                      TextSpan(
                        text: " *",
                        style: TextStyle(color: theme.error),
                      ),
                    ]
                  : null,
            ),
          ),
          SizedBox(height: theme.spacingXs),
          GestureDetector(
            onTap: enabled ? onTap : null,
            behavior: HitTestBehavior.opaque,
            child: field,
          ),
          if (errorText != null || helperText != null) ...[
            SizedBox(height: theme.spacingXs),
            Text(
              errorText ?? helperText!,
              style: theme.caption.copyWith(
                color: errorText == null ? theme.textMuted : theme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
