import "dart:async";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mobile_ui_kit/mobile_ui_kit.dart" as ui;

void main() {
  testWidgets(
    'autocomplete ignores stale results and reports current failures',
    (tester) async {
      final oldSearch = Completer<Iterable<String>>();
      final newSearch = Completer<Iterable<String>>();
      final errors = <Object>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ui.Autocomplete<String>(
              label: 'Search',
              debounceDuration: Duration.zero,
              onSearch: (query) =>
                  query == 'a' ? oldSearch.future : newSearch.future,
              onSearchError: (error, _) => errors.add(error),
              optionBuilder: (_, option) => Text(option),
              optionLabel: (option) => option,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'ab');
      await tester.pump();
      oldSearch.complete(['outdated']);
      await tester.pump();
      expect(find.text('outdated'), findsNothing);
      newSearch.completeError(StateError('offline'));
      await tester.pump();
      expect(errors, hasLength(1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('autocomplete only searches the latest debounced input', (
    tester,
  ) async {
    final queries = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: ui.Autocomplete<String>(
            label: 'Search',
            onSearch: (query) {
              queries.add(query);
              return <String>[];
            },
            optionBuilder: (_, option) => Text(option),
            optionLabel: (option) => option,
            onSelected: (_) {},
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'a');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextField), 'ab');
    await tester.pump(const Duration(milliseconds: 300));
    expect(queries, ['ab']);
    await tester.enterText(find.byType(TextField), 'abc');
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 300));
    expect(queries, ['ab']);
    expect(tester.takeException(), isNull);
  });

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
