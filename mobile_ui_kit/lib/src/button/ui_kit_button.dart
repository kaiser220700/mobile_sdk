import "package:material_ui/material_ui.dart";

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

/// Controls whether loading replaces the button content or is shown before it.
///
/// [replaceContent] preserves the historical kit appearance. Hosts whose
/// design system requires the action label to remain readable while submitting
/// can opt into [showBeforeContent].
enum UiKitButtonLoadingBehavior {
  replaceContent,
  showBeforeContent,

  /// Keep the content and colors, disable activation, and let the host own
  /// the loading presentation (for example, a full-screen overlay).
  external,
}

/// Basic visual button with app-overridable theme tokens.
class UiKitButton extends StatelessWidget {
  const UiKitButton({
    required this.onPressed,
    this.label,
    this.child,
    this.variant = UiKitButtonVariant.primary,
    this.size = UiKitButtonSize.md,
    this.iconLeft,
    this.iconRight,
    this.fullWidth = false,
    this.loading = false,
    this.loadingBehavior = UiKitButtonLoadingBehavior.replaceContent,
    this.loadingIndicator,
    this.disabled = false,
    this.outlineBorderColor,
    this.outlineBorderWidth = 1,
    this.height,
    this.minWidth,
    this.horizontalPadding,
    this.iconSize,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.tapThrottleDuration,
    this.semanticsLabel,
    super.key,
  }) : assert(
         label != null || child != null || semanticsLabel != null,
         "Icon-only buttons need semanticsLabel.",
       ),
       assert(label == null || child == null, "Use either label or child."),
       assert(outlineBorderWidth > 0, "outlineBorderWidth must be positive."),
       assert(height == null || height > 0),
       assert(minWidth == null || minWidth > 0),
       assert(iconSize == null || iconSize > 0);

  const UiKitButton.text({
    required VoidCallback? onPressed,
    required String label,
    UiKitButtonVariant variant = UiKitButtonVariant.primary,
    UiKitButtonSize size = UiKitButtonSize.md,
    bool fullWidth = false,
    bool loading = false,
    UiKitButtonLoadingBehavior loadingBehavior =
        UiKitButtonLoadingBehavior.replaceContent,
    Widget? loadingIndicator,
    bool disabled = false,
    Color? outlineBorderColor,
    double outlineBorderWidth = 1,
    Key? key,
  }) : this(
         onPressed: onPressed,
         label: label,
         variant: variant,
         size: size,
         fullWidth: fullWidth,
         loading: loading,
         loadingBehavior: loadingBehavior,
         loadingIndicator: loadingIndicator,
         disabled: disabled,
         outlineBorderColor: outlineBorderColor,
         outlineBorderWidth: outlineBorderWidth,
         key: key,
       );

  const UiKitButton.icon({
    required VoidCallback? onPressed,
    required IconData icon,
    required String semanticsLabel,
    UiKitButtonVariant variant = UiKitButtonVariant.primary,
    UiKitButtonSize size = UiKitButtonSize.md,
    bool loading = false,
    UiKitButtonLoadingBehavior loadingBehavior =
        UiKitButtonLoadingBehavior.replaceContent,
    Widget? loadingIndicator,
    bool disabled = false,
    Color? outlineBorderColor,
    double outlineBorderWidth = 1,
    Key? key,
  }) : this(
         onPressed: onPressed,
         iconLeft: icon,
         variant: variant,
         size: size,
         loading: loading,
         loadingBehavior: loadingBehavior,
         loadingIndicator: loadingIndicator,
         disabled: disabled,
         outlineBorderColor: outlineBorderColor,
         outlineBorderWidth: outlineBorderWidth,
         semanticsLabel: semanticsLabel,
         key: key,
       );

  final VoidCallback? onPressed;
  final String? label;

  /// Custom content, styled with the button foreground and typography.
  /// Use either [child] or [label].
  final Widget? child;
  final UiKitButtonVariant variant;
  final UiKitButtonSize size;
  final IconData? iconLeft;
  final IconData? iconRight;
  final bool fullWidth;
  final bool loading;
  final UiKitButtonLoadingBehavior loadingBehavior;
  final Widget? loadingIndicator;
  final bool disabled;

