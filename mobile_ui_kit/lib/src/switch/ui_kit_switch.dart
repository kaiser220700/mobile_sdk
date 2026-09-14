import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

enum UiKitSwitchSize { sm, md }

class UiKitSwitch extends StatelessWidget {
  const UiKitSwitch({
    required this.value,
    this.onChanged,
    this.label,
    this.sublabel,
    this.size = UiKitSwitchSize.md,
    this.disabled = false,
    this.semanticsLabel,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final String? sublabel;
  final UiKitSwitchSize size;
  final bool disabled;
  final String? semanticsLabel;

  bool get _enabled => !disabled && onChanged != null;
  double get _width => size == UiKitSwitchSize.sm ? 32 : 40;
  double get _height => size == UiKitSwitchSize.sm ? 20 : 24;
  double get _thumb => size == UiKitSwitchSize.sm ? 16 : 20;

  void _toggle() {
    if (_enabled) onChanged!(!value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final track = Semantics(
      toggled: value,
      enabled: _enabled,
      label: semanticsLabel ?? label,
      child: GestureDetector(
        onTap: _toggle,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: theme.touchMinTarget,
          height: theme.touchMinTarget,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: _width,
              height: _height,
              padding: EdgeInsets.all(theme.spacing2xs),
              decoration: BoxDecoration(
                color: disabled
                    ? theme.textDisabled
                    : (value ? theme.primary : theme.border),
                borderRadius: BorderRadius.circular(theme.radiusFull),
              ),
              child: AnimatedAlign(
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  width: _thumb,
                  height: _thumb,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: disabled ? theme.textDisabled : theme.surface,
                    boxShadow: const [
                      BoxShadow(color: Color(0x22000000), blurRadius: 2),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (label == null && sublabel == null) return track;
    return GestureDetector(
      onTap: _toggle,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: theme.bodyMedium.copyWith(
                      color: disabled ? theme.textDisabled : theme.text,
                    ),
                  ),
                if (sublabel != null)
                  Padding(
                    padding: EdgeInsets.only(top: theme.spacing2xs),
                    child: Text(
                      sublabel!,
                      style: theme.caption.copyWith(
                        color: disabled ? theme.textDisabled : theme.textMuted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: theme.spacingMd),
          track,
        ],
      ),
    );
  }
}
