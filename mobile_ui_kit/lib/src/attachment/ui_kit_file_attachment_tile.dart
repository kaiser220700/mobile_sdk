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
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.borderRadius,
    this.padding,
    this.iconColor,
    this.titleStyle,
    this.metadataStyle,
    this.downloadIcon = Icons.download_outlined,
    this.deleteIcon = Icons.close,
    super.key,
  }) : assert(sizeInBytes >= 0),
       assert(borderWidth > 0);

  final String fileName;
  final int sizeInBytes;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;
  final VoidCallback? onDelete;
  final IconData icon;
  final String downloadLabel;
  final String deleteLabel;
  final String? semanticsLabel;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? iconColor;
  final TextStyle? titleStyle;
  final TextStyle? metadataStyle;
  final IconData downloadIcon;
  final IconData deleteIcon;

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final row = DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.surface,
        border: Border.all(
          color: borderColor ?? theme.border,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(borderRadius ?? theme.radiusMd),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(theme.spacingMd),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? theme.textMuted),
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
                    style: (titleStyle ?? theme.bodyMedium).copyWith(
                      color: theme.text,
                    ),
                  ),
                  SizedBox(height: theme.spacing2xs),
                  Text(
                    _formatFileSize(sizeInBytes),
                    style: metadataStyle ?? theme.caption,
                  ),
                ],
              ),
            ),
            if (onDownload != null)
              IconButton(
                tooltip: downloadLabel,
                onPressed: onDownload,
                icon: Icon(downloadIcon),
              ),
            if (onDelete != null)
              IconButton(
                tooltip: deleteLabel,
                onPressed: onDelete,
                icon: Icon(deleteIcon),
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
