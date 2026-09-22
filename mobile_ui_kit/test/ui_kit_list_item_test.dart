import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mobile_ui_kit/mobile_ui_kit.dart";

void main() {
  testWidgets("uses one line and ellipsis by default", (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: UiKitListItem(title: "Title", description: "Description"),
      ),
    );

    final title = tester.widget<Text>(find.text("Title"));
    final description = tester.widget<Text>(find.text("Description"));

    expect(title.maxLines, 1);
    expect(title.overflow, TextOverflow.ellipsis);
    expect(description.maxLines, 1);
    expect(description.overflow, TextOverflow.ellipsis);
  });

  testWidgets("uses the configured description max lines", (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: UiKitListItem(
          title: "Title",
          description: "Description",
          descriptionMaxLines: 3,
        ),
      ),
    );

    final description = tester.widget<Text>(find.text("Description"));

    expect(description.maxLines, 3);
    expect(description.overflow, TextOverflow.ellipsis);
  });

  testWidgets("clips unbounded description text", (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: UiKitListItem(
          title: "Title",
          description: "Description",
          descriptionMaxLines: null,
        ),
      ),
    );

    final description = tester.widget<Text>(find.text("Description"));

    expect(description.maxLines, isNull);
    expect(description.overflow, TextOverflow.clip);
  });
}
