import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/pressable/ui_kit_pressable.dart";
import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

/// A file row that delegates opening, downloading, and deletion to its host.
/// It performs no network, storage, or permission operation itself.
class UiKitFileAttachmentTile extends StatelessWidget {
  const UiKitFileAttachmentTile({
    required this.fileName,
    required this.sizeInBytes,
    this.onTap,
    this.onDownload,
    this.onDelete,
    this.icon = Icons.description_outlined,
    this.downloadLabel = "Download",
    this.deleteLabel = "Delete",
    this.semanticsLabel,
    super.key,
  }) : assert(sizeInBytes >= 0);

  final String fileName;
  final int sizeInBytes;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;
  final VoidCallback? onDelete;
  final IconData icon;
  final String downloadLabel;
  final String deleteLabel;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final row = DecoratedBox(
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border.all(color: theme.border),
        borderRadius: BorderRadius.circular(theme.radiusMd),
      ),
      child: Padding(
        padding: EdgeInsets.all(theme.spacingMd),
        child: Row(
          children: [
            Icon(icon, color: theme.textMuted),
            SizedBox(width: theme.spacingSm),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.bodyMedium.copyWith(color: theme.text),
                  ),
                  SizedBox(height: theme.spacing2xs),
                  Text(_formatFileSize(sizeInBytes), style: theme.caption),
                ],
              ),
            ),
            if (onDownload != null)
              IconButton(
                tooltip: downloadLabel,
                onPressed: onDownload,
                icon: const Icon(Icons.download_outlined),
              ),
            if (onDelete != null)
              IconButton(
                tooltip: deleteLabel,
                onPressed: onDelete,
                icon: const Icon(Icons.close),
              ),
          ],
        ),
      ),
    );
    return UiKitPressable(
      onPress: onTap,
      semanticsLabel: semanticsLabel ?? fileName,
      builder: (context, states, child) => row,
    );
  }
}

String _formatFileSize(int bytes) {
  const units = ["B", "KB", "MB", "GB", "TB"];
  var value = bytes.toDouble();
  var index = 0;
  while (value >= 1024 && index < units.length - 1) {
    value /= 1024;
    index++;
  }
  final digits = value >= 10 || index == 0 ? 0 : 1;
  return "${value.toStringAsFixed(digits)} ${units[index]}";
}
