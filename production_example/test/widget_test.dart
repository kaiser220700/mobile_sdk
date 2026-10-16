import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_sdk/mobile_sdk.dart' as ui;
import 'package:mobile_sdk_production_example/main.dart';

void main() {
  test('production dependency graph excludes developer tools and Firebase', () {
    final config =
        jsonDecode(File('.dart_tool/package_config.json').readAsStringSync())
            as Map;
    final names = (config['packages'] as List).map((p) => (p as Map)['name']);
    for (final forbidden in [
      'mobile_devtool',
      'mobile_fuzz',
      'mobile_screen_draw',
      'firebase_core',
      'firebase_remote_config',
    ]) {
      expect(names, isNot(contains(forbidden)));
    }
  });

  testWidgets('production list refreshes and paginates again after no-more', (
    tester,
  ) async {
    await tester.pumpWidget(const ProductionExample());
    expect(find.text('Production tasks'), findsOneWidget);
    var list = tester.widget<ui.SmartRefresher>(find.byType(ui.SmartRefresher));
    expect((list.child! as ListView).semanticChildCount, 3);
    list.onLoading!();
    await tester.pump();
    list = tester.widget<ui.SmartRefresher>(find.byType(ui.SmartRefresher));
    expect((list.child! as ListView).semanticChildCount, 6);
    list.onLoading!();
    await tester.pump();
    expect(list.controller.footerStatus, ui.LoadStatus.noMore);
    list.onRefresh!();
    await tester.pump();
    list = tester.widget<ui.SmartRefresher>(find.byType(ui.SmartRefresher));
    expect((list.child! as ListView).semanticChildCount, 3);
    expect(list.controller.footerStatus, ui.LoadStatus.idle);
    list.onLoading!();
    await tester.pump();
    list = tester.widget<ui.SmartRefresher>(find.byType(ui.SmartRefresher));
    expect((list.child! as ListView).semanticChildCount, 6);
  });
}
