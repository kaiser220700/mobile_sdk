import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mobile_devtool/mobile_devtool.dart";

void main() {
  testWidgets("uses the host theme builder for SDK-owned chrome", (
    tester,
  ) async {
    final controller = MobileDevToolController();
    final hostTheme = ThemeData(
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0F766E),
        onPrimary: Colors.white,
        surface: Color(0xFFF0FDFA),
        onSurface: Color(0xFF042F2E),
      ),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MobileDevToolChrome(
            controller: controller,
            showLauncher: false,
            configuration: MobileDevToolConfiguration(
              themeBuilder: (_) => hostTheme,
            ),
          ),
        ),
      ),
    );

    final scopedTheme = tester.widgetList<Theme>(find.byType(Theme)).last;
    expect(scopedTheme.data.colorScheme.surface, hostTheme.colorScheme.surface);
    expect(scopedTheme.data.colorScheme.primary, hostTheme.colorScheme.primary);
  });
}
