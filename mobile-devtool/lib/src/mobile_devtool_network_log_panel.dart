import "dart:async";

import "package:flutter/material.dart";

import "mobile_devtool_clipboard.dart";
import "mobile_devtool_controller.dart";
import "mobile_devtool_json_formatter.dart";
import "mobile_devtool_ui_state.dart";
import "mobile_devtool_toast.dart";

/// Builds the cURL command for [entry] — the host supplies real base URLs and
/// a currently-valid bearer token; the SDK never knows either.
typedef MobileDevToolCurlBuilder =
    String Function(MobileDevToolNetworkEntry entry);

/// Opens the detail page for a network entry in the host tool sheet.
typedef MobileDevToolNetworkDetailOpener =
    void Function(MobileDevToolNetworkEntry entry);

class MobileDevToolNetworkLogPanel extends StatefulWidget {
  const MobileDevToolNetworkLogPanel({
    required this.controller,
    this.kind,
    this.curlBuilder,
    this.onOpenDetail,
    super.key,
  });

  final MobileDevToolController controller;
  final MobileDevToolNetworkKind? kind;
  final MobileDevToolCurlBuilder? curlBuilder;
  final MobileDevToolNetworkDetailOpener? onOpenDetail;

  @override
  State<MobileDevToolNetworkLogPanel> createState() =>
      _MobileDevToolNetworkLogPanelState();
}

class _MobileDevToolNetworkLogPanelState
    extends State<MobileDevToolNetworkLogPanel> {
  final _statusFilter =
      MobileDevToolNetworkStatusFilter<MobileDevToolNetworkStatus>();

  @override
  void dispose() {
    _statusFilter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.controller, _statusFilter]),
      builder: (context, _) {
        final allLogs = widget.controller.networkEntries;
        final kindLogs = widget.kind == null
            ? allLogs
            : allLogs
                  .where((e) => e.request.kind == widget.kind)
                  .toList(growable: false);
        final statusFilter = _statusFilter.value;
        final logs = kindLogs
            .where((e) => statusFilter == null || e.status == statusFilter)
            .toList();

        return Column(
          children: [
            _StatusFilterTabs(logs: kindLogs, filter: _statusFilter),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: logs.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text("Chưa có network log"),
                            ),
                          )
                        : ListView.builder(
                            itemCount: logs.length,
                            padding: const EdgeInsets.only(bottom: 72),
                            itemBuilder: (context, index) => _LogCard(
                              entry: logs[index],
                              showKind: widget.kind == null,
                              curlBuilder: widget.curlBuilder,
                              onOpenDetail: widget.onOpenDetail,
                            ),
                          ),
                  ),
                  if (kindLogs.isNotEmpty)
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: FloatingActionButton.small(
                        heroTag: "clear-network-${widget.kind?.name ?? 'all'}",
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                        tooltip: "Xóa network log",
                        onPressed: () {
                          final kind = widget.kind;
                          if (kind == null) {
                            widget.controller.clearNetwork();
                          } else {
                            widget.controller.clearNetworkKind(kind);
                          }
                        },
                        child: const Icon(Icons.delete_outline),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatusFilterTabs extends StatelessWidget {
  const _StatusFilterTabs({required this.logs, required this.filter});

  final List<MobileDevToolNetworkEntry> logs;
  final MobileDevToolNetworkStatusFilter<MobileDevToolNetworkStatus> filter;

  @override
  Widget build(BuildContext context) {
    final successCount = logs
        .where((e) => e.status == MobileDevToolNetworkStatus.success)
        .length;
    final errorCount = logs
        .where((e) => e.status == MobileDevToolNetworkStatus.error)
        .length;
    final pendingCount = logs
        .where((e) => e.status == MobileDevToolNetworkStatus.pending)
        .length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        children: [
          _StatusFilterChip(
            label: Text("All (${logs.length})"),
            selected: filter.value == null,
            onTap: () => filter.value = null,
          ),
          _StatusFilterChip(
            label: Text("OK ($successCount)"),
            selected: filter.value == MobileDevToolNetworkStatus.success,
            onTap: () => filter.value = MobileDevToolNetworkStatus.success,
          ),
          _StatusFilterChip(
            label: Text("Err ($errorCount)"),
            selected: filter.value == MobileDevToolNetworkStatus.error,
            onTap: () => filter.value = MobileDevToolNetworkStatus.error,
          ),
          _StatusFilterChip(
            label: Text("Pend ($pendingCount)"),
            selected: filter.value == MobileDevToolNetworkStatus.pending,
            onTap: () => filter.value = MobileDevToolNetworkStatus.pending,
          ),
        ],
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  const _StatusFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Widget label;
  final bool selected;
  final VoidCallback onTap;

  static final _pillBorderRadius = BorderRadius.circular(999);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            border: selected ? null : Border.all(color: colorScheme.outline),
            borderRadius: _pillBorderRadius,
            color: selected ? null : colorScheme.surface,
            gradient: selected
                ? const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFFFFE082), Color(0xFFFFB300)],
                  )
                : null,
          ),
          child: InkWell(
            borderRadius: _pillBorderRadius,
            onTap: onTap,
            splashFactory: NoSplash.splashFactory,
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              child: label,
            ),
          ),
        ),
      ),
    );
  }
}

