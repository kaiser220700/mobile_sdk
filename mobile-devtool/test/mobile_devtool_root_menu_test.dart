import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mobile_devtool/src/mobile_devtool_configuration.dart";
import "package:mobile_devtool/src/mobile_devtool_controller.dart";
import "package:mobile_devtool/src/mobile_devtool_network_log_panel.dart";
import "package:mobile_devtool/src/mobile_devtool_root_menu.dart";

void main() {
  testWidgets("puts Screen Draw and Fuzz Tap actions in the header", (
    tester,
  ) async {
    final controller = MobileDevToolController();
    addTearDown(controller.dispose);
    var screenDrawOpened = false;
    var fuzzTapOpened = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => MobileDevToolRootMenu.show(
              context,
              controller: controller,
              configuration: const MobileDevToolConfiguration(),
              onOpenScreenDraw: () => screenDrawOpened = true,
              onOpenFuzzTap: () => fuzzTapOpened = true,
            ),
            child: const Text("Open"),
          ),
        ),
      ),
    );

    await tester.tap(find.text("Open"));
    await tester.pumpAndSettle();

    expect(find.byTooltip("Screen Draw"), findsOneWidget);
    expect(find.byTooltip("Fuzz Tap"), findsOneWidget);
    expect(find.text("Screen Draw"), findsNothing);
    expect(find.text("Fuzz Tap"), findsNothing);

    await tester.tap(find.byTooltip("Fuzz Tap"));
    await tester.pumpAndSettle();
    expect(fuzzTapOpened, isTrue);
    expect(screenDrawOpened, isFalse);
  });

  testWidgets("opens the first tool and switches tools from the header menu", (
    tester,
  ) async {
    final controller = MobileDevToolController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MobileDevToolRootMenu(
            controller: controller,
            configuration: const MobileDevToolConfiguration(),
          ),
        ),
      ),
    );

    expect(find.text("Network"), findsOneWidget);
    expect(find.text("Chưa có network log"), findsOneWidget);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Trace").last);
    await tester.pumpAndSettle();

    expect(find.text("Trace"), findsOneWidget);
    expect(find.text("Chưa có trace log"), findsOneWidget);
  });

  testWidgets("shows published and development tool status", (tester) async {
    final controller = MobileDevToolController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MobileDevToolRootMenu(
            controller: controller,
            configuration: const MobileDevToolConfiguration(),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Dev Tool Info"));
    await tester.pumpAndSettle();

    expect(find.text("Published"), findsOneWidget);
    expect(find.text("Đang phát triển"), findsOneWidget);
    expect(find.text("Network"), findsOneWidget);
    expect(find.text("Fuzz Tap"), findsOneWidget);
  });

  testWidgets("opens network details as a page in the current sheet", (
    tester,
  ) async {
    final controller = MobileDevToolController();
    addTearDown(controller.dispose);
    final id = controller.startNetwork(
      const MobileDevToolNetworkRequest(
        label: "Load profile",
        endpoint: "/profile",
        method: "GET",
      ),
    );
    controller.completeNetwork(id, response: const {"ok": true});

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MobileDevToolRootMenu(
            controller: controller,
            configuration: const MobileDevToolConfiguration(),
          ),
        ),
      ),
    );

    await tester.tap(find.text("Load profile"));
    await tester.pumpAndSettle();

    expect(find.text("Network detail"), findsOneWidget);
    expect(find.byType(MobileDevToolNetworkLogDetail), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text("Network detail"), findsNothing);
    expect(find.text("Load profile"), findsOneWidget);
  });

  testWidgets(
    "uses a white surface and black text even under a dark host theme",
    (tester) async {
      final controller = MobileDevToolController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: MobileDevToolRootMenu(
              controller: controller,
              configuration: const MobileDevToolConfiguration(),
            ),
          ),
        ),
      );

      final scopedTheme = tester.widgetList<Theme>(find.byType(Theme)).last;
      expect(scopedTheme.data.colorScheme.surface, Colors.white);
      expect(scopedTheme.data.colorScheme.onSurface, Colors.black);
    },
  );

  testWidgets("registers a custom tool from menuItems", (tester) async {
    final controller = MobileDevToolController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MobileDevToolRootMenu(
            controller: controller,
            configuration: MobileDevToolConfiguration(
              menuItems: [
                MobileDevToolMenuItem(
                  id: "storage-tool",
                  label: "Storage",
                  icon: Icons.storage_outlined,
                  builder: (_) => const Text("Storage inspector"),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.text("Storage"), findsOneWidget);

    await tester.tap(find.text("Storage"));
    await tester.pumpAndSettle();
    expect(find.text("Storage inspector"), findsOneWidget);
  });

  testWidgets("custom menu items can replace and hide built-ins", (
    tester,
  ) async {
    final controller = MobileDevToolController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MobileDevToolRootMenu(
            controller: controller,
            configuration: MobileDevToolConfiguration(
              hiddenMenuItemIds: {MobileDevToolBuiltInIds.trace},
              menuItems: [
                MobileDevToolMenuItem(
                  id: MobileDevToolBuiltInIds.network,
                  label: "Account",
                  icon: Icons.account_circle_outlined,
                  builder: (_) => const Text("Account inspector"),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text("Account"), findsOneWidget);
    expect(find.text("Account inspector"), findsOneWidget);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.text("Network"), findsNothing);
    expect(find.text("Trace"), findsNothing);
  });
}
