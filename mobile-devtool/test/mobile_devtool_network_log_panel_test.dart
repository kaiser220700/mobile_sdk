import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mobile_devtool/mobile_devtool.dart";

void main() {
  testWidgets("uses the host status-filter style", (tester) async {
    final controller = MobileDevToolController();
    addTearDown(controller.dispose);
    const style = MobileDevToolNetworkStatusFilterStyle(
      selectedGradient: LinearGradient(colors: [Colors.blue, Colors.indigo]),
      selectedForegroundColor: Colors.white,
      unselectedBackgroundColor: Color(0xFFE4ECF4),
      unselectedBorderColor: Color(0xFF2F5D8A),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MobileDevToolNetworkLogPanel(
            controller: controller,
            statusFilterStyle: style,
          ),
        ),
      ),
    );

    final allInk = tester.widget<Ink>(
      find.ancestor(of: find.text("All (0)"), matching: find.byType(Ink)).first,
    );
    final allDecoration = allInk.decoration! as BoxDecoration;
    expect(allDecoration.gradient, style.selectedGradient);

    final okInk = tester.widget<Ink>(
      find.ancestor(of: find.text("OK (0)"), matching: find.byType(Ink)).first,
    );
    final okDecoration = okInk.decoration! as BoxDecoration;
    expect(okDecoration.color, style.unselectedBackgroundColor);
    expect(
      (okDecoration.border! as Border).top.color,
      style.unselectedBorderColor,
    );
  });
}
