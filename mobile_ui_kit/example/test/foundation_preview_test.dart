import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_ui_kit/mobile_ui_kit.dart' as ui;
import 'package:mobile_ui_kit_example/foundation_preview.dart';

void main() {
  testWidgets('foundation screen renders at phone width and large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: ui.Theme.material(),
        builder: (_, child) => MediaQuery(
          data: MediaQueryData(
            size: const Size(390, 844),
            textScaler: TextScaler.linear(1.5),
          ),
          child: child!,
        ),
        home: const FoundationPreview(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Project settings'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
