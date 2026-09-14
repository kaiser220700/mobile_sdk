import "package:flutter/widgets.dart";

import "package:mobile_ui_kit/src/pressable/ui_kit_pressable.dart";
import "package:mobile_ui_kit/src/theme/ui_kit_theme.dart";

/// List-row headless dùng cho picker/menu — thay `FItem`. Package KHÔNG tự
/// set màu cứng cho [destructive]: đây chỉ là style hint, app-layer tự
/// quyết định màu qua context/theme của chính widget truyền vào (ví dụ
/// [title]/[prefix] đã được tô màu sẵn từ bên ngoài).
class UiKitItem extends StatelessWidget {
  const UiKitItem({
    required this.title,
    this.subtitle,
    this.prefix,
    this.suffix,
    this.onPress,
    this.enabled = true,
    this.destructive = false,
    this.padding,
    super.key,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? prefix;
  final Widget? suffix;
  final VoidCallback? onPress;
  final bool enabled;

  /// Style hint cho app-layer tự quyết màu (ví dụ item xoá/destructive) —
  /// package không tự áp màu cứng nào dựa trên field này.
  final bool destructive;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = UiKitTheme.of(context);
    return UiKitPressable(
      onPress: enabled ? onPress : null,
      builder: (context, states, child) => Padding(
        padding:
            padding ??
            EdgeInsets.symmetric(
              horizontal: theme.spacingLg,
              vertical: theme.spacingMd,
            ),
        child: Row(
          children: [
            if (prefix != null) ...[prefix!, SizedBox(width: theme.spacingMd)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [title, if (subtitle != null) subtitle!],
              ),
            ),
            if (suffix != null) ...[SizedBox(width: theme.spacingMd), suffix!],
          ],
        ),
      ),
    );
  }
}
