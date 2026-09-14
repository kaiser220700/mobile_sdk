import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mobile_ui_kit/mobile_ui_kit.dart";

void main() {
  testWidgets("renders the data and form primitives", (tester) async {
    var selected = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: ListView(
            children: [
              const UiKitBadge.textIcon(
                label: "Active",
                icon: Icons.check,
                semantic: UiKitBadgeSemantic.success,
              ),
              UiKitSelectField(label: "Environment", onTap: () {}),
              UiKitFilterChip(
                label: "Only active",
                onSelected: (value) => selected = value,
              ),
              const UiKitStatTile(label: "Users", value: "12,480"),
              const UiKitKeyValue(label: "Region", value: "Asia"),
              const UiKitTimeline(items: [UiKitTimelineItem(title: "Created")]),
              const UiKitStepper(
                currentIndex: 0,
                steps: [UiKitStep(title: "First")],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text("Active"), findsOneWidget);
    expect(find.text("Environment"), findsOneWidget);
    expect(find.text("Users"), findsOneWidget);
    expect(find.text("Region"), findsOneWidget);
    expect(find.text("Created"), findsOneWidget);
    expect(find.text("First"), findsOneWidget);

    await tester.tap(find.text("Only active"));
    await tester.pump();
    expect(selected, isTrue);
  });
}
