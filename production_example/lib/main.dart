import 'package:flutter/material.dart';
import 'package:mobile_sdk/mobile_sdk.dart' as sdk;
import 'package:mobile_sdk/mobile_sdk.dart' as ui;

void main() => runApp(const ProductionExample());

class ProductionExample extends StatelessWidget {
  const ProductionExample({super.key});

  @override
  Widget build(BuildContext context) => sdk.AppShell(
    config: const sdk.AppConfig(
      environment: sdk.AppEnvironment.prod,
      appName: 'SDK production integration',
    ),
    navigatorKey: GlobalKey<NavigatorState>(),
    home: const TaskList(),
  );
}

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  int _count = 3;

  Future<void> _refresh() async {
    setState(() => _count = 3);
  }

  Future<bool> _loadMore() async {
    setState(() => _count = (_count + 3).clamp(0, 9));
    return _count < 9;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Production tasks')),
    body: ui.RefreshView(
      onRefresh: _refresh,
      enableLoadMore: true,
      onLoadMore: _loadMore,
      child: ListView.builder(
        itemCount: _count,
        itemBuilder: (context, index) =>
            ListTile(title: Text('Task ${index + 1}')),
      ),
    ),
  );
}
