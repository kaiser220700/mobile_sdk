import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mobile_ui_kit/mobile_ui_kit.dart";

void main() {
  testWidgets("keeps button content visible while an action is loading", (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: UiKitButton(
            label: "Save changes",
            onPressed: _noop,
            loading: true,
            loadingBehavior: UiKitButtonLoadingBehavior.showBeforeContent,
          ),
        ),
      ),
    );

    expect(find.text("Save changes"), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets("forwards a submitted fixed-height text field", (tester) async {
    String? submitted;
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: UiKitTextField(
            controller: controller,
            label: "Code",
            inputHeight: 44,
            textInputAction: TextInputAction.done,
            onSubmitted: (value) => submitted = value,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), "SCMS");
    await tester.testTextInput.receiveAction(TextInputAction.done);

    expect(submitted, "SCMS");
    expect(tester.getSize(find.byType(TextField)), const Size(800, 44));
  });

  testWidgets("renders a compact status pill with a leading dot", (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: UiKitBadge(
            label: "Active",
            leadingDot: true,
            height: 28,
            horizontalPadding: 8,
            maxWidth: 120,
            semantic: UiKitBadgeSemantic.success,
          ),
        ),
      ),
    );

    expect(find.text("Active"), findsOneWidget);
    expect(find.byType(DecoratedBox), findsWidgets);
  });

  testWidgets("supports stacked key-values and value-first stat tiles", (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: Column(
            children: [
              UiKitKeyValue(
                label: "Assignee",
                value: "",
                emptyValue: "Not assigned",
                layout: UiKitKeyValueLayout.stacked,
                leading: Icon(Icons.person_outline),
                showDivider: true,
              ),
              UiKitStatTile(
                label: "Overdue",
                value: "3",
                layout: UiKitStatTileLayout.valueFirst,
                valueColor: Colors.red,
                showBorder: false,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text("Not assigned"), findsOneWidget);
    expect(
      tester.getTopLeft(find.text("3")).dy,
      lessThan(tester.getTopLeft(find.text("Overdue")).dy),
    );
  });
}

void _noop() {}
