import "dart:async";

import "package:flutter/material.dart";

import "mobile_devtool_clipboard.dart";
import "mobile_devtool_controller.dart";
import "mobile_devtool_toast.dart";

class MobileDevToolTraceLogPanel extends StatelessWidget {
  const MobileDevToolTraceLogPanel({required this.controller, super.key});

  final MobileDevToolController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final entries = controller.traceEntries;
        final theme = Theme.of(context);

        return MobileDevToolToast(
          child: Stack(
            children: [
              Positioned.fill(
                child: entries.isEmpty
                    ? Center(
                        child: Text(
                          "Chưa có trace log",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 72),
                        itemCount: entries.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          final formatted = _formatEntry(entry);
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onDoubleTap: () => _copy(context, formatted),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              child: Text(formatted),
                            ),
                          );
                        },
                      ),
              ),
              if (entries.isNotEmpty)
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.small(
                        heroTag: "copy-all-trace-logs",
                        tooltip: "Sao chép toàn bộ trace",
                        onPressed: () => _copy(
                          context,
                          entries.map(_formatEntry).join("\n"),
                        ),
                        child: const Icon(Icons.copy_all_outlined),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: "clear-trace-logs",
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                        tooltip: "Xóa trace logs",
                        onPressed: controller.clearTraces,
                        child: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatEntry(MobileDevToolTraceEntry entry) =>
      "${_formatTime(entry.timestamp)}  ${entry.id}\n${entry.message}";

  String _formatTime(DateTime timestamp) =>
      "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}";

  Future<void> _copy(BuildContext context, String text) async {
    await mobileDevToolCopyToClipboard(context, text);
  }
}
