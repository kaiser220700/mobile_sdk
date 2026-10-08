import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/pressable/ui_kit_pressable.dart";
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
    this.width,
    this.height,
    this.thumbSize,
    this.touchTargetSize,
    this.padding,
    this.activeColor,
    this.inactiveColor,
    this.disabledColor,
    this.thumbColor,
    this.labelStyle,
    this.sublabelStyle,
    this.gap,
    this.animationDuration = const Duration(milliseconds: 150),
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final String? sublabel;
  final UiKitSwitchSize size;
  final bool disabled;
  final String? semanticsLabel;
  final double? width;
  final double? height;
  final double? thumbSize;
  final double? touchTargetSize;
  final EdgeInsetsGeometry? padding;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? disabledColor;
  final Color? thumbColor;
  final TextStyle? labelStyle;
  final TextStyle? sublabelStyle;
  final double? gap;
  final Duration animationDuration;

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
    final track = SizedBox(
      width: touchTargetSize ?? theme.touchMinTarget,
      height: touchTargetSize ?? theme.touchMinTarget,
      child: Center(
        child: AnimatedContainer(
          duration: animationDuration,
          width: width ?? _width,
          height: height ?? _height,
          padding: padding ?? EdgeInsets.all(theme.spacing2xs),
          decoration: BoxDecoration(
            color: disabled
                ? disabledColor ?? theme.textDisabled
                : (value
                      ? activeColor ?? theme.primary
                      : inactiveColor ?? theme.border),
            borderRadius: BorderRadius.circular(theme.radiusFull),
          ),
          child: AnimatedAlign(
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            duration: animationDuration,
            child: Container(
              width: thumbSize ?? _thumb,
              height: thumbSize ?? _thumb,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: disabled
                    ? disabledColor ?? theme.textDisabled
                    : thumbColor ?? theme.surface,
                boxShadow: const [
                  BoxShadow(color: Color(0x22000000), blurRadius: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    final content = label == null && sublabel == null
        ? track
        : Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (label != null)
                      Text(
                        label!,
                        style: (labelStyle ?? theme.bodyMedium).copyWith(
                          color: disabled ? theme.textDisabled : theme.text,
                        ),
                      ),
                    if (sublabel != null)
                      Padding(
                        padding: EdgeInsets.only(top: theme.spacing2xs),
                        child: Text(
                          sublabel!,
                          style: (sublabelStyle ?? theme.caption).copyWith(
                            color: disabled
                                ? theme.textDisabled
                                : theme.textMuted,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: gap ?? theme.spacingMd),
              track,
            ],
          );
    return UiKitPressable(
      onPress: _enabled ? _toggle : null,
      selected: value,
      toggled: value,
      semanticsLabel: semanticsLabel ?? label,
      builder: (context, states, child) => content,
    );
  }
}
