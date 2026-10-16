import 'package:flutter/material.dart';
import 'package:mobile_devtool/mobile_devtool.dart' as dev;
import 'package:mobile_fuzz/mobile_fuzz.dart' as fuzz;
import 'package:mobile_screen_draw/mobile_screen_draw.dart' as draw;

/// Example-owned composition: each optional tool can be removed independently.
class DeveloperTools extends StatefulWidget {
  const DeveloperTools({
    required this.controller,
    this.configuration = const dev.Configuration(),
    this.navigatorKey,
    this.enabled = true,
    this.showLauncher = true,
    super.key,
  });
  final dev.Controller controller;
  final dev.Configuration configuration;
  final GlobalKey<NavigatorState>? navigatorKey;
  final bool enabled;
  final bool showLauncher;

  @override
  State<DeveloperTools> createState() => _DeveloperToolsState();
}

class _DeveloperToolsState extends State<DeveloperTools> {
  late final _drawing = draw.Controller(
    accentColor: widget.configuration.accentColor,
  );
  final _log = fuzz.SessionLog();
  late final _runner = fuzz.Runner(
    log: _log,
    networkFailures: () => widget.controller.networkEntries
        .where((entry) => entry.status == dev.NetworkStatus.error)
        .map(
          (entry) => fuzz.NetworkFailure(
            id: entry.id,
            message: '${entry.request.label} — ${entry.error}',
          ),
        ),
  );
  bool _fuzzOpen = false;

  @override
  void dispose() {
    _runner.stop();
    _log.dispose();
    _drawing.dispose();
    super.dispose();
  }

  void _openFuzz() {
    _runner.stop();
    _log.resetCurrentSession();
    setState(() => _fuzzOpen = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return const SizedBox.shrink();
    final config = widget.configuration;
    return fuzz.ExcludeFromFuzzTap(
      child: AnimatedBuilder(
        animation: _drawing,
        builder: (context, _) => Stack(
          fit: StackFit.expand,
          children: [
            dev.ToolsOverlay(
              controller: widget.controller,
              navigatorKey: widget.navigatorKey,
              showLauncher:
                  widget.showLauncher && !_drawing.overlayActive && !_fuzzOpen,
              configuration: dev.Configuration(
                title: config.title,
                hostActions: config.hostActions,
                panels: [
                  ...config.panels,
                  dev.Panel(
                    id: 'fuzz-history',
                    label: 'Fuzz Tap Log',
                    icon: Icons.receipt_long,
                    builder: (_) => fuzz.SessionLogPanel(log: _log),
                  ),
                ],
                quickActions: [
                  ...config.quickActions,
                  dev.MenuItem(
                    id: 'screen-draw',
                    label: 'Screen Draw',
                    icon: Icons.gesture,
                    onSelect: _drawing.showOverlay,
                  ),
                  dev.MenuItem(
                    id: 'fuzz-tap',
                    label: 'Fuzz Tap',
                    icon: Icons.smart_toy,
                    onSelect: _openFuzz,
                  ),
                ],
                menuItems: config.menuItems,
                hiddenMenuItemIds: config.hiddenMenuItemIds,
                featureFlags: config.featureFlags,
                accentColor: config.accentColor,
                bubbleBackgroundColor: config.bubbleBackgroundColor,
                bubbleForegroundColor: config.bubbleForegroundColor,
                bubbleBorderColor: config.bubbleBorderColor,
                themeBuilder: config.themeBuilder,
              ),
            ),
            if (_fuzzOpen)
              fuzz.RunnerOverlay(
                runner: _runner,
                log: _log,
                onClose: () {
                  _runner.stop();
                  setState(() => _fuzzOpen = false);
                },
              ),
            if (_drawing.overlayActive) draw.DrawingOverlay(tool: _drawing),
          ],
        ),
      ),
    );
  }
}
