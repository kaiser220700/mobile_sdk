import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "mobile_devtool_toast.dart";

Future<void> mobileDevToolCopyToClipboard(
  BuildContext context,
  String text,
) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) MobileDevToolToast.show(context, "Đã sao chép");
}
