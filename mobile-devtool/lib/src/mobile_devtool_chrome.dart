import "dart:async";

import "package:material_ui/material_ui.dart";

import "mobile_devtool_bubble.dart";
import "mobile_devtool_configuration.dart";
import "mobile_devtool_controller.dart";
import "mobile_devtool_root_menu.dart";
import "mobile_devtool_theme.dart";
import "mobile_devtool_ui_state.dart";

/// Non-production launcher and tool menu. Hosts compose optional tool overlays.
class MobileDevToolChrome extends StatefulWidget {
  const MobileDevToolChrome({
    required this.controller,
    this.enabled = true,
    this.configuration = const MobileDevToolConfiguration(),
    this.navigatorKey,
    this.showLauncher = true,
    super.key,
  });

  final MobileDevToolController controller;
  final bool enabled;
  final MobileDevToolConfiguration configuration;
  final GlobalKey<NavigatorState>? navigatorKey;
  final bool showLauncher;

  /// Host owns removal/disposal of the returned entry.
  static OverlayEntry attach({
    required GlobalKey<NavigatorState> navigatorKey,
    required WidgetBuilder builder,
  }) {
    final entry = _DeferredOverlayEntry(
      builder: (context) => Positioned.fill(child: Builder(builder: builder)),
    );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => entry.insertInto(navigatorKey.currentState?.overlay),
    );
    return entry;
  }

  @override
  State<MobileDevToolChrome> createState() => _MobileDevToolChromeState();
}

class _MobileDevToolChromeState extends State<MobileDevToolChrome> {
  final _position = MobileDevToolBubblePosition(const Offset(20, 100));
  final _idle = MobileDevToolBubbleIdle();
  bool _menuOpen = false;

  @override
  void dispose() {
    _position.dispose();
    _idle.dispose();
    super.dispose();
  }

  Future<void> _openMenu() async {
    setState(() => _menuOpen = true);
    try {
      await MobileDevToolRootMenu.show(
        widget.navigatorKey?.currentContext ?? context,
        controller: widget.controller,
        configuration: widget.configuration,
      );
    } finally {
      if (mounted) setState(() => _menuOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return const SizedBox.shrink();
    final hostTheme = widget.configuration.themeBuilder?.call(context);
    final theme =
        hostTheme ??
        MobileDevToolTheme.data(
          context,
          accentColor: widget.configuration.accentColor,
        );
    return Theme(
      data: theme,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.showLauncher && !_menuOpen)
            MobileDevToolBubble(
              controller: widget.controller,
              position: _position,
              idle: _idle,
              accentColor: widget.configuration.accentColor,
              backgroundColor:
                  widget.configuration.bubbleBackgroundColor ??
                  hostTheme?.colorScheme.surface,
              foregroundColor:
                  widget.configuration.bubbleForegroundColor ??
                  hostTheme?.colorScheme.primary,
              borderColor:
                  widget.configuration.bubbleBorderColor ??
                  hostTheme?.colorScheme.outline,
              onTap: () => unawaited(_openMenu()),
            ),
        ],
      ),
    );
  }
}

// Handles owners that disappear before the deferred insertion frame.
class _DeferredOverlayEntry extends OverlayEntry {
  _DeferredOverlayEntry({required super.builder});
  bool _cancelled = false;
  bool _inserted = false;

  void insertInto(OverlayState? overlay) {
    if (_cancelled || overlay == null || !overlay.mounted) return;
    overlay.insert(this);
    _inserted = true;
  }

  @override
  void remove() {
    _cancelled = true;
    if (!_inserted) return;
    _inserted = false;
    super.remove();
  }

  @override
  void dispose() {
    remove();
    super.dispose();
  }
}
