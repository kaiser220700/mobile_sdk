import "package:material_ui/material_ui.dart";
import "package:flutter/services.dart";

import "toast.dart";

Future<void> toolCopyToClipboard(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) ToolToast.show(context, "Đã sao chép");
}
