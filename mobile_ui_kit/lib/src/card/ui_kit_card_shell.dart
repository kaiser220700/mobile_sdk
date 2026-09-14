import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

class UiKitCardShell extends StatelessWidget {
  const UiKitCardShell({
    required this.child,
    this.border = true,
    this.shadow = false,
    this.padding,
    super.key,
  });

  final Widget child;
  final bool border;
  final bool shadow;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(theme.spacingLg),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(theme.radiusLg),
        border: border ? Border.all(color: theme.border) : null,
        boxShadow: shadow
            ? const [
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
