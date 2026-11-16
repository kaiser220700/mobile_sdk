import "package:material_ui/material_ui.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mobile_screen_draw/mobile_screen_draw.dart";

void main() {
  testWidgets("keeps expanded Screen Draw toolbar inside the viewport", (
    tester,
  ) async {
    final tool = Controller()..toolbarPosition = const Offset(1000, 1000);
    addTearDown(tool.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(children: [DrawingOverlay(tool: tool)]),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byTooltip("Đóng Screen Draw")).width,
      lessThan(tester.view.physicalSize.width / tester.view.devicePixelRatio),
    );
    expect(find.byTooltip("Thu gọn"), findsOneWidget);
    await tester.tap(find.byTooltip("Thu gọn"));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    expect(find.byTooltip("Đóng Screen Draw"), findsNothing);
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    expect(find.byTooltip("Thu gọn"), findsOneWidget);
    final beforeDrag = tool.toolbarPosition;
    await tester.drag(
      find.byTooltip("Đóng Screen Draw"),
      const Offset(-40, 20),
    );
    expect(tool.toolbarPosition, isNot(beforeDrag));
  });
}
