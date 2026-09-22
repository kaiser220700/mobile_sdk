import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mobile_ui_kit/mobile_ui_kit.dart";

void main() {
  testWidgets("motion primitives preserve their child and update values", (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Column(
          children: [
            UiKitFadeMotion(child: Text("fade")),
            UiKitBouncingMotion(child: Text("bounce")),
            UiKitShimmer(
              baseColor: Colors.grey,
              highlightColor: Colors.white,
              child: Text("shimmer"),
            ),
            UiKitFlipCounter(value: 2),
          ],
        ),
      ),
    );

    expect(find.text("fade"), findsOneWidget);
    expect(find.text("bounce"), findsOneWidget);
    expect(find.byType(ShaderMask), findsOneWidget);
    expect(find.text("2"), findsOneWidget);
  });

  testWidgets("extra layout primitives compose with UI Kit controls", (
    tester,
  ) async {
    var value = 2;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              UiKitDashedBorder(
                color: Colors.blue,
                child: const SizedBox(width: 80, height: 32),
              ),
              UiKitAvatarStack(
                avatars: const [
                  ColoredBox(color: Colors.red),
                  ColoredBox(color: Colors.green),
                ],
              ),
              UiKitQuantityStepper(
                value: value,
                min: 1,
                max: 3,
                onChanged: (next) => setState(() => value = next),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(UiKitDashedBorder), findsOneWidget);
    expect(find.byType(UiKitAvatarStack), findsOneWidget);
    await tester.tap(find.bySemanticsLabel("Increase Quantity"));
    await tester.pump();
    expect(find.text("3"), findsOneWidget);
  });

  testWidgets("async suggestions delegate search and selection to the host", (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UiKitAsyncSuggestionField<String>(
            label: "Assignee",
            debounceDuration: Duration.zero,
            onSearch: (query) => ["Ada Lovelace"],
            optionLabel: (option) => option,
            optionBuilder: (context, option) => ListTile(title: Text(option)),
            onSelected: (option) => selected = option,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), "ada");
    await tester.pumpAndSettle();
    await tester.tap(find.text("Ada Lovelace"));
    expect(selected, "Ada Lovelace");
  });

  testWidgets("attachment and media fields delegate host actions", (
    tester,
  ) async {
    var downloaded = false;
    UiKitMediaSource? selectedSource;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              UiKitFileAttachmentTile(
                fileName: "brief.pdf",
                sizeInBytes: 1024,
                onDownload: () => downloaded = true,
              ),
              UiKitMediaPicker(
                label: "Receipt",
                onSelectSource: (source) => selectedSource = source,
              ),
              const UiKitCountdown(
                duration: Duration(seconds: 2),
                paused: true,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.download_outlined));
    expect(downloaded, isTrue);
    await tester.tap(find.text("Add media"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Photo library"));
    expect(selectedSource, UiKitMediaSource.gallery);
    expect(find.text("00:02"), findsOneWidget);
  });
}
