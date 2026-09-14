import "dart:async";

import "package:flutter/material.dart";

import "mobile_devtool_clipboard.dart";
import "mobile_devtool_fuzz_run_log.dart";
import "mobile_devtool_toast.dart";

/// Reviews Fuzz Tap run history, grouped by session.
class MobileDevToolFuzzRunLogPanel extends StatelessWidget {
  const MobileDevToolFuzzRunLogPanel({required this.log, super.key});

  final MobileDevToolFuzzRunLog log;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: log,
      builder: (context, _) {
        final sessions = log.sessions;
        final theme = Theme.of(context);

        return MobileDevToolToast(
          child: Stack(
            children: [
              Positioned.fill(
                child: sessions.isEmpty
                    ? Center(
                        child: Text(
                          "Chưa có log Fuzz Tap",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 72),
                        itemCount: sessions.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) =>
                            _SessionTile(session: sessions[index]),
                      ),
              ),
              if (sessions.isNotEmpty)
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.small(
                        heroTag: "copy-all-fuzz-run-logs",
                        tooltip: "Sao chép toàn bộ log",
                        onPressed: () => _copy(
                          context,
                          sessions.map(_formatSession).join("\n\n"),
                        ),
                        child: const Icon(Icons.copy_all_outlined),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: "clear-fuzz-run-logs",
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                        tooltip: "Xóa lịch sử",
                        onPressed: log.clearHistory,
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
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});

  final MobileDevToolFuzzRunSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: session.isRunning
              ? theme.colorScheme.primary
              : theme.dividerColor,
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: session.isRunning,
        title: Text(
          "${session.configLabel} — ${_formatTime(session.startedAt)}",
        ),
        subtitle: Text(
          "${session.isRunning ? 'Đang chạy' : session.stopReasonLabel} · "
          "${session.tapCount} tap · ${_formatDuration(session.elapsed)}"
          "${session.errorCount > 0 ? ' · ${session.errorCount} lỗi' : ''}",
        ),
        children: [
          for (final step in session.steps)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onDoubleTap: () => _copy(context, _formatStep(step)),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text("${_formatTime(step.timestamp)}  ${step.message}"),
              ),
            ),
        ],
      ),
    );
  }
}

String _formatSession(MobileDevToolFuzzRunSession session) =>
    "== ${session.configLabel} — ${session.startedAt.toIso8601String()} "
    "(${session.isRunning ? 'đang chạy' : session.stopReasonLabel}) ==\n"
    "${session.steps.map(_formatStep).join('\n')}";

String _formatStep(MobileDevToolFuzzRunStep step) =>
    "${step.timestamp.toIso8601String()}  ${step.message}";

String _formatTime(DateTime timestamp) =>
    "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}";

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return minutes > 0 ? "${minutes}p${seconds}s" : "${seconds}s";
}

Future<void> _copy(BuildContext context, String text) async {
  await mobileDevToolCopyToClipboard(context, text);
}
