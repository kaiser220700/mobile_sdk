import "package:mobile_fuzz/mobile_fuzz.dart";
import "package:material_ui/material_ui.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  testWidgets("host error snapshots stop only for new failures", (
    tester,
  ) async {
    final failures = [const NetworkFailure(id: "old", message: "old error")];
    final log = SessionLog();
    final runner = Runner(log: log, networkFailures: () => failures);
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    runner.start(
      config: const RunConfig(
        label: "test",
        description: "test",
        tickInterval: Duration(milliseconds: 1),
        sessionDuration: null,
      ),
    );
    failures.add(const NetworkFailure(id: "new", message: "new error"));
    await tester.pump(const Duration(milliseconds: 2));
    expect(runner.isRunning, isFalse);
    expect(log.currentSession?.status, SessionStatus.stoppedNetworkError);
    runner.stop();
    log.dispose();
  });

  testWidgets("a failing host error reader leaves no running session", (
    tester,
  ) async {
    final log = SessionLog();
    final runner = Runner(
      log: log,
      networkFailures: () => throw StateError("host unavailable"),
    );
    runner.start(
      config: const RunConfig(
        label: "test",
        description: "test",
        tickInterval: Duration(milliseconds: 1),
        sessionDuration: null,
      ),
    );
    expect(runner.isRunning, isFalse);
    expect(log.currentSession?.status, SessionStatus.stoppedStuck);
    log.dispose();
  });

  test("resetting the current session preserves older history", () {
    final log = SessionLog();
    log.start("First", "first");
    log.stopByUser();
    log.start("Second", "second");

    log.resetCurrentSession();

    expect(log.currentSession, isNull);
    expect(log.sessions, hasLength(2));
  });

  test(
    "fails a route-restricted run safely when the host route accessor throws",
    () {
      final log = SessionLog();
      final runner = Runner(
        log: log,
        currentRouteKey: () => throw StateError('route unavailable'),
      );
      addTearDown(() {
        runner.stop();
        log.dispose();
      });

      runner.start(
        config: const RunConfig(
          label: 'test',
          description: 'test',
          tickInterval: Duration(seconds: 1),
          sessionDuration: null,
          restrictToCurrentRoute: true,
        ),
      );

      expect(runner.isRunning, isFalse);
      expect(log.currentSession?.status, SessionStatus.stoppedStuck);
    },
  );

  testWidgets(
    "fuzz tap invokes a semantic tap target after semantics is ready",
    (tester) async {
      var tapCount = 0;
      final log = SessionLog();
      final runner = Runner(log: log);
      addTearDown(() {
        runner.stop();
        log.dispose();
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
        config: const RunConfig(
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
    final log = SessionLog();
    final runner = Runner(log: log);
    addTearDown(() {
      runner.stop();
      log.dispose();
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
      config: const RunConfig(
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
    expect(log.currentSession?.status, SessionStatus.stoppedStuck);
  });

  testWidgets("fuzz run can pause, resume, and seek a timed session", (
    tester,
  ) async {
    final log = SessionLog();
    final runner = Runner(log: log);
    addTearDown(() {
      runner.stop();
      log.dispose();
    });

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    runner.start(
      config: const RunConfig(
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
    expect(log.currentSession?.status, SessionStatus.running);
    runner.stop();
  });
}
