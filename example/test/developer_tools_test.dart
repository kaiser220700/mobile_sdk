import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_devtool/mobile_devtool.dart' as dev;
import 'package:mobile_fuzz/mobile_fuzz.dart' as fuzz;
import 'package:mobile_screen_draw/mobile_screen_draw.dart' as draw;
import 'package:mobile_sdk_example/developer_tools.dart';

void main() {
  testWidgets('host composes independent draw and fuzz actions', (
    tester,
  ) async {
    final logs = dev.Controller();
    addTearDown(logs.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              const Text('Host app'),
              DeveloperTools(controller: logs),
            ],
          ),
        ),
      ),
    );
    await tester.tap(
      find.byKey(const ValueKey('mobile-devtool-bubble-surface')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Screen Draw'));
    await tester.pumpAndSettle();
    expect(find.byType(draw.DrawingOverlay), findsOneWidget);
    tester
        .widget<draw.DrawingOverlay>(find.byType(draw.DrawingOverlay))
        .tool
        .hideOverlay();
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('mobile-devtool-bubble-surface')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Fuzz Tap'));
    await tester.pumpAndSettle();
    expect(find.byType(fuzz.RunnerOverlay), findsOneWidget);
    tester
        .widget<fuzz.RunnerOverlay>(find.byType(fuzz.RunnerOverlay))
        .onClose();
    await tester.pumpAndSettle();
    expect(find.byType(fuzz.RunnerOverlay), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
