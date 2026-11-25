import "package:material_ui/material_ui.dart";
import "package:flutter/semantics.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mobile_ui_kit/mobile_ui_kit.dart" as ui;

Widget host(Widget child, {ui.ThemeData tokens = ui.ThemeData.defaults}) =>
    MaterialApp(
      theme: ui.Theme.material(tokens: tokens),
      home: Material(
        child: Center(child: SizedBox(width: 320, child: child)),
      ),
    );

void main() {
  testWidgets(
    'notification metadata is below description and dot stays at the right',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          ui.ListItem(
            title: 'New notification',
            description: 'Details',
            titleStyle: const TextStyle(fontWeight: FontWeight.w600),
            crossAxisAlignment: CrossAxisAlignment.start,
            leading: const Icon(Icons.notifications),
            meta: const Text('Today, 14:42'),
            trailing: const SizedBox(
              key: ValueKey('unread'),
              width: 8,
              height: 8,
            ),
            semanticLabel: 'Unread notification. Details. Today, 14:42',
            onTap: () {},
          ),
        ),
      );
      expect(
        tester.getTopLeft(find.text('Today, 14:42')).dy,
        greaterThan(tester.getBottomLeft(find.text('Details')).dy),
      );
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('unread'))).dx,
        greaterThan(tester.getTopRight(find.text('Today, 14:42')).dx),
      );
      expect(
        tester.widget<Text>(find.text('New notification')).style!.fontWeight,
        FontWeight.w600,
      );
      final node = tester.getSemantics(find.byType(ui.ListItem));
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      expect(node.label, 'Unread notification. Details. Today, 14:42');
      semantics.dispose();
    },
  );

  testWidgets(
    'external loading retains label and blocks pointer, keyboard and semantics',
    (tester) async {
      final semantics = tester.ensureSemantics();
      var calls = 0;
      await tester.pumpWidget(
        host(
          ui.Button(
            label: 'Submit',
            loading: true,
            loadingBehavior: ui.ButtonLoadingBehavior.external,
            onPressed: () => calls++,
          ),
        ),
      );
      expect(find.text('Submit'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.tap(find.text('Submit'));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      final node = tester.getSemantics(find.byType(ui.Button));
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
      expect(calls, 0);
      semantics.dispose();
    },
  );

  testWidgets(
    'alert quote, source and action remain accessible without duplicate title',
    (tester) async {
      final semantics = tester.ensureSemantics();
      var calls = 0;
      await tester.pumpWidget(
        host(
          ui.AlertBanner(
            title: 'Review required',
            description: 'Check the documents',
            quote: 'Please supply a clearer image',
            quoteSource: 'Station manager',
            semantic: ui.AlertSemantic.neutral,
            showBorder: false,
            leading: const Icon(Icons.info),
            meta: const Text('Updated today'),
            action: ui.AlertAction(label: 'Review', onPressed: () => calls++),
          ),
        ),
      );
      expect(find.bySemanticsLabel(RegExp('Review required')), findsOneWidget);
      expect(find.text('Please supply a clearer image'), findsOneWidget);
      expect(find.text('Station manager'), findsOneWidget);
      await tester.tap(find.text('Review'));
      expect(calls, 1);
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(ui.AlertBanner),
              matching: find.byType(Container),
            )
            .first,
      );
      expect((container.decoration! as BoxDecoration).border, isNull);
      semantics.dispose();
    },
  );

  testWidgets('custom bodies replace defaults and metadata remains visible', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ui.ListItem(
              title: 'List fallback',
              body: Text('List body'),
              meta: Text('List meta'),
            ),
            ui.StatTile(
              label: 'Stat fallback',
              value: '0',
              body: Text('Stat body'),
              meta: Text('Stat meta'),
            ),
            ui.AlertBanner(
              title: 'Alert fallback',
              body: Text('Alert body'),
              meta: Text('Alert meta'),
            ),
            ui.Timeline(
              items: [
                ui.TimelineItem(
                  title: 'Timeline fallback',
                  body: Text('Timeline body'),
                  meta: Text('Timeline meta'),
                  leading: SizedBox(width: 8, height: 8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    for (final name in ['List', 'Stat', 'Alert', 'Timeline']) {
      expect(find.text('$name fallback'), findsNothing);
      expect(find.text('$name body'), findsOneWidget);
      expect(find.text('$name meta'), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'timeline metadata sits below the event and final connector is absent',
    (tester) async {
      await tester.pumpWidget(
        host(
          const ui.Timeline(
            items: [
              ui.TimelineItem(title: 'Created', meta: Text('Today, 09:10')),
              ui.TimelineItem(title: 'Confirmed', meta: Text('Today, 09:12')),
            ],
          ),
        ),
      );
      expect(
        tester.getTopLeft(find.text('Today, 09:10')).dy,
        greaterThan(tester.getBottomLeft(find.text('Created')).dy),
      );
      // One connector between two entries; the terminal entry has no outgoing line.
      final lines = find.descendant(
        of: find.byType(ui.Timeline),
        matching: find.byWidgetPredicate(
          (widget) => widget is Container && widget.constraints?.maxWidth == 1,
        ),
      );
      expect(lines, findsOneWidget);
    },
  );

  test('theme copy and interpolation retain component sizes, motion and numeric type', () {
    final first = ui.ThemeData.defaults.copyWith(
      title: const TextStyle(fontSize: 30),
      sizes: const ui.ComponentSizes(rowLg: 80, dotSize: 10),
      motion: const ui.MotionTokens(base: Duration(milliseconds: 100)),
    );
    final second = first.copyWith(
      sizes: first.sizes.copyWith(rowLg: 100),
      motion: first.motion.copyWith(base: const Duration(milliseconds: 300)),
      numeric: const TextStyle(
        fontSize: 40,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );
    expect(first.numeric.fontSize, 30);
    expect(
      first.numeric.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
    final middle = first.lerp(second, .5);
    expect(middle.sizes.rowLg, 90);
    expect(middle.sizes.dotSize, 10);
    expect(middle.motion.base, const Duration(milliseconds: 200));
    expect(middle.numeric.fontSize, 35);
    expect(second.copyWith(primary: Colors.red).numeric.fontSize, 40);
  });

  testWidgets(
    'host numeric typography and size tokens reach stats and countdowns',
    (tester) async {
      final tokens = ui.ThemeData.defaults.copyWith(
        numeric: const TextStyle(
          fontSize: 31,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
        sizes: const ui.ComponentSizes(statMinHeight: 120, rowMd: 90),
      );
      await tester.pumpWidget(
        host(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ui.StatTile(
                label: 'Overdue',
                value: '12',
                valueColor: Colors.red,
              ),
              ui.Countdown(duration: Duration(minutes: 1), paused: true),
              ui.ListItem(title: 'One row'),
            ],
          ),
          tokens: tokens,
        ),
      );
      expect(tester.widget<Text>(find.text('12')).style!.fontSize, 31);
      expect(tester.widget<Text>(find.text('12')).style!.color, Colors.red);
      expect(
        tester.widget<Text>(find.text('01:00')).style!.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
      expect(
        tester.getSize(find.byType(ui.StatTile)).height,
        greaterThanOrEqualTo(120),
      );
      expect(
        tester.getSize(find.byType(ui.ListItem)).height,
        greaterThanOrEqualTo(90),
      );
    },
  );

  testWidgets('reduced motion overrides host animation durations', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: ui.FilterChip(label: 'Filter', onSelected: (_) {}),
        ),
      ),
    );
    expect(
      find.descendant(
        of: find.byType(ui.FilterChip),
        matching: find.byType(AnimatedContainer),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'badge dot follows the host size and an explicit name is read once',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          const ui.Badge(
            label: 'Pending',
            leadingDot: true,
            semanticsLabel: 'Pending approval',
          ),
          tokens: ui.ThemeData.defaults.copyWith(
            sizes: const ui.ComponentSizes(dotSize: 11),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Pending approval'), findsOneWidget);
      expect(find.bySemanticsLabel('Pending'), findsNothing);
      final dots = find.descendant(
        of: find.byType(ui.Badge),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is SizedBox && widget.width == 11 && widget.height == 11,
        ),
      );
      expect(dots, findsOneWidget);
      semantics.dispose();
    },
  );

  testWidgets(
    'select locks activation when disabled and retains its accessible name',
    (tester) async {
      var taps = 0;
      final semantics = tester.ensureSemantics();
      Widget field(bool enabled) => host(
        ui.SelectField(
          label: 'Environment',
          value: 'Production',
          enabled: enabled,
          semanticsLabel: 'Choose environment',
          onTap: () => taps++,
        ),
      );
      await tester.pumpWidget(field(true));
      await tester.tap(find.text('Production'));
      expect(taps, 1);
      await tester.pumpWidget(field(false));
      final node = tester.getSemantics(
        find.bySemanticsLabel('Choose environment'),
      );
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
      await tester.tap(find.text('Production'));
      expect(taps, 1);
      semantics.dispose();
    },
  );

  testWidgets(
    'visible loading hides background semantics and releases it when done',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final controller = ui.LoadingController();
      final focus = FocusNode();
      await tester.pumpWidget(
        host(
          SizedBox(
            height: 200,
            child: ui.LoadingOverlay(
              controller: controller,
              animationDuration: Duration.zero,
              builder: (_, _) => const Text('Processing'),
              child: TextButton(
                focusNode: focus,
                autofocus: true,
                onPressed: () {},
                child: const Text('Background action'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(focus.hasFocus, isTrue);
      final release = controller.acquire();
      await tester.pump();
      expect(focus.hasFocus, isFalse);
      expect(find.bySemanticsLabel(RegExp('Background action')), findsNothing);
      expect(find.bySemanticsLabel('Processing'), findsOneWidget);
      release();
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp('Background action')),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Processing'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      focus.dispose();
      controller.dispose();
      semantics.dispose();
    },
  );
}
