import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

class UiKitCardShell extends StatelessWidget {
  const UiKitCardShell({
    required this.child,
    this.border = true,
    this.shadow = false,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.borderRadius,
    this.boxShadow,
    super.key,
  }) : assert(borderWidth > 0);

  final Widget child;
  final bool border;
  final bool shadow;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(theme.spacingLg),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? theme.radiusLg),
        border: border
            ? Border.all(color: borderColor ?? theme.border, width: borderWidth)
            : null,
        boxShadow: shadow
            ? boxShadow ??
                  const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ]
            : null,
      ),
      child: child,
    );
  }
}
