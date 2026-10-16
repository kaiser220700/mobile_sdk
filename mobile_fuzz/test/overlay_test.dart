import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mobile_fuzz/mobile_fuzz.dart";
import "package:mobile_fuzz/src/theme.dart";

void main() {
  testWidgets("keeps expanded Fuzz Tap inside the viewport", (tester) async {
    final log = SessionLog();
    final runner = Runner(log: log);
    log.start("Test", "first log");
    log.log("second log");
    log.log("latest log");
    addTearDown(() {
      runner.stop();
      log.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(
          children: [RunnerOverlay(runner: runner, log: log, onClose: () {})],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byTooltip("Thu gọn"), findsNothing);
    final scrim = tester.widget<ColoredBox>(
      find.byKey(const ValueKey("fuzz-overlay-scrim")),
    );
    expect(scrim.color, ToolTheme.fuzzOverlayScrim);
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
    final log = SessionLog()..start("Test", "scroll log 0");
    for (var index = 1; index < 10; index++) {
      log.log("scroll log $index");
    }
    final runner = Runner(log: log);
    addTearDown(() {
      runner.stop();
      log.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(
          children: [RunnerOverlay(runner: runner, log: log, onClose: () {})],
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

  testWidgets("shows the Fuzz preset sheet above the overlay", (tester) async {
    final log = SessionLog();
    final runner = Runner(log: log);
    addTearDown(() {
      runner.stop();
      log.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(
          children: [RunnerOverlay(runner: runner, log: log, onClose: () {})],
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
    final log = SessionLog()
      ..start("Test", "Bắt đầu")
      ..stopTimeLimit("đã hết thời lượng");
    final runner = Runner(log: log);
    var closed = false;
    addTearDown(() {
      runner.stop();
      log.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(
          children: [
            RunnerOverlay(
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
