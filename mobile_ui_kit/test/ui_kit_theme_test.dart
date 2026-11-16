import "package:material_ui/material_ui.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mobile_ui_kit/mobile_ui_kit.dart" as ui;

void main() {
  testWidgets('field error text uses the semantic error token', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        theme: ui.Theme.material(),
        home: Material(
          child: ui.TextField(
            controller: controller,
            label: 'Email',
            errorText: 'Invalid email',
          ),
        ),
      ),
    );
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration!.errorStyle!.color, ui.ThemeData.defaults.error);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  test(
    'default semantic colors meet normal text contrast on paired surfaces',
    () {
      final t = ui.ThemeData.defaults;
      double contrast(Color a, Color b) {
        final x = a.computeLuminance(), y = b.computeLuminance();
        return x > y ? (x + .05) / (y + .05) : (y + .05) / (x + .05);
      }

      for (final pair in [
        (t.text, t.surface),
        (t.textMuted, t.surfaceMuted),
        (t.textInverse, t.primary),
        (t.textInverse, t.success),
        (t.textInverse, t.warning),
        (t.textInverse, t.error),
        (t.textInverse, t.info),
        (t.success, t.successBg),
        (t.warning, t.warningBg),
        (t.error, t.errorBg),
        (t.info, t.infoBg),
      ]) {
        expect(contrast(pair.$1, pair.$2), greaterThanOrEqualTo(4.5));
      }
    },
  );
  test('Material and kit share semantic tokens', () {
    final theme = ui.Theme.material();
    expect(theme.colorScheme.primary, ui.ThemeData.defaults.primary);
    expect(theme.extension<ui.ThemeData>(), ui.ThemeData.defaults);
    expect(theme.scaffoldBackgroundColor, ui.ThemeData.defaults.surfaceMuted);
    final custom = ui.ThemeData.defaults.copyWith(primary: Colors.purple);
    expect(
      ui.Theme.material(tokens: custom).colorScheme.primary,
      Colors.purple,
    );
  });

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
    expect(resolved!.primary, const Color(0xFF2563EB));
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
