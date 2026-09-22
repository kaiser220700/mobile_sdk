import "package:flutter/material.dart";

import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

/// Host-owned sources that [UiKitMediaPicker] can request.
enum UiKitMediaSource { camera, gallery, file }

/// A visual media field. The host owns platform access, permissions, upload,
/// preview creation, and persistence; this widget only collects an intent.
class UiKitMediaPicker extends StatelessWidget {
  const UiKitMediaPicker({
    required this.label,
    required this.onSelectSource,
    this.preview,
    this.errorText,
    this.uploadProgress,
    this.onRemove,
    this.allowedSources = const {
      UiKitMediaSource.camera,
      UiKitMediaSource.gallery,
      UiKitMediaSource.file,
    },
    this.enabled = true,
    this.aspectRatio = 16 / 9,
    this.addLabel = "Add media",
    this.replaceLabel = "Replace media",
    this.removeLabel = "Remove media",
    this.cameraLabel = "Camera",
    this.galleryLabel = "Photo library",
    this.fileLabel = "File",
    this.cancelLabel = "Cancel",
    this.placeholder,
    super.key,
  }) : assert(aspectRatio > 0);

  final String label;
  final ValueChanged<UiKitMediaSource> onSelectSource;
  final Widget? preview;
  final String? errorText;
  final double? uploadProgress;
  final VoidCallback? onRemove;
  final Set<UiKitMediaSource> allowedSources;
  final bool enabled;
  final double aspectRatio;
  final String addLabel;
  final String replaceLabel;
  final String removeLabel;
  final String cameraLabel;
  final String galleryLabel;
  final String fileLabel;
  final String cancelLabel;
  final Widget? placeholder;

  bool get _uploading => uploadProgress != null && uploadProgress! < 1;

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    final field = preview == null
        ? _empty(context, theme)
        : _preview(context, theme);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(label: label, child: field),
        if (preview != null) ...[
          SizedBox(height: theme.spacingSm),
          OutlinedButton(
            onPressed: enabled ? () => _showSources(context) : null,
            child: Text(replaceLabel),
          ),
        ],
      ],
    );
  }

  Widget _empty(BuildContext context, UiKitThemeData theme) => InkWell(
    borderRadius: BorderRadius.circular(theme.radiusMd),
    onTap: enabled ? () => _showSources(context) : null,
    child: AspectRatio(
      aspectRatio: aspectRatio,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: enabled ? theme.surface : theme.surfaceMuted,
          border: Border.all(color: theme.border),
          borderRadius: BorderRadius.circular(theme.radiusMd),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              placeholder ??
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    color: theme.textMuted,
                  ),
              SizedBox(height: theme.spacingSm),
              Text(addLabel, style: theme.bodyMedium),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _preview(BuildContext context, UiKitThemeData theme) => AspectRatio(
    aspectRatio: aspectRatio,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(theme.radiusMd),
      child: Stack(
        fit: StackFit.expand,
        children: [
          preview!,
          if (_uploading || errorText != null)
            ColoredBox(
              color: Colors.black54,
              child: Center(
                child: errorText != null
                    ? Padding(
                        padding: EdgeInsets.all(theme.spacingLg),
                        child: Text(errorText!, textAlign: TextAlign.center),
                      )
                    : CircularProgressIndicator(value: uploadProgress),
              ),
            ),
          if (onRemove != null && enabled && !_uploading)
            Positioned(
              top: theme.spacingSm,
              right: theme.spacingSm,
              child: IconButton.filledTonal(
                tooltip: removeLabel,
                onPressed: onRemove,
                icon: const Icon(Icons.close),
              ),
            ),
        ],
      ),
    ),
  );

  Future<void> _showSources(BuildContext context) async {
    final source = await showModalBottomSheet<UiKitMediaSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (allowedSources.contains(UiKitMediaSource.camera))
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(cameraLabel),
                onTap: () =>
                    Navigator.pop(sheetContext, UiKitMediaSource.camera),
              ),
            if (allowedSources.contains(UiKitMediaSource.gallery))
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(galleryLabel),
                onTap: () =>
                    Navigator.pop(sheetContext, UiKitMediaSource.gallery),
              ),
            if (allowedSources.contains(UiKitMediaSource.file))
              ListTile(
                leading: const Icon(Icons.folder_open_outlined),
                title: Text(fileLabel),
                onTap: () => Navigator.pop(sheetContext, UiKitMediaSource.file),
              ),
            ListTile(
              title: Text(cancelLabel),
              onTap: () => Navigator.pop(sheetContext),
            ),
          ],
        ),
      ),
    );
    if (source != null && enabled) onSelectSource(source);
  }
}
