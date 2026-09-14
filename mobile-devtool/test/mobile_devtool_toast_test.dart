import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mobile_devtool/src/mobile_devtool_kv_table.dart";
import "package:mobile_devtool/src/mobile_devtool_toast.dart";

void main() {
  testWidgets("shows and dismisses widget-local toast", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MobileDevToolToast(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => MobileDevToolToast.show(context, "Đã sao chép"),
              child: const Text("Copy"),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text("Copy"));
    await tester.pump();
    expect(find.text("Đã sao chép"), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text("Đã sao chép"), findsNothing);
  });

  testWidgets("does not impose height constraints on a table in a list", (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ListView(
          children: [
            MobileDevToolKvTable(
              rows: const [MobileDevToolKvRow(label: "key", value: "value")],
            ),
          ],
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
