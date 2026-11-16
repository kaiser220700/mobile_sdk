import "package:material_ui/material_ui.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mobile_ui_kit/mobile_ui_kit.dart" as ui;

void main() {
  testWidgets("keeps button content visible while an action is loading", (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: ui.Button(
            label: "Save changes",
            onPressed: _noop,
            loading: true,
            loadingBehavior: ui.ButtonLoadingBehavior.showBeforeContent,
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
          child: ui.TextField(
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

  testWidgets("renders a compact status pill with a leading dot", (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: ui.Badge(
            label: "Active",
            leadingDot: true,
            height: 28,
            horizontalPadding: 8,
            maxWidth: 120,
            semantic: ui.BadgeSemantic.success,
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
              ui.KeyValue(
                label: "Assignee",
                value: "",
                emptyValue: "Not assigned",
                layout: ui.KeyValueLayout.stacked,
                leading: Icon(Icons.person_outline),
                showDivider: true,
              ),
              ui.StatTile(
                label: "Overdue",
                value: "3",
                layout: ui.StatTileLayout.valueFirst,
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

  testWidgets("caps count badges with host-provided dimensions", (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: Center(
            child: ui.CountBadge(
              count: 120,
              maxCount: 99,
              height: 18,
              minWidth: 18,
              maxWidth: 40,
            ),
          ),
        ),
      ),
    );

    expect(find.text("99+"), findsOneWidget);
    expect(tester.getSize(find.text("99+")).height, lessThanOrEqualTo(18));
  });

  testWidgets("reports the selected bottom-navigation item", (tester) async {
    var selectedIndex = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: ui.BottomNavigation(
            safeArea: false,
            tapThrottleDuration: Duration.zero,
            selectedIndex: selectedIndex,
            onSelected: (index) => selectedIndex = index,
            items: [
              ui.BottomNavigationItem(
                label: "Home",
                iconBuilder: (color) => Icon(Icons.home, color: color),
              ),
              ui.BottomNavigationItem(
                label: "Inbox",
                iconBuilder: (color) => Icon(Icons.inbox, color: color),
                badge: ui.CountBadge(count: 2),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text("Inbox"));
    expect(selectedIndex, 1);
    expect(find.text("2"), findsOneWidget);
  });

  testWidgets("allows outline-button border overrides", (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: ui.Button.text(
            onPressed: _noop,
            label: "Secondary action",
            variant: ui.ButtonVariant.outline,
            outlineBorderColor: Colors.deepPurple,
            outlineBorderWidth: 2,
          ),
        ),
      ),
    );

    final decoration = tester.widget<DecoratedBox>(
      find.ancestor(
        of: find.text("Secondary action"),
        matching: find.byType(DecoratedBox),
      ),
    );
    final border = (decoration.decoration as BoxDecoration).border! as Border;

    expect(border.top.width, 2);
    expect(border.top.color, Colors.deepPurple);
  });

  testWidgets("reserves at least 16 dp below bottom-navigation items", (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Align(
            alignment: Alignment.topCenter,
            child: ui.BottomNavigation(
              selectedIndex: 0,
              onSelected: _noopIndex,
              items: [
                ui.BottomNavigationItem(
                  label: "Home",
                  iconBuilder: (color) => Icon(Icons.home, color: color),
                ),
                ui.BottomNavigationItem(
                  label: "Inbox",
                  iconBuilder: (color) => Icon(Icons.inbox, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(ui.BottomNavigation)).height, 80);
  });

  testWidgets("puts bottom padding above the bottom safe-area inset", (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.only(bottom: 24)),
          child: Material(
            child: Align(
              alignment: Alignment.topCenter,
              child: ui.BottomNavigation(
                selectedIndex: 0,
                onSelected: _noopIndex,
                items: [
                  ui.BottomNavigationItem(
                    label: "Home",
                    iconBuilder: (color) => Icon(Icons.home, color: color),
                  ),
                  ui.BottomNavigationItem(
                    label: "Inbox",
                    iconBuilder: (color) => Icon(Icons.inbox, color: color),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(ui.BottomNavigation)).height, 104);
  });

  testWidgets("button exposes its accessible name only once", (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: Material(
            child: ui.Button.text(onPressed: _noop, label: "Save changes"),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(ui.Button)),
        matchesSemantics(
          label: "Save changes",
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasSelectedState: true,
        ),
      );
    } finally {
      semantics.dispose();
    }
  });

  testWidgets("keeps scaffold content unpadded when safe area is disabled", (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ui.Scaffold(
          safeArea: false,
          child: SizedBox(key: Key("content"), height: 10),
        ),
      ),
    );

    expect(find.byType(Scaffold), findsOneWidget);
    expect(tester.getSize(find.byKey(const Key("content"))).height, 10);
  });

  testWidgets("renders a host-styled filter chip without a selected icon", (
    tester,
  ) async {
    var selected = true;
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: ui.FilterChip(
            label: "All",
            trailingText: "3",
            selected: selected,
            selectedIcon: null,
            selectedBackgroundColor: Colors.blue,
            selectedForegroundColor: Colors.white,
            height: 36,
            touchHeight: 44,
            animationDuration: Duration.zero,
            tapThrottleDuration: Duration.zero,
            onSelected: (value) => selected = value,
          ),
        ),
      ),
    );

    expect(find.text("All"), findsOneWidget);
    expect(find.text("3"), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);
    await tester.tap(find.text("All"));
    expect(selected, isFalse);
  });
}

void _noop() {}

void _noopIndex(int _) {}
