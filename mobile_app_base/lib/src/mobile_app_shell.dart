import "package:flutter/material.dart";

import "app_config.dart";

/// Composition root for an app consuming the mobile SDK.
///
/// This shell owns Flutter application wiring. Business features remain
/// outside the SDK and are passed in through [home].
class MobileAppShell extends StatelessWidget {
  const MobileAppShell({
    required this.config,
    required this.navigatorKey,
    required this.home,
    this.colorSchemeSeed = const Color(0xFF176B87),
    this.theme,
    super.key,
  });

  final AppConfig config;
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget home;
  final Color colorSchemeSeed;
  final ThemeData? theme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: config.appName,
      theme:
          theme ??
          ThemeData(colorSchemeSeed: colorSchemeSeed, useMaterial3: true),
      home: home,
    );
  }
}
