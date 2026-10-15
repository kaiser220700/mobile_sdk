import 'dart:async';

import 'package:flutter/material.dart' hide RefreshIndicator;
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_ui_kit/mobile_ui_kit.dart';

void main() {
  testWidgets('refresh and pagination preserve controller state transitions', (
    tester,
  ) async {
    final controller = RefreshController();
    final refresh = Completer<void>();
    var hasMore = true;
    var refreshCalls = 0;
    var pageCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: UiKitRefreshConfiguration(
          child: UiKitRefreshLoadMore(
            controller: controller,
            enableLoadMore: true,
            onRefresh: () {
              refreshCalls++;
              return refresh.future;
            },
            onLoadMore: () {
              pageCalls++;
              return hasMore;
            },
            child: ListView(children: const [Text('Task')]),
          ),
        ),
      ),
    );
    final refresher = tester.widget<SmartRefresher>(
      find.byType(SmartRefresher),
    );
    refresher.onRefresh!();
    await tester.pump();
    expect(refreshCalls, 1);
    refresh.complete();
    await tester.pump();
    expect(controller.headerStatus, RefreshStatus.completed);
    refresher.onLoading!();
    await tester.pump();
    expect(controller.footerStatus, LoadStatus.idle);
    hasMore = false;
    refresher.onLoading!();
    await tester.pump();
    expect(controller.footerStatus, LoadStatus.noMore);
    expect(pageCalls, 2);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });

  testWidgets('refresh and load more can both be disabled', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UiKitRefreshLoadMore(
          enableRefresh: false,
          child: ListView(children: const [Text('Task')]),
        ),
      ),
    );
    final refresher = tester.widget<SmartRefresher>(
      find.byType(SmartRefresher),
    );
    expect(refresher.enablePullDown, isFalse);
    expect(refresher.enablePullUp, isFalse);
    expect(refresher.onRefresh, isNull);
    expect(refresher.onLoading, isNull);
  });
}
