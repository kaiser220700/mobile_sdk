import "package:material_ui/material_ui.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mobile_ui_kit/mobile_ui_kit.dart" as ui;

void main() {
  testWidgets("timeline motion interpolates keyframes and settles", (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ui.Motion(
          duration: const Duration(milliseconds: 100),
          builder: (context, frame, child) => Text(
            frame
                .valueAt(const [
                  ui.MotionKeyframe(0, 10),
                  ui.MotionKeyframe(1, 30),
                ])
                .toStringAsFixed(0),
          ),
        ),
      ),
    );

    expect(find.text("10"), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text("20"), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text("30"), findsOneWidget);
  });

  testWidgets("timeline motion renders a static reduced-motion frame", (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: ui.Motion(
            loop: true,
            reducedMotionValue: .5,
            builder: (context, frame, child) =>
                Text("${frame.reduceMotion}:${frame.progress}"),
          ),
        ),
      ),
    );

    expect(find.text("true:0.5"), findsOneWidget);
  });

  testWidgets("timeline motion pauses until activated", (tester) async {
    Widget buildMotion(bool active) => MaterialApp(
      home: ui.Motion(
        active: active,
        duration: const Duration(milliseconds: 100),
        builder: (context, frame, child) =>
            Text(frame.progress.toStringAsFixed(1)),
      ),
    );

    await tester.pumpWidget(buildMotion(false));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text("0.0"), findsOneWidget);

    await tester.pumpWidget(buildMotion(true));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text("0.5"), findsOneWidget);
  });

  testWidgets("motion primitives preserve their child and update values", (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Column(
          children: [
            ui.FadeMotion(child: Text("fade")),
            ui.BouncingMotion(child: Text("bounce")),
            ui.Shimmer(
              baseColor: Colors.grey,
              highlightColor: Colors.white,
              child: Text("shimmer"),
            ),
            ui.FlipCounter(value: 2),
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
              ui.DashedBorder(
                color: Colors.blue,
                child: const SizedBox(width: 80, height: 32),
              ),
              ui.AvatarStack(
                avatars: const [
                  ColoredBox(color: Colors.red),
                  ColoredBox(color: Colors.green),
                ],
              ),
              ui.QuantityStepper(
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

    expect(find.byType(ui.DashedBorder), findsOneWidget);
    expect(find.byType(ui.AvatarStack), findsOneWidget);
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
          body: ui.Autocomplete<String>(
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
    ui.MediaSource? selectedSource;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ui.FileAttachmentTile(
                fileName: "brief.pdf",
                sizeInBytes: 1024,
                onDownload: () => downloaded = true,
              ),
              ui.MediaPicker(
                label: "Receipt",
                onSelectSource: (source) => selectedSource = source,
              ),
              const ui.Countdown(duration: Duration(seconds: 2), paused: true),
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
    expect(selectedSource, ui.MediaSource.gallery);
    expect(find.text("00:02"), findsOneWidget);
  });
}
