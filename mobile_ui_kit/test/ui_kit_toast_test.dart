import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mobile_ui_kit/mobile_ui_kit.dart";

void main() {
  late UiKitToastQueue queue;

  setUp(() => queue = UiKitToastQueue());
  tearDown(() => queue.dispose());

  Future<void> pumpToastOverlay(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      home: UiKitToastOverlay(
        queue: queue,
        child: const Scaffold(body: SizedBox.expand()),
      ),
    ),
  );

  UiKitToastRequest notification({
    VoidCallback? onTap,
    VoidCallback? onDismiss,
    Duration duration = const Duration(seconds: 4),
    String? semanticLabel,
    UiKitToastAppearance? appearance,
    UiKitToastDragBehavior dragBehavior = UiKitToastDragBehavior.standard,
    UiKitToastEntrance entrance = UiKitToastEntrance.none,
    Duration entranceDuration = const Duration(milliseconds: 200),
  }) => UiKitToastRequest.content(
    type: UiKitToastType.success,
    duration: duration,
    onDismiss: onDismiss,
    content: UiKitToastContent(
      title: "New order",
      message: "Order #123 is ready",
      semanticLabel: semanticLabel,
      onTap: onTap,
      appearance: appearance,
      dragBehavior: dragBehavior,
      entrance: entrance,
      entranceDuration: entranceDuration,
    ),
  );

  testWidgets("structured toast dismisses after its timeout", (tester) async {
    var dismissed = 0;
    queue.enqueue(
      notification(
        duration: const Duration(seconds: 1),
        onDismiss: () => dismissed += 1,
      ),
    );
    await pumpToastOverlay(tester);

    expect(find.text("New order"), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));

    expect(queue.current, isNull);
    expect(dismissed, 1);
  });

  testWidgets("tap invokes the action only after user interaction", (
    tester,
  ) async {
    var tapped = 0;
    queue.enqueue(notification(onTap: () => tapped += 1));
    await pumpToastOverlay(tester);

    expect(tapped, 0);
    await tester.tap(find.text("New order"));
    await tester.pump();

    expect(tapped, 1);
    expect(queue.current, isNull);
  });

  for (final (name, gesture) in <(String, Offset)>[
    ("up", const Offset(0, -60)),
    ("left", const Offset(-60, 0)),
    ("right", const Offset(60, 0)),
  ]) {
    testWidgets("$name swipe dismisses a structured toast", (tester) async {
      queue.enqueue(notification());
      await pumpToastOverlay(tester);

      await tester.drag(
        find.byKey(const ValueKey("ui-kit-toast-surface")),
        gesture,
      );
      await tester.pump();

      expect(queue.current, isNull);
    });
  }

  testWidgets(
    "default downward drags move, then return to the original position",
    (tester) async {
      queue.enqueue(notification());
      await pumpToastOverlay(tester);
      final surface = find.byKey(const ValueKey("ui-kit-toast-surface"));
      final original = tester.getTopLeft(surface);

      final gesture = await tester.startGesture(tester.getCenter(surface));
      await gesture.moveBy(const Offset(0, 24));
      await tester.pump();

      expect(tester.getTopLeft(surface).dy, greaterThan(original.dy));

      await gesture.up();
      await tester.pumpAndSettle();

      expect(queue.current, isNotNull);
      expect(tester.getTopLeft(surface), original);
    },
  );

  testWidgets("lockDownward keeps a downward drag at its resting position", (
    tester,
  ) async {
    queue.enqueue(
      notification(dragBehavior: UiKitToastDragBehavior.lockDownward),
    );
    await pumpToastOverlay(tester);
    final surface = find.byKey(const ValueKey("ui-kit-toast-surface"));
    final original = tester.getTopLeft(surface);

    final gesture = await tester.startGesture(tester.getCenter(surface));
    await gesture.moveBy(const Offset(0, 60));
    await tester.pump();

    expect(tester.getTopLeft(surface), original);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(queue.current, isNotNull);
  });

  testWidgets("lockDownward keeps diagonal downward swipes horizontal", (
    tester,
  ) async {
    queue.enqueue(
      notification(dragBehavior: UiKitToastDragBehavior.lockDownward),
    );
    await pumpToastOverlay(tester);
    final surface = find.byKey(const ValueKey("ui-kit-toast-surface"));
    final original = tester.getTopLeft(surface);

    final gesture = await tester.startGesture(tester.getCenter(surface));
    await gesture.moveBy(const Offset(60, 24));
    await tester.pump();

    final moved = tester.getTopLeft(surface);
    expect(moved.dx, greaterThan(original.dx));
    expect(moved.dy, original.dy);
    await gesture.up();
    await tester.pump();
    expect(queue.current, isNull);
  });

  testWidgets("lockDownward ignores movement inside its activation range", (
    tester,
  ) async {
    queue.enqueue(
      notification(dragBehavior: UiKitToastDragBehavior.lockDownward),
    );
    await pumpToastOverlay(tester);
    final surface = find.byKey(const ValueKey("ui-kit-toast-surface"));
    final original = tester.getTopLeft(surface);

    final gesture = await tester.startGesture(tester.getCenter(surface));
    await gesture.moveBy(const Offset(8, -8));
    await tester.pump();

    expect(tester.getTopLeft(surface), original);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(queue.current, isNotNull);
  });

  testWidgets("lockDownward retains upward dismiss", (tester) async {
    queue.enqueue(
      notification(dragBehavior: UiKitToastDragBehavior.lockDownward),
    );
    await pumpToastOverlay(tester);

    await tester.drag(
      find.byKey(const ValueKey("ui-kit-toast-surface")),
      const Offset(0, -60),
    );
    await tester.pump();

    expect(queue.current, isNull);
  });

  testWidgets("lockDownward keeps diagonal upward swipes vertical", (
    tester,
  ) async {
    queue.enqueue(
      notification(dragBehavior: UiKitToastDragBehavior.lockDownward),
    );
    await pumpToastOverlay(tester);
    final surface = find.byKey(const ValueKey("ui-kit-toast-surface"));
    final original = tester.getTopLeft(surface);

    final gesture = await tester.startGesture(tester.getCenter(surface));
    await gesture.moveBy(const Offset(60, -60));
    await tester.pump();

    final moved = tester.getTopLeft(surface);
    expect(moved.dx, original.dx);
    expect(moved.dy, lessThan(original.dy));
    await gesture.up();
    await tester.pump();
    expect(queue.current, isNull);
  });

  testWidgets(
    "lockDownward keeps horizontal drags smooth despite upward jitter",
    (tester) async {
      queue.enqueue(
        notification(dragBehavior: UiKitToastDragBehavior.lockDownward),
      );
      await pumpToastOverlay(tester);
      final surface = find.byKey(const ValueKey("ui-kit-toast-surface"));
      final original = tester.getTopLeft(surface);

      final gesture = await tester.startGesture(tester.getCenter(surface));
      await gesture.moveBy(const Offset(12, -2));
      await gesture.moveBy(const Offset(48, 2));
      await tester.pump();

      final moved = tester.getTopLeft(surface);
      expect(moved.dx, greaterThan(original.dx));
      expect(moved.dy, original.dy);
      await gesture.up();
      await tester.pump();
      expect(queue.current, isNull);
    },
  );

  testWidgets(
    "lockDownward retains a horizontal fling in a downward diagonal",
    (tester) async {
      queue.enqueue(
        notification(dragBehavior: UiKitToastDragBehavior.lockDownward),
      );
      await pumpToastOverlay(tester);

      await tester.fling(
        find.byKey(const ValueKey("ui-kit-toast-surface")),
        const Offset(32, 100),
        1000,
      );
      await tester.pump();

      expect(queue.current, isNull);
    },
  );

  testWidgets("slideFromTop enters fully opaque from above", (tester) async {
    queue.enqueue(
      notification(
        entrance: UiKitToastEntrance.slideFromTop,
        entranceDuration: const Duration(milliseconds: 100),
      ),
    );
    await pumpToastOverlay(tester);
    final surface = find.byKey(const ValueKey("ui-kit-toast-surface"));
    final start = tester.getTopLeft(surface);

    await tester.pump(const Duration(milliseconds: 100));
    final end = tester.getTopLeft(surface);

    expect(start.dy, lessThan(0));
    expect(start.dy, lessThan(end.dy));
    expect(
      find.descendant(
        of: find.byType(UiKitToastOverlay),
        matching: find.byType(FadeTransition),
      ),
      findsNothing,
    );
  });

  testWidgets("slideFromTop respects reduced motion", (tester) async {
    queue.enqueue(notification(entrance: UiKitToastEntrance.slideFromTop));
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: UiKitToastOverlay(
            queue: queue,
            child: const Scaffold(body: SizedBox.expand()),
          ),
        ),
      ),
    );
    final surface = find.byKey(const ValueKey("ui-kit-toast-surface"));
    final initial = tester.getTopLeft(surface);

    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.getTopLeft(surface), initial);
  });

  testWidgets("queue transition avoids a second cross-fade for slideFromTop", (
    tester,
  ) async {
    queue
      ..enqueue(notification(entrance: UiKitToastEntrance.slideFromTop))
      ..enqueue(notification(entrance: UiKitToastEntrance.slideFromTop));
    await pumpToastOverlay(tester);

    queue.dismissCurrent();
    await tester.pump();

    expect(find.byKey(const ValueKey("ui-kit-toast-surface")), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(UiKitToastOverlay),
        matching: find.byType(FadeTransition),
      ),
      findsNothing,
    );
  });

  testWidgets("uses themed defaults when no appearance is provided", (
    tester,
  ) async {
    queue.enqueue(notification());
    await pumpToastOverlay(tester);

    final material = tester.widget<Material>(
      find.byKey(const ValueKey("ui-kit-toast-surface")),
    );
    expect(material.color, UiKitTheme.successBg);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
  });

  testWidgets("appearance overrides the standard toast surface", (
    tester,
  ) async {
    queue.enqueue(
      notification(
        appearance: const UiKitToastAppearance(
          backgroundColor: Colors.indigo,
          leadingIcon: Icons.notifications,
          leadingIconColor: Colors.white,
        ),
      ),
    );
    await pumpToastOverlay(tester);

    final material = tester.widget<Material>(
      find.byKey(const ValueKey("ui-kit-toast-surface")),
    );
    expect(material.color, Colors.indigo);
    expect(find.byIcon(Icons.notifications), findsOneWidget);
  });

  testWidgets(
    "leading widget replaces icons and keeps the toast semantic label",
    (tester) async {
      const leadingKey = ValueKey("brand-mark");
      queue.enqueue(
        notification(
          semanticLabel: "New CarPortal notification",
          appearance: UiKitToastAppearance(
            leading: Semantics(
              label: "CarPortal",
              child: ColoredBox(key: leadingKey, color: Colors.deepOrange),
            ),
            leadingIcon: Icons.notifications,
          ),
        ),
      );
      await pumpToastOverlay(tester);

      expect(find.byKey(leadingKey), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsNothing);
      expect(find.byIcon(Icons.check_circle_outline), findsNothing);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == "New CarPortal notification",
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && widget.properties.label == "CarPortal",
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets("leading widget retains structured toast tap and timeout", (
    tester,
  ) async {
    var taps = 0;
    queue.enqueue(
      notification(
        duration: const Duration(seconds: 1),
        onTap: () => taps += 1,
        appearance: const UiKitToastAppearance(
          leading: ColoredBox(color: Colors.deepOrange),
        ),
      ),
    );
    await pumpToastOverlay(tester);

    await tester.tap(find.byKey(const ValueKey("ui-kit-toast-surface")));
    await tester.pump();
    expect(taps, 1);
    expect(queue.current, isNull);

    queue.enqueue(
      notification(
        duration: const Duration(seconds: 1),
        appearance: const UiKitToastAppearance(
          leading: ColoredBox(color: Colors.deepOrange),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(queue.current, isNull);
  });

  testWidgets("legacy builder requests retain their app-owned surface", (
    tester,
  ) async {
    queue.enqueue(
      UiKitToastRequest(
        type: UiKitToastType.normal,
        builder: (_) => const Text("Legacy toast"),
      ),
    );
    await pumpToastOverlay(tester);

    expect(find.text("Legacy toast"), findsOneWidget);
    expect(find.byKey(const ValueKey("ui-kit-toast-surface")), findsNothing);
  });
}