  /// Optional per-button overrides for the outline variant.
  ///
  /// When omitted, the button uses the host theme's [UiKitThemeData.borderControl]
  /// token at 1 dp.
  final Color? outlineBorderColor;
  final double outlineBorderWidth;
  final double? height;
  final double? minWidth;
  final double? horizontalPadding;
  final double? iconSize;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final Duration? tapThrottleDuration;
  final String? semanticsLabel;

  bool get _isDisabled => disabled || loading || onPressed == null;

  bool get _usesDisabledColors =>
      disabled ||
      onPressed == null ||
      (loading && loadingBehavior == UiKitButtonLoadingBehavior.replaceContent);

  double _height(UiKitThemeData theme) =>
      height ??
      switch (size) {
        UiKitButtonSize.sm => theme.sizes.controlSm,
        UiKitButtonSize.md => theme.sizes.controlMd,
        UiKitButtonSize.lg => theme.sizes.controlLg,
      };

  double _horizontalPadding(UiKitThemeData theme) =>
      horizontalPadding ??
      switch (size) {
        UiKitButtonSize.sm => theme.spacingMd,
        UiKitButtonSize.md => theme.spacingLg,
        UiKitButtonSize.lg => theme.spacingXl,
      };

  double _iconSize(UiKitThemeData theme) =>
      iconSize ??
      switch (size) {
        UiKitButtonSize.sm => theme.sizes.iconSm,
        UiKitButtonSize.md => theme.sizes.iconMd,
        UiKitButtonSize.lg => theme.sizes.iconLg,
      };

  TextStyle _textStyle(UiKitThemeData theme) =>
      size == UiKitButtonSize.lg ? theme.buttonLarge : theme.button;

  ({Color background, Color foreground, Color border, bool hasBorder}) _colors(
    UiKitThemeData theme,
  ) {
    if (_usesDisabledColors) {
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
    final colors = switch (variant) {
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
        border: outlineBorderColor ?? theme.borderControl,
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
    return (
      background: backgroundColor ?? colors.background,
      foreground: foregroundColor ?? colors.foreground,
      border: borderColor ?? colors.border,
      hasBorder: colors.hasBorder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final colors = _colors(theme);
    final indicator =
        loadingIndicator ??
        SizedBox.square(
          dimension: _iconSize(theme),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colors.foreground,
          ),
        );
    final regularContent = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (iconLeft != null)
          Icon(iconLeft, size: _iconSize(theme), color: colors.foreground),
        if (iconLeft != null && (label != null || child != null))
          SizedBox(width: theme.spacingSm),
        if (child != null)
          Flexible(
            child: IconTheme.merge(
              data: IconThemeData(
                size: _iconSize(theme),
                color: colors.foreground,
              ),
              child: DefaultTextStyle(
                style: _textStyle(theme).copyWith(color: colors.foreground),
                child: child!,
              ),
            ),
          ),
        if (label != null)
          Flexible(
            child: Text(
              label!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _textStyle(theme).copyWith(color: colors.foreground),
            ),
          ),
        if (iconRight != null && (label != null || child != null))
          SizedBox(width: theme.spacingSm),
        if (iconRight != null)
          Icon(iconRight, size: _iconSize(theme), color: colors.foreground),
      ],
    );
    final content =
        loading && loadingBehavior == UiKitButtonLoadingBehavior.replaceContent
        ? indicator
        : loading &&
              loadingBehavior == UiKitButtonLoadingBehavior.showBeforeContent
        ? Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              indicator,
              SizedBox(width: theme.spacingSm),
              Flexible(child: regularContent),
            ],
          )
        : regularContent;

    final button = UiKitPressable(
      onPress: _isDisabled ? null : onPressed,
      tapThrottleDuration:
          tapThrottleDuration ?? const Duration(milliseconds: 300),
      semanticsLabel: semanticsLabel ?? label,
      // Label-based buttons have a complete accessible name here. Custom
      // children retain their semantics unless the host provides an override.
      excludeSemantics: semanticsLabel != null || child == null,
      builder: (context, states, child) => ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth ?? (size == UiKitButtonSize.sm ? 40 : 44),
          minHeight: _height(theme),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.background,
            border: colors.hasBorder
                ? Border.all(color: colors.border, width: outlineBorderWidth)
                : null,
            borderRadius: BorderRadius.circular(
              borderRadius ?? theme.radiusFull,
            ),
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
