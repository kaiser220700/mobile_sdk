import "dart:async";

import "package:material_ui/material_ui.dart";

/// A small in-tree toast host for devtool feedback.
///
/// The host keeps feedback local to the widget subtree, so devtool panels do
/// not need to depend on a host scaffold.
class ToolToast extends StatefulWidget {
  const ToolToast({
    required this.child,
    super.key,
    this.duration = const Duration(seconds: 2),
  });

  final Widget child;
  final Duration duration;

  /// Shows a toast in the nearest [ToolToast] ancestor.
  static void show(BuildContext context, String message) {
    context.findAncestorStateOfType<_ToolToastState>()?._show(message);
  }

  @override
  State<ToolToast> createState() => _ToolToastState();
}

class _ToolToastState extends State<ToolToast> {
  final _overlayController = OverlayPortalController();
  Timer? _dismissTimer;
  String? _message;

  void _show(String message) {
    _dismissTimer?.cancel();
    if (!_overlayController.isShowing) _overlayController.show();
    setState(() => _message = message);
    _dismissTimer = Timer(widget.duration, () {
      if (!mounted) return;
      setState(() => _message = null);
      _overlayController.hide();
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (context) => Positioned.fill(
        child: Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            bottom: false,
            child: IgnorePointer(
              ignoring: _message == null,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _message == null
                    ? const SizedBox.shrink(
                        key: ValueKey("mobile-devtool-toast-empty"),
                      )
                    : Material(
                        key: ValueKey(_message),
                        color: Colors.transparent,
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Text(_message!),
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
      child: widget.child,
    );
  }
}
