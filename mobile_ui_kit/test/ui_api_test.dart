import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_ui_kit/mobile_ui_kit.dart' as ui;

void main() {
  test('new names preserve existing type and constructor identity', () {
    const button = ui.Button.text(onPressed: null, label: 'Save');
    expect(button, isA<ui.UiKitButton>());
    expect(ui.ButtonSize.md, ui.UiKitButtonSize.md);
    expect(ui.ThemeData.defaults, same(ui.UiKitThemeData.defaults));
    expect(ui.Theme.primary, ui.UiKitTheme.primary);
    expect(
      ui.RefreshScope(child: const SizedBox()),
      isA<ui.UiKitRefreshConfiguration>(),
    );
    expect(
      () =>
          ui.Button(onPressed: null, label: 'Save', child: const Text('Save')),
      throwsAssertionError,
    );
  });

  testWidgets('button child inherits styling, semantics and activation', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var saves = 0;
    const foreground = Color(0xFF126734);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ui.Button(
            onPressed: () => saves++,
            foregroundColor: foreground,
            child: const Text('Save'),
          ),
        ),
      ),
    );
    final textContext = tester.element(find.text('Save'));
    expect(DefaultTextStyle.of(textContext).style.color, foreground);
    expect(IconTheme.of(textContext).color, foreground);
    expect(find.bySemanticsLabel('Save'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(saves, 1);
    semantics.dispose();
  });

  testWidgets('explicit accessible name replaces custom child semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: ui.Button(
          onPressed: () {},
          semanticsLabel: 'Save task',
          child: const Text('Save'),
        ),
      ),
    );
    expect(find.bySemanticsLabel('Save task'), findsOneWidget);
    expect(find.bySemanticsLabel('Save'), findsNothing);
    semantics.dispose();
  });
}
