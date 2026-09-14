import "dart:async";

import "package:flutter/material.dart";

import "mobile_devtool_clipboard.dart";
import "mobile_devtool_toast.dart";

/// 2-column `key | value` table — tap a row to copy its value.
class MobileDevToolKvRow {
  const MobileDevToolKvRow({
    required this.label,
    required this.value,
    this.trailing,
  });

  final String label;

  /// `null` shows a muted placeholder and disables copy.
  final String? value;

  /// Extra widget pinned to the value column's trailing edge (e.g. a
  /// show/hide toggle for a token).
  final Widget? trailing;
}

class MobileDevToolKvTable extends StatelessWidget {
  const MobileDevToolKvTable({required this.rows, super.key});

  static const double _labelWidth = 108;

  final List<MobileDevToolKvRow> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.dividerColor;

    final content = rows.isEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              "Chưa có dữ liệu",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
          )
        : DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var index = 0; index < rows.length; index++) ...[
                  if (index > 0)
                    Divider(height: 1, thickness: 1, color: borderColor),
                  _KvRowTile(row: rows[index], labelWidth: _labelWidth),
                ],
              ],
            ),
          );

    return MobileDevToolToast(child: content);
  }
}

class _KvRowTile extends StatelessWidget {
  const _KvRowTile({required this.row, required this.labelWidth});

  final MobileDevToolKvRow row;
  final double labelWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = row.value;
    final hasValue = value != null && value.isNotEmpty;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              row.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hasValue ? value : "Chưa có giá trị",
              style: theme.textTheme.bodySmall?.copyWith(
                color: hasValue ? theme.colorScheme.onSurface : theme.hintColor,
                fontFamily: hasValue ? "monospace" : null,
              ),
            ),
          ),
          if (row.trailing case final trailing?) ...[
            const SizedBox(width: 4),
            trailing,
          ],
        ],
      ),
    );

    if (!hasValue) return content;

    return Semantics(
      button: true,
      label: "Sao chép giá trị của ${row.label}",
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => unawaited(_copy(context, value)),
          child: ExcludeSemantics(child: content),
        ),
      ),
    );
  }

  Future<void> _copy(BuildContext context, String value) async {
    await mobileDevToolCopyToClipboard(context, value);
  }
}
