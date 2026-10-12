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

  testWidgets("uses the host theme colors for the launcher bubble", (
    tester,
  ) async {
    final controller = MobileDevToolController();
    final hostTheme = ThemeData(
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0F766E),
        surface: Color(0xFFF0FDFA),
        outline: Color(0xFF99F6E4),
      ),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MobileDevToolChrome(
            controller: controller,
            configuration: MobileDevToolConfiguration(
              themeBuilder: (_) => hostTheme,
            ),
          ),
        ),
      ),
    );

    final decoration = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey("mobile-devtool-bubble-surface")),
    );
    final box = decoration.decoration as BoxDecoration;
    expect(box.color, hostTheme.colorScheme.surface);
    expect((box.border! as Border).top.color, hostTheme.colorScheme.outline);
    expect(
      tester.widget<Icon>(find.byType(Icon)).color,
      hostTheme.colorScheme.primary,
    );
  });

  testWidgets("forwards explicit bubble colors from the configuration", (
    tester,
  ) async {
    final controller = MobileDevToolController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MobileDevToolChrome(
            controller: controller,
            configuration: const MobileDevToolConfiguration(
              bubbleBackgroundColor: Colors.blue,
              bubbleForegroundColor: Colors.white,
              bubbleBorderColor: Colors.red,
            ),
          ),
        ),
      ),
    );

    final decoration = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey("mobile-devtool-bubble-surface")),
    );
    final box = decoration.decoration as BoxDecoration;
    expect(box.color, Colors.blue);
    expect((box.border! as Border).top.color, Colors.red);
    expect(tester.widget<Icon>(find.byType(Icon)).color, Colors.white);
  });

  testWidgets("keeps the legacy bubble colors without host configuration", (
    tester,
  ) async {
    final controller = MobileDevToolController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: MobileDevToolChrome(controller: controller)),
      ),
    );

    final decoration = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey("mobile-devtool-bubble-surface")),
    );
    final box = decoration.decoration as BoxDecoration;
    expect(box.color, Colors.white);
    expect((box.border! as Border).top.color, Colors.black);
    expect(tester.widget<Icon>(find.byType(Icon)).color, Colors.black);
  });
}
