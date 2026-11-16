import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';
import 'package:mobile_ui_kit/mobile_ui_kit.dart' as ui;

void main() {
  LeakTesting.enable();
  testWidgets('disposing autocomplete cancels a long pending debounce', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: ui.Autocomplete<String>(
            label: 'Search',
            debounceDuration: const Duration(days: 1),
            onSearch: (_) => throw StateError('disposed search must not run'),
            optionLabel: (value) => value,
            optionBuilder: (_, value) => Text(value),
            onSelected: (_) {},
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'query');
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'repeated mount rebuild interaction and disposal releases resources',
    (tester) async {
      for (var cycle = 0; cycle < 20; cycle++) {
        final loading = ui.LoadingController();
        final overlay = ui.OverlayController();
        final queue = ui.ToastQueue();
        final release = loading.acquire();
        for (var rebuild = 0; rebuild < 5; rebuild++) {
          await tester.pumpWidget(
            MaterialApp(
              home: Material(
                child: ui.ToastOverlay(
                  queue: queue,
                  child: ui.LoadingOverlay(
                    controller: loading,
                    builder: (_, _) => const Center(child: Text('Loading')),
                    child: Column(
                      children: [
                        ui.Motion(
                          loop: true,
                          builder: (_, frame, _) => Text('${frame.progress}'),
                        ),
                        ui.FadeMotion(child: Text('Fade $rebuild')),
                        ui.ListEntrance(
                          index: cycle,
                          child: const Text('Item'),
                        ),
                        ui.Countdown(duration: Duration(seconds: rebuild + 1)),
                        ui.Search(value: '', onChanged: (_) {}),
                        ui.Autocomplete<String>(
                          label: 'Search',
                          onSearch: (_) => const ['result'],
                          optionLabel: (value) => value,
                          optionBuilder: (_, value) => Text(value),
                          onSelected: (_) {},
                        ),
                        ui.AnchoredOverlay(
                          controller: overlay,
                          overlayBuilder: (_) => const Text('Overlay'),
                          child: const Text('Target'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 16));
        }
        queue.enqueue(
          ui.ToastRequest.content(
            type: ui.ToastType.normal,
            content: const ui.ToastContent(title: 'Title', message: 'Message'),
          ),
        );
        release();
        overlay.show();
        await tester.pump();
        await tester.pumpWidget(const SizedBox());
        queue.dispose();
        overlay.dispose();
        loading.dispose();
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
      await tester.pump(const Duration(seconds: 2));
      expect(tester.binding.transientCallbackCount, 0);
    },
  );
}
