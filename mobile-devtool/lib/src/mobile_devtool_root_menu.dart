import "package:flutter/material.dart";

import "mobile_devtool_configuration.dart";
import "mobile_devtool_controller.dart";
import "mobile_devtool_feature_flag_panel.dart";
import "mobile_devtool_fuzz_run_log.dart";
import "mobile_devtool_fuzz_run_log_panel.dart";
import "mobile_devtool_network_log_panel.dart";
import "mobile_devtool_info_panel.dart";
import "mobile_devtool_menu.dart";
import "mobile_devtool_theme.dart";
import "mobile_devtool_toast.dart";
import "mobile_devtool_trace_log_panel.dart";

/// The SDK's own tool bottom sheet — opens the first tool immediately and
/// exposes the remaining tools from the menu button in the header. Deliberately
/// reimplemented rather than reusing an app's stepped-sheet widget, since the
/// SDK cannot depend on app UI.
class MobileDevToolRootMenu extends StatefulWidget {
  const MobileDevToolRootMenu({
    required this.controller,
    required this.configuration,
    this.fuzzRunLog,
    this.onOpenScreenDraw,
    this.onOpenFuzzTap,
    super.key,
  });

  final MobileDevToolController controller;
  final MobileDevToolConfiguration configuration;
  final MobileDevToolFuzzRunLog? fuzzRunLog;
  final VoidCallback? onOpenScreenDraw;
  final VoidCallback? onOpenFuzzTap;

  static Future<void> show(
    BuildContext context, {
    required MobileDevToolController controller,
    required MobileDevToolConfiguration configuration,
    MobileDevToolFuzzRunLog? fuzzRunLog,
    VoidCallback? onOpenScreenDraw,
    VoidCallback? onOpenFuzzTap,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: MobileDevToolTheme.bottomSheetBarrierColor,
    builder: (context) => MobileDevToolRootMenu(
      controller: controller,
      configuration: configuration,
      fuzzRunLog: fuzzRunLog,
      onOpenScreenDraw: onOpenScreenDraw,
      onOpenFuzzTap: onOpenFuzzTap,
    ),
  );

  @override
  State<MobileDevToolRootMenu> createState() => _MobileDevToolRootMenuState();
}

class _MobileDevToolRootMenuState extends State<MobileDevToolRootMenu> {
  late final List<MobileDevToolMenuItem> _pageStack;

  MobileDevToolMenuItem get _current => _pageStack.last;

  List<MobileDevToolMenuItem> get _entries =>
      MobileDevToolMenu.resolve(
            configuration: widget.configuration,
            items: [
              MobileDevToolMenuItem(
                id: MobileDevToolBuiltInIds.network,
                label: "Network",
                icon: Icons.hub_outlined,
                order: 10,
                builder: (_) => MobileDevToolNetworkLogPanel(
                  controller: widget.controller,
                  onOpenDetail: _openNetworkDetail,
                ),
              ),
              MobileDevToolMenuItem(
                id: MobileDevToolBuiltInIds.trace,
                label: "Trace",
                icon: Icons.bug_report_outlined,
                order: 20,
                builder: (_) =>
                    MobileDevToolTraceLogPanel(controller: widget.controller),
              ),
              if (widget.fuzzRunLog case final log?)
                MobileDevToolMenuItem(
                  id: MobileDevToolBuiltInIds.fuzzTapLog,
                  label: "Fuzz Tap Log",
                  icon: Icons.receipt_long_outlined,
                  order: 30,
                  builder: (_) => MobileDevToolFuzzRunLogPanel(log: log),
                ),
              if (widget.onOpenScreenDraw case final onOpen?)
                MobileDevToolMenuItem(
                  id: MobileDevToolBuiltInIds.screenDraw,
                  label: "Screen Draw",
                  icon: Icons.gesture,
                  order: 40,
                  builder: (_) => const SizedBox.shrink(),
                  onSelect: onOpen,
                ),
              if (widget.onOpenFuzzTap case final onOpen?)
                MobileDevToolMenuItem(
                  id: MobileDevToolBuiltInIds.fuzzTap,
                  label: "Fuzz Tap",
                  icon: Icons.smart_toy_outlined,
                  order: 50,
                  builder: (_) => const SizedBox.shrink(),
                  onSelect: onOpen,
                ),
              if (widget.configuration.featureFlags.isNotEmpty)
                MobileDevToolMenuItem(
                  id: MobileDevToolBuiltInIds.featureFlags,
                  label: "Feature Flags",
                  icon: Icons.flag_outlined,
                  order: 60,
                  builder: (_) => MobileDevToolFeatureFlagPanel(
                    flags: widget.configuration.featureFlags,
                  ),
                ),
              MobileDevToolMenuItem(
                id: MobileDevToolBuiltInIds.devToolInfo,
                label: "Dev Tool Info",
                icon: Icons.info_outline,
                // Keep the default Network entry (including a host override)
                // as the initial page when its order falls back to 100.
                order: 100,
                builder: (_) => const MobileDevToolInfoPanel(),
              ),
              for (final panel in widget.configuration.panels)
                MobileDevToolMenuItem(
                  id: panel.id,
                  label: panel.label,
                  icon: panel.icon,
                  order: 200,
                  builder: panel.builder,
                ),
              for (final action in widget.configuration.hostActions)
                MobileDevToolMenuItem(
                  id: "host-action:${action.label}",
                  label: action.label,
                  icon: action.icon,
                  order: 300,
                  onSelect: action.onPressed,
                ),
            ],
          )
          .where(
            (entry) =>
                entry.id != MobileDevToolBuiltInIds.screenDraw ||
                entry.onSelect == null,
          )
          .where(
            (entry) =>
                entry.id != MobileDevToolBuiltInIds.fuzzTap ||
                entry.onSelect == null,
          )
          .toList();

