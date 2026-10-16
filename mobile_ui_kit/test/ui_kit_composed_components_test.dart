import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mobile_ui_kit/mobile_ui_kit.dart" as ui;

void main() {
  testWidgets("renders the data and form primitives", (tester) async {
    var selected = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: ListView(
            children: [
              const ui.Badge.textIcon(
                label: "Active",
                icon: Icons.check,
                semantic: ui.BadgeSemantic.success,
              ),
              ui.SelectField(label: "Environment", onTap: () {}),
              ui.FilterChip(
                label: "Only active",
                onSelected: (value) => selected = value,
              ),
              const ui.StatTile(label: "Users", value: "12,480"),
              const ui.KeyValue(label: "Region", value: "Asia"),
              const ui.Timeline(items: [ui.TimelineItem(title: "Created")]),
              const ui.Stepper(
                currentIndex: 0,
                steps: [ui.Step(title: "First")],
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
