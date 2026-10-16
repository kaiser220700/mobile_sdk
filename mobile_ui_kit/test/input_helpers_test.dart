import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_ui_kit/mobile_ui_kit.dart' as ui;

TextEditingValue edit(String text, [int? caret]) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: caret ?? text.length),
);

void main() {
  test(
    'decimal input supports intermediate edits and configured constraints',
    () {
      final formatter = ui.DecimalInputFormatter(
        decimalSeparator: ',',
        maxIntegerDigits: 3,
        allowNegative: true,
      );
      expect(formatter.formatEditUpdate(edit(''), edit('.5')), edit('0,5'));
      expect(formatter.formatEditUpdate(edit(''), edit('-.')), edit('-0,'));
      expect(
        formatter.formatEditUpdate(edit('12'), edit('1.2', 2)),
        edit('1,2', 2),
      );
      expect(formatter.formatEditUpdate(edit('12'), edit('1234')), edit('12'));
      expect(
        formatter.formatEditUpdate(edit('1,23'), edit('1,234')),
        edit('1,23'),
      );
      expect(formatter.formatEditUpdate(edit('12'), edit('')), edit(''));
      expect(formatter.formatEditUpdate(edit('12'), edit('a')), edit('12'));
      expect(
        ui.DecimalInputFormatter(
          decimalDigits: 0,
        ).formatEditUpdate(edit('1'), edit('1.')),
        edit('1'),
      );
    },
  );
  test('preserves selected ranges and active IME composition', () {
    final formatter = ui.DecimalInputFormatter();
    const composing = TextEditingValue(
      text: 'あ',
      composing: TextRange(start: 0, end: 1),
    );
    expect(formatter.formatEditUpdate(edit(''), composing), composing);
    const selected = TextEditingValue(
      text: '.12',
      selection: TextSelection(baseOffset: 1, extentOffset: 3),
    );
    final result = formatter.formatEditUpdate(edit(''), selected);
    expect(result.text, '0.12');
    expect(
      result.selection,
      const TextSelection(baseOffset: 2, extentOffset: 4),
    );
    expect(
      () => ui.DecimalInputFormatter(decimalDigits: -1),
      throwsArgumentError,
    );
  });
  testWidgets(
    'bottom actions retain device inset after parent removes padding',
    (tester) async {
      tester.view.padding = const FakeViewPadding(bottom: 34);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const SizedBox(),
            bottomNavigationBar: const ui.BottomActionArea(
              child: SizedBox(key: Key('action'), height: 48),
            ),
          ),
        ),
      );
      expect(
        tester.getBottomLeft(find.byKey(const Key('action'))).dy,
        tester.view.physicalSize.height - 34,
      );
    },
  );
}
