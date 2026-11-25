import "package:material_ui/material_ui.dart";
import "package:flutter_test/flutter_test.dart";
import "package:flutter/services.dart";
import "package:flutter/semantics.dart";
import "package:mobile_ui_kit/mobile_ui_kit.dart" as ui;

void main() {
  testWidgets("keyboard and semantics share activation and throttle", (
    tester,
  ) async {
    final focus = FocusNode();
    final semantics = tester.ensureSemantics();
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ui.Pressable(
          focusNode: focus,
          autofocus: true,
          excludeSemantics: true,
          semanticsLabel: 'Accessible action',
          onPress: () => taps++,
          builder: (_, _, _) => const Text('Visible label'),
        ),
      ),
    );
    await tester.pump();
    expect(focus.hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(taps, 1);
    final node = tester.getSemantics(
      find.bySemanticsLabel('Accessible action'),
    );
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    node.owner!.performAction(node.id, SemanticsAction.tap);
    expect(taps, 1);
    await tester.pump(const Duration(milliseconds: 301));
    node.owner!.performAction(node.id, SemanticsAction.tap);
    expect(taps, 2);
    await tester.pump(const Duration(milliseconds: 301));
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(taps, 3);
    await tester.pumpWidget(const SizedBox());
    focus.dispose();
    semantics.dispose();
  });

  testWidgets("disabled controls have no focus or semantic tap action", (
    tester,
  ) async {
    final focus = FocusNode();
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: ui.Pressable(
          focusNode: focus,
          autofocus: true,
          semanticsLabel: 'Disabled action',
          builder: (_, _, _) => const Text('Disabled'),
        ),
      ),
    );
    await tester.pump();
    final node = tester.getSemantics(
      find.bySemanticsLabel(RegExp('Disabled action')),
    );
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
    expect(focus.hasFocus, isFalse);
    await tester.pumpWidget(const SizedBox());
    focus.dispose();
    semantics.dispose();
  });
  testWidgets("throttles repeated taps by default", (tester) async {
    var tapCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ui.Pressable(
          onPress: () => tapCount++,
          builder: (context, states, child) => const Text("Tap"),
        ),
      ),
    );

    await tester.tap(find.text("Tap"));
    await tester.pump();
    await tester.tap(find.text("Tap"));
    await tester.pump();
    expect(tapCount, 1);

    await tester.pump(const Duration(milliseconds: 301));
    await tester.tap(find.text("Tap"));
    await tester.pump();
    expect(tapCount, 2);
  });

  testWidgets("allows rapid taps when throttling is disabled", (tester) async {
    var tapCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ui.Pressable(
          onPress: () => tapCount++,
          tapThrottleDuration: Duration.zero,
          builder: (context, states, child) => const Text("Tap"),
        ),
      ),
    );

    await tester.tap(find.text("Tap"));
    await tester.pump();
    await tester.tap(find.text("Tap"));
    await tester.pump();
    expect(tapCount, 2);
  });
}
