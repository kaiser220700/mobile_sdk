import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mobile_ui_kit/mobile_ui_kit.dart";

void main() {
  testWidgets("throttles repeated taps by default", (tester) async {
    var tapCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: UiKitPressable(
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
        home: UiKitPressable(
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
