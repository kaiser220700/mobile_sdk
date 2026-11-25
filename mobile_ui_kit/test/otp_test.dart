import "package:material_ui/material_ui.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mobile_ui_kit/mobile_ui_kit.dart" as ui;

Widget otp(
  ui.OtpController controller, {
  ValueChanged<String>? onChanged,
  ValueChanged<String>? onCompleted,
  bool enabled = true,
  double width = 320,
}) => MaterialApp(
  home: Material(
    child: Center(
      child: SizedBox(
        width: width,
        child: ui.OtpField(
          controller: controller,
          semanticLabel: 'Verification code',
          enabled: enabled,
          cellBuilder: (_, index, value, active) =>
              Text(value, key: ValueKey('digit-$index')),
          onChanged: onChanged,
          onCompleted: onCompleted,
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('paste fills one code and completes only once', (tester) async {
    final controller = ui.OtpController(length: 6);
    final changed = <String>[], completed = <String>[];
    await tester.pumpWidget(
      otp(controller, onChanged: changed.add, onCompleted: completed.add),
    );
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();
    expect(controller.text, '123456');
    expect(changed, ['123456']);
    expect(completed, ['123456']);
    controller.setText('123456');
    expect(completed, ['123456']);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('IME deletion edits the complete code without hardware keys', (
    tester,
  ) async {
    final controller = ui.OtpController(length: 6);
    await tester.pumpWidget(otp(controller));
    await tester.enterText(find.byType(TextField), '123');
    // The editing update delivered by an IME, not sendKeyEvent(backspace).
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: '12',
        selection: TextSelection.collapsed(offset: 2),
      ),
    );
    await tester.pump();
    expect(controller.text, '12');
    expect(controller.valueAt(2), isEmpty);
    tester.testTextInput.updateEditingValue(TextEditingValue.empty);
    await tester.pump();
    expect(controller.text, isEmpty);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets(
    'full-code autofill and replacing a selection use the native input',
    (tester) async {
      final controller = ui.OtpController(length: 6);
      final completed = <String>[];
      await tester.pumpWidget(otp(controller, onCompleted: completed.add));
      await tester.showKeyboard(find.byType(TextField));
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.autofillHints, contains(AutofillHints.oneTimeCode));
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '246810',
          selection: TextSelection.collapsed(offset: 6),
        ),
      );
      await tester.pump();
      expect(controller.text, '246810');
      // Replace the whole selection with a new code, without an empty intermediate.
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '135790',
          selection: TextSelection.collapsed(offset: 6),
        ),
      );
      await tester.pump();
      expect(controller.text, '135790');
      expect(completed, ['246810', '135790']);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    },
  );

  testWidgets('filters pasted non-digits and clips excess digits', (
    tester,
  ) async {
    final controller = ui.OtpController(length: 6);
    await tester.pumpWidget(otp(controller));
    await tester.enterText(find.byType(TextField), '12 34-56a78');
    await tester.pump();
    expect(controller.text, '123456');
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('completion callback can clear the controller synchronously', (
    tester,
  ) async {
    final controller = ui.OtpController(length: 6);
    var completions = 0;
    await tester.pumpWidget(
      otp(
        controller,
        onCompleted: (_) {
          completions++;
          controller.clear();
        },
      ),
    );
    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();
    expect(completions, 1);
    expect(controller.text, isEmpty);
    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();
    expect(completions, 2);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('changed callback can reject a complete code before submission', (
    tester,
  ) async {
    final controller = ui.OtpController(length: 6);
    var completions = 0;
    await tester.pumpWidget(
      otp(
        controller,
        onChanged: (code) {
          if (code.length == 6) controller.clear();
        },
        onCompleted: (_) => completions++,
      ),
    );
    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();
    expect(completions, 0);
    expect(controller.text, isEmpty);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('controller replacement detaches the previous listener', (
    tester,
  ) async {
    final first = ui.OtpController(length: 6),
        second = ui.OtpController(length: 4);
    await tester.pumpWidget(otp(first));
    first.setText('123');
    await tester.pumpWidget(otp(second));
    first.dispose();
    second.setText('9876');
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '9876',
    );
    expect(find.byKey(const ValueKey('digit-4')), findsNothing);
    await tester.pumpWidget(const SizedBox());
    second.dispose();
  });

  testWidgets('visual cells do not create duplicate accessible inputs', (
    tester,
  ) async {
    final controller = ui.OtpController(length: 6);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(otp(controller));
    controller.setText('123');
    await tester.pump();
    expect(find.bySemanticsLabel(RegExp('Verification code')), findsOneWidget);
    expect(find.byType(EditableText), findsOneWidget);
    await tester.pumpWidget(otp(controller, enabled: false, width: 200));
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    semantics.dispose();
  });

  testWidgets('legacy mode accepts a full paste in a non-first cell', (
    tester,
  ) async {
    final controller = ui.OtpController(length: 4);
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: ui.OtpField(
            controller: controller,
            inputMode: ui.OtpInputMode.segmented,
            decorationBuilder: (_, _, _) =>
                const InputDecoration(counterText: ''),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField).at(1), '789');
    await tester.pump();
    expect(controller.valueAt(0), isEmpty);
    expect(controller.valueAt(1), '7');
    expect(controller.valueAt(2), '8');
    expect(controller.valueAt(3), '9');
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
}
