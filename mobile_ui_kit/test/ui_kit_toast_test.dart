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
    UiKitToastAppearance? appearance,
  }) => UiKitToastRequest.content(
    type: UiKitToastType.success,
    duration: duration,
    onDismiss: onDismiss,
    content: UiKitToastContent(
      title: "New order",
      message: "Order #123 is ready",
      onTap: onTap,
      appearance: appearance,
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

  testWidgets("short and downward drags return to the original position", (
    tester,
  ) async {
    queue.enqueue(notification());
    await pumpToastOverlay(tester);
    final surface = find.byKey(const ValueKey("ui-kit-toast-surface"));
    final original = tester.getTopLeft(surface);

    await tester.drag(surface, const Offset(0, 24));
    await tester.pumpAndSettle();

    expect(queue.current, isNotNull);
    expect(tester.getTopLeft(surface), original);
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
