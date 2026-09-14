import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mobile_devtool/src/mobile_devtool_annotation_overlay.dart";
import "package:mobile_devtool/src/mobile_devtool_annotation_tool.dart";
import "package:mobile_devtool/src/mobile_devtool_controller.dart";
import "package:mobile_devtool/src/mobile_devtool_fuzz_run_log.dart";
import "package:mobile_devtool/src/mobile_devtool_fuzz_tap_overlay.dart";
import "package:mobile_devtool/src/mobile_devtool_fuzz_tap_runner.dart";
import "package:mobile_devtool/src/mobile_devtool_theme.dart";

void main() {
  testWidgets("keeps expanded Fuzz Tap inside the viewport", (tester) async {
    final controller = MobileDevToolController();
    final log = MobileDevToolFuzzRunLog();
    final runner = MobileDevToolFuzzTapRunner(
      log: log,
      networkController: controller,
    );
    log.start("Test", "first log");
    log.log("second log");
    log.log("latest log");
    addTearDown(() {
      runner.stop();
      log.dispose();
      controller.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(
          children: [
            MobileDevToolFuzzTapOverlay(
              runner: runner,
              log: log,
              onClose: () {},
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byTooltip("Thu gọn"), findsNothing);
    final scrim = tester.widget<ColoredBox>(
      find.byKey(const ValueKey("fuzz-overlay-scrim")),
    );
    expect(scrim.color, MobileDevToolTheme.fuzzOverlayScrim);
    expect(find.byKey(const ValueKey("fuzz-log-stream")), findsOneWidget);
    expect(
      tester.getTopLeft(find.textContaining("latest log")).dy,
      greaterThan(tester.getTopLeft(find.textContaining("second log")).dy),
    );
    expect(find.byType(AnimatedList), findsOneWidget);
    log.log("animated log");
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));
    expect(find.textContaining("animated log"), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey("fuzz-overlay-panel"))).width,
      equals(tester.view.physicalSize.width / tester.view.devicePixelRatio),
    );
    expect(find.byTooltip("Tua lại 10 giây"), findsOneWidget);
    expect(find.byTooltip("Tạm dừng"), findsOneWidget);
    expect(find.byTooltip("Tua nhanh 10 giây"), findsOneWidget);
  });

  testWidgets("allows scrolling through the live Fuzz Tap messages", (
    tester,
  ) async {
    final controller = MobileDevToolController();
    final log = MobileDevToolFuzzRunLog()..start("Test", "scroll log 0");
    for (var index = 1; index < 10; index++) {
      log.log("scroll log $index");
    }
    final runner = MobileDevToolFuzzTapRunner(
      log: log,
      networkController: controller,
    );
    addTearDown(() {
      runner.stop();
      log.dispose();
      controller.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(
          children: [
            MobileDevToolFuzzTapOverlay(
              runner: runner,
              log: log,
              onClose: () {},
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final scrollPosition = tester
        .state<ScrollableState>(
          find.descendant(
            of: find.byType(AnimatedList),
            matching: find.byType(Scrollable),
          ),
        )
        .position;
    expect(scrollPosition.maxScrollExtent, greaterThan(0));
    await tester.drag(find.byType(AnimatedList), const Offset(0, 160));
    await tester.pumpAndSettle();
    expect(scrollPosition.pixels, greaterThan(0));
  });

  testWidgets("keeps expanded Screen Draw toolbar inside the viewport", (
    tester,
  ) async {
    final tool = MobileDevToolAnnotationTool()
      ..toolbarPosition = const Offset(1000, 1000);
    addTearDown(tool.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(children: [MobileDevToolAnnotationOverlay(tool: tool)]),
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

  testWidgets("shows the Fuzz preset sheet above the overlay", (tester) async {
    final controller = MobileDevToolController();
    final log = MobileDevToolFuzzRunLog();
    final runner = MobileDevToolFuzzTapRunner(
      log: log,
      networkController: controller,
    );
    addTearDown(() {
      runner.stop();
      log.dispose();
      controller.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(
          children: [
            MobileDevToolFuzzTapOverlay(
              runner: runner,
              log: log,
              onClose: () {},
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text("Chọn kịch bản"));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey("fuzz-preset-sheet-overlay")),
      findsOneWidget,
    );
    expect(
      find.text("Tự chọn tick interval và thời lượng phiên."),
      findsOneWidget,
    );
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets("asks whether to stop or continue after a terminal fuzz run", (
    tester,
  ) async {
    final controller = MobileDevToolController();
    final log = MobileDevToolFuzzRunLog()
      ..start("Test", "Bắt đầu")
      ..stopTimeLimit("đã hết thời lượng");
    final runner = MobileDevToolFuzzTapRunner(
      log: log,
      networkController: controller,
    );
    var closed = false;
    addTearDown(() {
      runner.stop();
      log.dispose();
      controller.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(
          children: [
            MobileDevToolFuzzTapOverlay(
              runner: runner,
              log: log,
              onClose: () => closed = true,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Fuzz hoàn tất"), findsOneWidget);
    expect(find.byKey(const ValueKey("fuzz-terminal-dialog")), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text("Đóng"), findsOneWidget);
    expect(find.text("Chạy lại"), findsOneWidget);
    expect(find.text("Dừng"), findsNothing);
    expect(find.text("Tiếp tục"), findsNothing);
    await tester.tap(find.text("Đóng"));
    await tester.pumpAndSettle();
    expect(closed, isFalse);
    expect(find.byKey(const ValueKey("fuzz-terminal-dialog")), findsNothing);
    expect(find.byKey(const ValueKey("fuzz-overlay-panel")), findsOneWidget);
  });
}
