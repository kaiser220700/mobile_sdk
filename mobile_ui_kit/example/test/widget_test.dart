import "package:flutter_test/flutter_test.dart";

import "package:mobile_ui_kit_example/main.dart";

void main() {
  testWidgets("renders the component preview", (tester) async {
    await tester.pumpWidget(const UiKitPreviewApp());
    expect(find.text("mobile_ui_kit"), findsOneWidget);
    expect(find.text("UI Kit Preview"), findsOneWidget);
    expect(find.text("alert-banner"), findsOneWidget);
  });
}
