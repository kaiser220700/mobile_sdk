import "package:material_ui/material_ui.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mobile_devtool/mobile_devtool.dart" as dev;

void main() {
  testWidgets("fades the public launcher after it becomes idle", (
    tester,
  ) async {
    final controller = dev.Controller();
    final position = dev.LauncherPosition(const Offset(16, 16));
    final idle = dev.LauncherIdleState();
    addTearDown(() {
      controller.dispose();
      position.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(
          children: [
            dev.Launcher(
              controller: controller,
              position: position,
              idle: idle,
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              borderColor: Colors.blue,
              onTap: () {},
            ),
          ],
        ),
      ),
    );

    expect(
      tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
      1,
    );
    final decoration = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey("mobile-devtool-bubble-surface")),
    );
    final box = decoration.decoration as BoxDecoration;
    expect(box.color, Colors.blue);
    expect((box.border! as Border).top.color, Colors.blue);
    expect(tester.widget<Icon>(find.byType(Icon)).color, Colors.white);

    idle.value = true;
    await tester.pump();
    expect(
      tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
      .45,
    );
    idle.dispose();
  });
}
