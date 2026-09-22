import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/pressable/ui_kit_pressable.dart";
import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

enum UiKitButtonVariant {
  primary,
  secondary,
  tertiary,
  outline,
  ghost,
  danger,
  success,
}

enum UiKitButtonSize { sm, md, lg }

/// Basic visual button with app-overridable theme tokens.
class UiKitButton extends StatelessWidget {
  const UiKitButton({
    required this.onPressed,
    this.label,
    this.variant = UiKitButtonVariant.primary,
    this.size = UiKitButtonSize.md,
    this.iconLeft,
    this.iconRight,
    this.fullWidth = false,
    this.loading = false,
    this.disabled = false,
    this.semanticsLabel,
    super.key,
  }) : assert(
         label != null || semanticsLabel != null,
         "Icon-only buttons need semanticsLabel.",
       );

  const UiKitButton.text({
    required VoidCallback? onPressed,
    required String label,
    UiKitButtonVariant variant = UiKitButtonVariant.primary,
    UiKitButtonSize size = UiKitButtonSize.md,
    bool fullWidth = false,
    bool loading = false,
    bool disabled = false,
    Key? key,
  }) : this(
         onPressed: onPressed,
         label: label,
         variant: variant,
         size: size,
         fullWidth: fullWidth,
         loading: loading,
         disabled: disabled,
         key: key,
       );

  const UiKitButton.icon({
    required VoidCallback? onPressed,
    required IconData icon,
    required String semanticsLabel,
    UiKitButtonVariant variant = UiKitButtonVariant.primary,
    UiKitButtonSize size = UiKitButtonSize.md,
    bool loading = false,
    bool disabled = false,
    Key? key,
  }) : this(
         onPressed: onPressed,
         iconLeft: icon,
         variant: variant,
         size: size,
         loading: loading,
         disabled: disabled,
         semanticsLabel: semanticsLabel,
         key: key,
       );

  final VoidCallback? onPressed;
  final String? label;
  final UiKitButtonVariant variant;
  final UiKitButtonSize size;
  final IconData? iconLeft;
  final IconData? iconRight;
  final bool fullWidth;
  final bool loading;
  final bool disabled;
  final String? semanticsLabel;

  bool get _isDisabled => disabled || loading || onPressed == null;

  double get _height => switch (size) {
    UiKitButtonSize.sm => 32,
    UiKitButtonSize.md => 44,
    UiKitButtonSize.lg => 52,
  };

  double _horizontalPadding(UiKitThemeData theme) => switch (size) {
    UiKitButtonSize.sm => theme.spacingMd,
    UiKitButtonSize.md => theme.spacingLg,
    UiKitButtonSize.lg => theme.spacingXl,
  };

  double get _iconSize => switch (size) {
    UiKitButtonSize.sm => 16,
    UiKitButtonSize.md => 20,
    UiKitButtonSize.lg => 24,
  };

  TextStyle _textStyle(UiKitThemeData theme) =>
      size == UiKitButtonSize.lg ? theme.buttonLarge : theme.button;

  ({Color background, Color foreground, Color border, bool hasBorder}) _colors(
    UiKitThemeData theme,
  ) {
    if (_isDisabled) {
      return (
        background:
            variant == UiKitButtonVariant.ghost ||
                variant == UiKitButtonVariant.outline
            ? Colors.transparent
            : theme.textDisabled,
        foreground:
            variant == UiKitButtonVariant.ghost ||
                variant == UiKitButtonVariant.outline
            ? theme.textDisabled
            : theme.textInverse,
        border: theme.textDisabled,
        hasBorder: variant == UiKitButtonVariant.outline,
      );
    }
    return switch (variant) {
      UiKitButtonVariant.primary => (
        background: theme.primary,
        foreground: theme.textInverse,
        border: theme.primary,
        hasBorder: false,
      ),
      UiKitButtonVariant.secondary => (
        background: theme.surfaceMuted,
        foreground: theme.text,
        border: theme.surfaceMuted,
        hasBorder: false,
      ),
      UiKitButtonVariant.tertiary => (
        background: theme.primaryBg,
        foreground: theme.primary,
        border: theme.primaryBg,
        hasBorder: false,
      ),
      UiKitButtonVariant.outline => (
        background: Colors.transparent,
        foreground: theme.primary,
        border: theme.primary,
        hasBorder: true,
      ),
      UiKitButtonVariant.ghost => (
        background: Colors.transparent,
        foreground: theme.primary,
        border: Colors.transparent,
        hasBorder: false,
      ),
      UiKitButtonVariant.danger => (
        background: theme.error,
        foreground: theme.textInverse,
        border: theme.error,
        hasBorder: false,
      ),
      UiKitButtonVariant.success => (
        background: theme.success,
        foreground: theme.textInverse,
        border: theme.success,
        hasBorder: false,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final colors = _colors(theme);
    final content = loading
        ? SizedBox.square(
            dimension: _iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.foreground,
            ),
          )
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconLeft != null)
                Icon(iconLeft, size: _iconSize, color: colors.foreground),
              if (iconLeft != null && label != null)
                SizedBox(width: theme.spacingSm),
              if (label != null)
                Text(
                  label!,
                  style: _textStyle(theme).copyWith(color: colors.foreground),
                ),
              if (iconRight != null && label != null)
                SizedBox(width: theme.spacingSm),
              if (iconRight != null)
                Icon(iconRight, size: _iconSize, color: colors.foreground),
            ],
          );

    final button = UiKitPressable(
      onPress: _isDisabled ? null : onPressed,
      semanticsLabel: semanticsLabel ?? label,
      builder: (context, states, child) => ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: size == UiKitButtonSize.sm ? 40 : 44,
          minHeight: _height,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.background,
            border: colors.hasBorder
                ? Border.all(color: colors.border, width: 1.5)
                : null,
            borderRadius: BorderRadius.circular(theme.radiusFull),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _horizontalPadding(theme),
            ),
            child: Center(child: content),
          ),
        ),
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
