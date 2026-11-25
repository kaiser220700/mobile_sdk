import "package:material_ui/material_ui.dart";

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
    this.uploading = false,
    this.errorStyle,
    this.sourcePicker,
    this.replaceButtonBuilder,
    this.removeButtonBuilder,
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
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.borderRadius,
    this.placeholderColor,
    this.labelStyle,
    this.previewOverlayColor,
    this.removeIcon = Icons.close,
    super.key,
  }) : assert(aspectRatio > 0),
       assert(borderWidth > 0),
       assert(
         uploadProgress == null || (uploadProgress >= 0 && uploadProgress <= 1),
       );

  final String label;
  final ValueChanged<UiKitMediaSource> onSelectSource;
  final Widget? preview;
  final String? errorText;
  final double? uploadProgress;
  final bool uploading;
  final TextStyle? errorStyle;

  /// Host-owned presentation. Null means cancellation; only allowed sources
  /// are accepted. The host owns closing its dialog or sheet.
  final Future<UiKitMediaSource?> Function(
    BuildContext context,
    Set<UiKitMediaSource> allowedSources,
  )?
  sourcePicker;
  final Widget Function(BuildContext context, VoidCallback? onPressed)?
  replaceButtonBuilder;
  final Widget Function(BuildContext context, VoidCallback? onPressed)?
  removeButtonBuilder;
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
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double? borderRadius;
  final Color? placeholderColor;
  final TextStyle? labelStyle;
  final Color? previewOverlayColor;
  final IconData removeIcon;

  bool get _uploading =>
      uploading || (uploadProgress != null && uploadProgress! < 1);
  bool get _interactive => enabled && !_uploading;

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
          replaceButtonBuilder?.call(
                context,
                _interactive ? () => _showSources(context) : null,
              ) ??
              OutlinedButton(
                onPressed: _interactive ? () => _showSources(context) : null,
                child: Text(replaceLabel),
              ),
        ],
      ],
    );
  }

  Widget _empty(BuildContext context, UiKitThemeData theme) => InkWell(
    borderRadius: BorderRadius.circular(borderRadius ?? theme.radiusMd),
    onTap: _interactive ? () => _showSources(context) : null,
    child: AspectRatio(
      aspectRatio: aspectRatio,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: enabled
              ? backgroundColor ?? theme.surface
              : disabledBackgroundColor ?? theme.surfaceMuted,
          border: Border.all(
            color: borderColor ?? theme.border,
            width: borderWidth,
          ),
          borderRadius: BorderRadius.circular(borderRadius ?? theme.radiusMd),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              placeholder ??
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    color: placeholderColor ?? theme.textMuted,
                  ),
              SizedBox(height: theme.spacingSm),
              Text(addLabel, style: labelStyle ?? theme.bodyMedium),
              if (_uploading) CircularProgressIndicator(value: uploadProgress),
              if (errorText != null)
                Text(
                  errorText!,
                  style:
                      errorStyle ?? theme.caption.copyWith(color: theme.error),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _preview(BuildContext context, UiKitThemeData theme) => AspectRatio(
    aspectRatio: aspectRatio,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? theme.radiusMd),
      child: Stack(
        fit: StackFit.expand,
        children: [
          preview!,
          if (_uploading || errorText != null)
            ColoredBox(
              color: previewOverlayColor ?? theme.scrim,
              child: Center(
                child: errorText != null
                    ? Padding(
                        padding: EdgeInsets.all(theme.spacingLg),
                        child: Text(
                          errorText!,
                          style:
                              errorStyle ??
                              theme.caption.copyWith(color: theme.error),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : CircularProgressIndicator(value: uploadProgress),
              ),
            ),
          if (onRemove != null && enabled && !_uploading)
            Positioned(
              top: theme.spacingSm,
              right: theme.spacingSm,
              child:
                  removeButtonBuilder?.call(context, onRemove) ??
                  IconButton.filledTonal(
                    tooltip: removeLabel,
                    onPressed: onRemove,
                    icon: Icon(removeIcon),
                  ),
            ),
        ],
      ),
    ),
  );

  Future<void> _showSources(BuildContext context) async {
    final source = sourcePicker != null
        ? await sourcePicker!(context, Set.unmodifiable(allowedSources))
        : await showModalBottomSheet<UiKitMediaSource>(
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
                      onTap: () =>
                          Navigator.pop(sheetContext, UiKitMediaSource.file),
                    ),
                  ListTile(
                    title: Text(cancelLabel),
                    onTap: () => Navigator.pop(sheetContext),
                  ),
                ],
              ),
            ),
          );
    if (!context.mounted || source == null) return;
    final current = context.widget;
    if (current is UiKitMediaPicker &&
        current._interactive &&
        current.allowedSources.contains(source)) {
      current.onSelectSource(source);
    }
  }
}