String _networkSummary(MobileDevToolNetworkEntry entry) => [
  entry.status.name.toUpperCase(),
  if (entry.statusCode != null) "${entry.statusCode}",
  if (entry.duration != null) "${entry.duration!.inMilliseconds}ms",
].join(" • ");

class _LogCard extends StatelessWidget {
  const _LogCard({
    required this.entry,
    required this.showKind,
    required this.curlBuilder,
    required this.onOpenDetail,
  });

  final MobileDevToolNetworkEntry entry;
  final bool showKind;
  final MobileDevToolCurlBuilder? curlBuilder;
  final MobileDevToolNetworkDetailOpener? onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, borderColor) = switch (entry.status) {
      MobileDevToolNetworkStatus.success => (
        Colors.green.shade50,
        Colors.green.shade800,
      ),
      MobileDevToolNetworkStatus.error => (
        Colors.red.shade50,
        Colors.red.shade800,
      ),
      MobileDevToolNetworkStatus.pending => (Colors.white, Colors.black),
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 0,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          final openDetail = onOpenDetail;
          if (openDetail != null) {
            openDetail(entry);
            return;
          }
          unawaited(
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (context) => MobileDevToolNetworkLogDetail(
                entry: entry,
                curlBuilder: curlBuilder,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showKind)
                      Text(
                        entry.request.kind == MobileDevToolNetworkKind.graphql
                            ? "GraphQL"
                            : "API",
                      ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            entry.request.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(" (${entry.request.method})"),
                      ],
                    ),
                    Text(
                      _networkSummary(entry),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

/// Detail body for one entry — rendered as a page in the tool sheet, or as a
/// standalone modal sheet when the panel is used without [onOpenDetail].
class MobileDevToolNetworkLogDetail extends StatelessWidget {
  const MobileDevToolNetworkLogDetail({
    required this.entry,
    this.curlBuilder,
    super.key,
  });

  final MobileDevToolNetworkEntry entry;
  final MobileDevToolCurlBuilder? curlBuilder;

  @override
  Widget build(BuildContext context) {
    final request = entry.request.kind == MobileDevToolNetworkKind.graphql
        ? <String, dynamic>{
            "operationName": entry.request.endpoint,
            "variables":
                entry.request.request?["variables"] ??
                const <String, dynamic>{},
          }
        : entry.request.request ?? const <String, dynamic>{};

    return MobileDevToolToast(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          shrinkWrap: true,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.request.method.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(_networkSummary(entry)),
                    ],
                  ),
                ),
                if (curlBuilder != null)
                  OutlinedButton.icon(
                    onPressed: () =>
                        unawaited(_copy(context, curlBuilder!(entry))),
                    icon: const Icon(Icons.terminal),
                    label: const Text("cURL"),
                  ),
              ],
            ),
            _JsonBlock(label: "Request", data: request),
            if (entry.request.kind == MobileDevToolNetworkKind.graphql &&
                entry.request.document != null)
              _JsonBlock(
                label: "GraphQL document",
                data: MobileDevToolJsonFormatter.formatGraphQLDocument(
                  entry.request.document!,
                ),
              ),
            _JsonBlock(
              label: "Response",
              data: entry.response ?? const <String, dynamic>{},
            ),
            if (entry.error != null)
              _JsonBlock(label: "Error", data: entry.error.toString()),
          ],
        ),
      ),
    );
  }

  Future<void> _copy(BuildContext context, String text) async {
    await mobileDevToolCopyToClipboard(context, text);
  }
}

class _JsonBlock extends StatelessWidget {
  const _JsonBlock({required this.label, required this.data});

  final String label;
  final dynamic data;

  @override
  Widget build(BuildContext context) {
    final formatted = MobileDevToolJsonFormatter.format(
      data,
      omitGraphQLTypeNames: true,
    );
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                tooltip: "Sao chép",
                icon: const Icon(Icons.copy_outlined, size: 18),
                onPressed: () =>
                    unawaited(mobileDevToolCopyToClipboard(context, formatted)),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(6),
            ),
            child: SelectableText(
              formatted,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: "monospace",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
