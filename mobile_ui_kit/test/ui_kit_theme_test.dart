import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mobile_ui_kit/mobile_ui_kit.dart";

void main() {
  testWidgets("falls back to the package defaults", (tester) async {
    UiKitThemeData? resolved;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            resolved = UiKitTheme.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(resolved, UiKitThemeData.defaults);
    expect(resolved!.primary, const Color(0xFF3F5F73));
    expect(resolved!.primary, UiKitTheme.primary);
    expect(resolved!.primary, isNot(const Color(0xFFBC0000)));
  });

  testWidgets("reads the host app ThemeExtension", (tester) async {
    const customTheme = UiKitThemeData(primary: Colors.indigo, radiusMd: 20);
    UiKitThemeData? resolved;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [customTheme]),
        home: Builder(
          builder: (context) {
            resolved = UiKitTheme.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(resolved, customTheme);
    expect(resolved!.primary, Colors.indigo);
    expect(resolved!.radiusMd, 20);
  });

  testWidgets("visual components use the host theme", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const [UiKitThemeData(primary: Colors.indigo)],
        ),
        home: UiKitButton.text(onPressed: () {}, label: "Continue"),
      ),
    );

    final decoration =
        tester.widget<DecoratedBox>(find.byType(DecoratedBox).first).decoration
            as BoxDecoration;
    expect(decoration.color, Colors.indigo);
  });
}
