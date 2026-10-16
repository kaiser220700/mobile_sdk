import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mobile_ui_kit/mobile_ui_kit.dart" as ui;

void main() {
  testWidgets("falls back to the package defaults", (tester) async {
    ui.ThemeData? resolved;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            resolved = ui.Theme.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(resolved, ui.ThemeData.defaults);
    expect(resolved!.primary, const Color(0xFF3F5F73));
    expect(resolved!.primary, ui.Theme.primary);
    expect(resolved!.primary, isNot(const Color(0xFFBC0000)));
  });

  testWidgets("reads the host app ThemeExtension", (tester) async {
    const customTheme = ui.ThemeData.fromDefaults(
      primary: Colors.indigo,
      radiusMd: 20,
    );
    ui.ThemeData? resolved;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [customTheme]),
        home: Builder(
          builder: (context) {
            resolved = ui.Theme.of(context);
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
          extensions: const [ui.ThemeData.fromDefaults(primary: Colors.indigo)],
        ),
        home: ui.Button.text(onPressed: () {}, label: "Continue"),
      ),
    );

    final decoration =
        tester.widget<DecoratedBox>(find.byType(DecoratedBox).first).decoration
            as BoxDecoration;
    expect(decoration.color, Colors.indigo);
  });
}
