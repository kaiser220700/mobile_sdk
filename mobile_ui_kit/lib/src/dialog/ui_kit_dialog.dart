import "dart:async";

import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/button/ui_kit_button.dart";
import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

enum UiKitDialogSemantic { none, success, warning, error, info }

class UiKitDialogAction {
  const UiKitDialogAction({
    required this.label,
    required this.onPressed,
    this.variant = UiKitButtonVariant.secondary,
  });
  final String label;
  final FutureOr<void> Function() onPressed;
  final UiKitButtonVariant variant;
}

class UiKitDialog {
  const UiKitDialog._();

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? description,
    UiKitDialogSemantic semantic = UiKitDialogSemantic.none,
    IconData? icon,
    List<UiKitDialogAction> actions = const [],
    bool showClose = false,
    bool dismissible = true,
    Color barrierColor = Colors.black54,
    Duration transitionDuration = const Duration(milliseconds: 200),
    EdgeInsets insetPadding = const EdgeInsets.symmetric(horizontal: 24),
    double minWidth = 280,
    double maxWidth = 320,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    double? borderRadius,
    Color? semanticColor,
    TextStyle? titleStyle,
    TextStyle? descriptionStyle,
    double iconSize = 40,
    IconData closeIcon = Icons.close,
  }) {
    assert(actions.length <= 2, "Dialogs support at most two actions.");
    assert(minWidth > 0 && maxWidth >= minWidth && iconSize > 0);
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: dismissible,
      barrierLabel: title,
      barrierColor: barrierColor,
      transitionDuration: transitionDuration,
      pageBuilder: (context, _, __) => _DialogView(
        title: title,
        description: description,
        semantic: semantic,
        icon: icon,
        actions: actions,
        showClose: showClose,
        insetPadding: insetPadding,
        minWidth: minWidth,
        maxWidth: maxWidth,
        padding: padding,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        semanticColor: semanticColor,
        titleStyle: titleStyle,
        descriptionStyle: descriptionStyle,
        iconSize: iconSize,
        closeIcon: closeIcon,
      ),
      transitionBuilder: (context, animation, _, child) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: .95, end: 1.0).animate(animation),
          child: child,
        ),
      ),
    );
  }
}

class _DialogView extends StatefulWidget {
  const _DialogView({
    required this.title,
    required this.description,
    required this.semantic,
    required this.icon,
    required this.actions,
    required this.showClose,
    required this.insetPadding,
    required this.minWidth,
    required this.maxWidth,
    required this.padding,
    required this.backgroundColor,
    required this.borderRadius,
    required this.semanticColor,
    required this.titleStyle,
    required this.descriptionStyle,
    required this.iconSize,
    required this.closeIcon,
  });
  final String title;
  final String? description;
  final UiKitDialogSemantic semantic;
  final IconData? icon;
  final List<UiKitDialogAction> actions;
  final bool showClose;
  final EdgeInsets insetPadding;
  final double minWidth;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double? borderRadius;
  final Color? semanticColor;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
  final double iconSize;
  final IconData closeIcon;

  @override
  State<_DialogView> createState() => _DialogViewState();
}

class _DialogViewState extends State<_DialogView> {
  int _pending = -1;

  Color _color(UiKitThemeData theme) => switch (widget.semantic) {
    UiKitDialogSemantic.none => theme.text,
    UiKitDialogSemantic.success => theme.success,
    UiKitDialogSemantic.warning => theme.warning,
    UiKitDialogSemantic.error => theme.error,
    UiKitDialogSemantic.info => theme.info,
  };
  IconData? get _icon =>
      widget.icon ??
      switch (widget.semantic) {
        UiKitDialogSemantic.none => null,
        UiKitDialogSemantic.success => Icons.check_circle,
        UiKitDialogSemantic.warning => Icons.warning_amber,
        UiKitDialogSemantic.error => Icons.error,
        UiKitDialogSemantic.info => Icons.info,
      };

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final color = widget.semanticColor ?? _color(theme);
    return Dialog(
      backgroundColor: widget.backgroundColor ?? theme.surface,
      insetPadding: widget.insetPadding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          widget.borderRadius ?? theme.radiusXl,
        ),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: widget.minWidth,
          maxWidth: widget.maxWidth,
        ),
        child: Padding(
          padding: widget.padding ?? EdgeInsets.all(theme.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showClose)
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: _pending == -1
                        ? () => Navigator.of(context).pop()
                        : null,
                    icon: Icon(widget.closeIcon, size: 18),
                  ),
                ),
              if (_icon != null) ...[
                Icon(_icon, size: widget.iconSize, color: color),
                SizedBox(height: theme.spacingMd),
              ],
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: (widget.titleStyle ?? theme.bodyLarge).copyWith(
                  color: theme.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.description != null) ...[
                SizedBox(height: theme.spacingSm),
                Text(
                  widget.description!,
                  textAlign: TextAlign.center,
                  style: (widget.descriptionStyle ?? theme.body).copyWith(
                    color: theme.textMuted,
                  ),
                ),
              ],
              if (widget.actions.isNotEmpty) ...[
                SizedBox(height: theme.spacingXl),
                for (var i = 0; i < widget.actions.length; i++)
                  Padding(
                    padding: EdgeInsets.only(top: i == 0 ? 0 : theme.spacingSm),
                    child: _action(i, widget.actions[i]),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _action(int index, UiKitDialogAction action) => UiKitButton(
    label: action.label,
    variant: action.variant,
    fullWidth: true,
    loading: _pending == index,
    disabled: _pending != -1 && _pending != index,
    onPressed: () async {
      setState(() => _pending = index);
      await action.onPressed();
      if (mounted) Navigator.of(context).pop();
    },
  );
}
