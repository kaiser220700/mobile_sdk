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
  }) {
    assert(actions.length <= 2, "Dialogs support at most two actions.");
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: dismissible,
      barrierLabel: title,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, _, __) => _DialogView(
        title: title,
        description: description,
        semantic: semantic,
        icon: icon,
        actions: actions,
        showClose: showClose,
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
  });
  final String title;
  final String? description;
  final UiKitDialogSemantic semantic;
  final IconData? icon;
  final List<UiKitDialogAction> actions;
  final bool showClose;

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
    final color = _color(theme);
    return Dialog(
      backgroundColor: theme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(theme.radiusXl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 320),
        child: Padding(
          padding: EdgeInsets.all(theme.spacingXl),
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
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ),
              if (_icon != null) ...[
                Icon(_icon, size: 40, color: color),
                SizedBox(height: theme.spacingMd),
              ],
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: theme.bodyLarge.copyWith(
                  color: theme.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.description != null) ...[
                SizedBox(height: theme.spacingSm),
                Text(
                  widget.description!,
                  textAlign: TextAlign.center,
                  style: theme.body.copyWith(color: theme.textMuted),
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