  MobileDevToolMenuItem? _quickAction({
    required String id,
    required String label,
    required IconData icon,
    required VoidCallback? onSelect,
  }) {
    if (onSelect == null) return null;
    final entries = MobileDevToolMenu.resolve(
      configuration: widget.configuration,
      items: [
        MobileDevToolMenuItem(
          id: id,
          label: label,
          icon: icon,
          onSelect: onSelect,
        ),
      ],
    );
    if (entries.length != 1 || entries.single.onSelect == null) return null;
    return entries.single;
  }

  List<MobileDevToolMenuItem> get _quickActions => [
    if (_quickAction(
          id: MobileDevToolBuiltInIds.screenDraw,
          label: "Screen Draw",
          icon: Icons.gesture,
          onSelect: widget.onOpenScreenDraw,
        )
        case final action?)
      action,
    if (_quickAction(
          id: MobileDevToolBuiltInIds.fuzzTap,
          label: "Fuzz Tap",
          icon: Icons.smart_toy_outlined,
          onSelect: widget.onOpenFuzzTap,
        )
        case final action?)
      action,
  ];

  @override
  void initState() {
    super.initState();
    // Network is intentionally the first entry so opening the devtool lands
    // directly in a useful screen instead of requiring a second tap.
    _pageStack = [_entries.first];
  }

  void _select(MobileDevToolMenuItem entry) {
    final onSelect = entry.onSelect;
    if (onSelect != null) {
      _invokeQuickAction(onSelect);
      return;
    }
    setState(() {
      _pageStack
        ..clear()
        ..add(entry);
    });
  }

  void _openNetworkDetail(MobileDevToolNetworkEntry entry) {
    setState(() {
      _pageStack.add(
        MobileDevToolMenuItem(
          id: "network-detail",
          label: "Network detail",
          builder: (_) => MobileDevToolNetworkLogDetail(entry: entry),
        ),
      );
    });
  }

  void _invokeQuickAction(VoidCallback action) {
    Navigator.of(context).pop();
    // Let the sheet finish dismissing before mounting a full-screen overlay in
    // the same Navigator's root Overlay.
    WidgetsBinding.instance.addPostFrameCallback((_) => action());
  }

  void _popPage() {
    if (_pageStack.length <= 1) return;
    setState(_pageStack.removeLast);
  }

  @override
  Widget build(BuildContext context) {
    final quickActions = _quickActions;
    final hostTheme = widget.configuration.themeBuilder?.call(context);
    final theme =
        hostTheme ??
        MobileDevToolTheme.data(
          context,
          accentColor: widget.configuration.accentColor,
        );
    final usesHostTheme = hostTheme != null;

    return MobileDevToolToast(
      child: Theme(
        data: theme,
        child: Material(
          surfaceTintColor: Colors.transparent,
          color: theme.colorScheme.surface,
          borderRadius: MobileDevToolTheme.surfaceRadius,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * .8,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 20),
                    child: _DragHandle(),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Column(
                      children: [
                        SizedBox(
                          height: kMinInteractiveDimension,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_pageStack.length > 1)
                                      IconButton(
                                        tooltip: "Quay lại",
                                        icon: const Icon(Icons.arrow_back),
                                        onPressed: _popPage,
                                      )
                                    else
                                      PopupMenuButton<MobileDevToolMenuItem>(
                                        tooltip: "Chọn chức năng",
                                        icon: const Icon(Icons.menu),
                                        color: theme.colorScheme.surface,
                                        surfaceTintColor: Colors.transparent,
                                        onSelected: _select,
                                        itemBuilder: (context) => [
                                          for (final entry in _entries)
                                            PopupMenuItem<
                                              MobileDevToolMenuItem
                                            >(
                                              value: entry,
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  color: entry.id == _current.id
                                                      ? usesHostTheme
                                                            ? theme
                                                                  .colorScheme
                                                                  .primaryContainer
                                                            : const Color(
                                                                0xFFE3F2FD,
                                                              )
                                                      : null,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 10,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 28,
                                                        child:
                                                            entry.icon == null
                                                            ? null
                                                            : Icon(
                                                                entry.icon,
                                                                color:
                                                                    entry.id ==
                                                                        _current
                                                                            .id
                                                                    ? usesHostTheme
                                                                          ? theme.colorScheme.primary
                                                                          : Colors.blue.shade700
                                                                    : theme
                                                                          .colorScheme
                                                                          .primary,
                                                              ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(entry.label),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              Positioned.fill(
                                left: kMinInteractiveDimension,
                                right: kMinInteractiveDimension,
                                child: IgnorePointer(
                                  child: Center(
                                    child: Text(
                                      _current.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  tooltip: "Đóng",
                                  icon: const Icon(Icons.close, size: 20),
                                  color: usesHostTheme
                                      ? theme.colorScheme.onSurfaceVariant
                                      : MobileDevToolTheme.textMuted,
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (quickActions.isNotEmpty)
                          SizedBox(
                            height: 32,
                            child: Align(
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (final action in quickActions)
                                    IconButton(
                                      tooltip: action.label,
                                      icon: Icon(action.icon),
                                      constraints:
                                          const BoxConstraints.tightFor(
                                            width: 32,
                                            height: 32,
                                          ),
                                      iconSize: 18,
                                      padding: EdgeInsets.zero,
                                      onPressed: action.onSelect == null
                                          ? null
                                          : () => _invokeQuickAction(
                                              action.onSelect!,
                                            ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _current.builder == null
                        ? const SizedBox.shrink()
                        : Builder(builder: _current.builder!),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outline,
          borderRadius: BorderRadius.circular(MobileDevToolTheme.radiusFull),
        ),
      ),
    );
  }
}
