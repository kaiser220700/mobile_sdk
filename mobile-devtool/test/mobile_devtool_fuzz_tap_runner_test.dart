import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mobile_devtool/src/mobile_devtool_controller.dart";
import "package:mobile_devtool/src/mobile_devtool_exclude_from_fuzz_tap.dart";
import "package:mobile_devtool/src/mobile_devtool_fuzz_run_log.dart";
import "package:mobile_devtool/src/mobile_devtool_fuzz_run_preset.dart";
import "package:mobile_devtool/src/mobile_devtool_fuzz_tap_runner.dart";

void main() {
  test("resetting the current session preserves older history", () {
    final log = MobileDevToolFuzzRunLog();
    log.start("First", "first");
    log.stopByUser();
    log.start("Second", "second");

    log.resetCurrentSession();

    expect(log.currentSession, isNull);
    expect(log.sessions, hasLength(2));
  });

  testWidgets(
    "fuzz tap invokes a semantic tap target after semantics is ready",
    (tester) async {
      var tapCount = 0;
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
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () => tapCount++,
              child: const Text("Target"),
            ),
          ),
        ),
      );

      runner.start(
        config: const MobileDevToolFuzzRunConfig(
          label: "test",
          description: "test",
          tickInterval: Duration(milliseconds: 1),
          sessionDuration: Duration(seconds: 1),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 5));

      runner.stop();
      expect(tapCount, greaterThan(0));
      expect(log.currentSession?.tapCount, greaterThan(0));
    },
  );

  testWidgets("fuzz tap skips an excluded subtree", (tester) async {
    var tapCount = 0;
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
        home: Scaffold(
          body: ExcludeFromFuzzTap(
            child: ElevatedButton(
              onPressed: () => tapCount++,
              child: const Text("Excluded"),
            ),
          ),
        ),
      ),
    );
    runner.start(
      config: const MobileDevToolFuzzRunConfig(
        label: "test",
        description: "test",
        tickInterval: Duration(milliseconds: 1),
        sessionDuration: Duration(seconds: 1),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 5));

    runner.stop();
    expect(tapCount, 0);
    expect(log.currentSession?.status, MobileDevToolFuzzRunStatus.stoppedStuck);
  });

  testWidgets("fuzz run can pause, resume, and seek a timed session", (
    tester,
  ) async {
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

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    runner.start(
      config: const MobileDevToolFuzzRunConfig(
        label: "test",
        description: "test",
        tickInterval: Duration(seconds: 1),
        sessionDuration: Duration(minutes: 1),
      ),
    );

    runner.pause();
    expect(runner.isRunning, isTrue);
    expect(runner.isPaused, isTrue);
    expect(log.currentSession?.isPaused, isTrue);

    runner.skip(const Duration(seconds: 10));
    expect(
      log.currentSession?.elapsed,
      greaterThanOrEqualTo(const Duration(seconds: 10)),
    );

    runner.resume();
    expect(runner.isPaused, isFalse);
    expect(log.currentSession?.status, MobileDevToolFuzzRunStatus.running);
    runner.stop();
  });
}
