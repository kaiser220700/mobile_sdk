import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_ui_kit/mobile_ui_kit.dart' as ui;

void main() {
  test('leases retain other tasks and release is idempotent', () {
    final controller = ui.LoadingController();
    final a = controller.acquire();
    final b = controller.acquire();
    controller.showSuccess();
    expect(controller.step, ui.LoadingStep.spinner);
    a();
    a();
    expect(controller.activeCount, 1);
    controller.hide();
    expect(controller.visible, isTrue);
    b();
    expect(controller.visible, isFalse);
    controller.dispose();
    b();
    expect(controller.acquire, throwsStateError);
  });

  test('run releases on success, sync failure and async failure', () async {
    final controller = ui.LoadingController();
    expect(await controller.run(() async => 42), 42);
    await expectLater(
      controller.run<void>(() => throw StateError('sync')),
      throwsStateError,
    );
    await expectLater(
      controller.run<void>(() async => throw StateError('async')),
      throwsStateError,
    );
    expect(controller.activeCount, 0);
    expect(controller.visible, isFalse);
    final work = Completer<void>();
    final pending = controller.run(() => work.future);
    controller.dispose();
    work.complete();
    await pending;
  });

  test('manual state remains after leases finish', () {
    final controller = ui.LoadingController();
    final release = controller.acquire();
    controller.showError();
    release();
    expect(controller.visible, isTrue);
    expect(controller.step, ui.LoadingStep.error);
    controller.hide();
    expect(controller.visible, isFalse);
    controller.dispose();
  });

  Widget host(Widget child) => MaterialApp(
    home: Scaffold(
      body: Center(child: SizedBox(width: 320, child: child)),
    ),
  );

  testWidgets('overlay stays blocked until the last task releases', (
    tester,
  ) async {
    final controller = ui.LoadingController();
    var taps = 0;
    final releaseA = controller.acquire();
    final releaseB = controller.acquire();
    await tester.pumpWidget(
      host(
        SizedBox(
          height: 240,
          child: ui.LoadingOverlay(
            controller: controller,
            animationDuration: Duration.zero,
            builder: (_, _) => const Center(child: Text('Working')),
            child: TextButton(
              onPressed: () => taps++,
              child: const Text('Action'),
            ),
          ),
        ),
      ),
    );
    releaseA();
    await tester.pump();
    await tester.tap(find.text('Action'), warnIfMissed: false);
    expect(taps, 0);
    releaseB();
    await tester.pump();
    await tester.tap(find.text('Action'));
    expect(taps, 1);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('source cancellation and disallowed result do not select', (
    tester,
  ) async {
    var selected = 0;
    ui.MediaSource? result;
    await tester.pumpWidget(
      host(
        ui.MediaPicker(
          label: 'Photo',
          allowedSources: const {ui.MediaSource.file},
          onSelectSource: (_) => selected++,
          sourcePicker: (_, _) async => result,
        ),
      ),
    );
    await tester.tap(find.text('Add media'));
    await tester.pump();
    expect(selected, 0);
    result = ui.MediaSource.camera;
    await tester.tap(find.text('Add media'));
    await tester.pump();
    expect(selected, 0);
  });

  testWidgets(
    'empty picker shows error and indeterminate upload locks source',
    (tester) async {
      var selected = 0;
      await tester.pumpWidget(
        host(
          ui.MediaPicker(
            label: 'Photo',
            errorText: 'Cannot read',
            uploading: true,
            errorStyle: const TextStyle(color: Colors.purple),
            onSelectSource: (_) => selected++,
          ),
        ),
      );
      expect(find.text('Cannot read'), findsOneWidget);
      expect(
        tester.widget<Text>(find.text('Cannot read')).style!.color,
        Colors.purple,
      );
      expect(
        tester
            .widget<CircularProgressIndicator>(
              find.byType(CircularProgressIndicator),
            )
            .value,
        isNull,
      );
      await tester.tap(find.text('Add media'));
      await tester.pump();
      expect(find.text('Camera'), findsNothing);
      expect(selected, 0);
    },
  );

  testWidgets(
    'host controls respect upload lock and use custom source presentation',
    (tester) async {
      var sourceCalls = 0;
      var removed = 0;
      ui.MediaSource? selected;
      Widget picker(bool uploading) => ui.MediaPicker(
        label: 'Photo',
        preview: const ColoredBox(color: Colors.red),
        uploading: uploading,
        onRemove: () => removed++,
        onSelectSource: (value) => selected = value,
        allowedSources: const {ui.MediaSource.file},
        sourcePicker: (_, allowed) async {
          sourceCalls++;
          expect(allowed, {ui.MediaSource.file});
          return ui.MediaSource.file;
        },
        replaceButtonBuilder: (_, callback) =>
            TextButton(onPressed: callback, child: const Text('Choose')),
        removeButtonBuilder: (_, callback) =>
            TextButton(onPressed: callback, child: const Text('Delete')),
      );
      await tester.pumpWidget(host(picker(true)));
      await tester.tap(find.text('Choose'));
      expect(find.text('Delete'), findsNothing);
      expect(sourceCalls, 0);
      await tester.pumpWidget(host(picker(false)));
      await tester.tap(find.text('Choose'));
      await tester.pump();
      expect(selected, ui.MediaSource.file);
      await tester.tap(find.text('Delete'));
      expect(removed, 1);
    },
  );

  testWidgets('late source completion respects current state and disposal', (
    tester,
  ) async {
    var selected = 0;
    var pending = Completer<ui.MediaSource?>();
    Widget picker(bool enabled) => ui.MediaPicker(
      label: 'Photo',
      enabled: enabled,
      onSelectSource: (_) => selected++,
      sourcePicker: (_, _) => pending.future,
    );
    await tester.pumpWidget(host(picker(true)));
    await tester.tap(find.text('Add media'));
    await tester.pumpWidget(host(picker(false)));
    pending.complete(ui.MediaSource.camera);
    await tester.pump();
    expect(selected, 0);
    pending = Completer<ui.MediaSource?>();
    await tester.pumpWidget(host(picker(true)));
    await tester.tap(find.text('Add media'));
    await tester.pumpWidget(const SizedBox());
    pending.complete(ui.MediaSource.camera);
    await tester.pump();
    expect(selected, 0);
    expect(tester.takeException(), isNull);
  });
}
