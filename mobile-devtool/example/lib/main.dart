// This preview is part of the repository workspace and uses APIs excluded
// from the published package surface.
// ignore_for_file: implementation_imports

import "dart:async";

import "developer_tools.dart";

import "package:flutter/material.dart";
import "package:mobile_app_base/mobile_app_base.dart";
import "package:mobile_devtool/mobile_devtool.dart" as dev;

/// Standalone preview app for the `mobile_devtool` package — mounts the SDK
/// chrome (bubble + tool sheet) over a tiny demo screen so every built-in tool
/// can be poked at without depending on the real `node_mobile_app` host.
///
/// This mirrors how a real app would wire the SDK: a single
/// [dev.Controller] created once at the composition root,
/// `dev.ToolsOverlay.attach` inserted into the root `Navigator`'s
/// `Overlay`, and `dev.Configuration.menuItems`/`featureFlags` supplying
/// host-specific content the SDK does not know about.
void main() => runApp(const MobileDevToolExampleApp());

class MobileDevToolExampleApp extends StatefulWidget {
  const MobileDevToolExampleApp({super.key, this.config = AppConfig.demo});

  final AppConfig config;

  @override
  State<MobileDevToolExampleApp> createState() =>
      _MobileDevToolExampleAppState();
}

class _MobileDevToolExampleAppState extends State<MobileDevToolExampleApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  // A single controller for the whole app lifetime — the shared app config
  // selects the disabled controller for `prod`.
  late final dev.Controller _controller;

  // Toggle values backing the demo `dev.FeatureFlag`s below — a real
  // host would read/write these from its own state management (Riverpod...).
  bool _mockHomeList = false;
  bool _verboseLogging = true;

  OverlayEntry? _devToolEntry;

  @override
  void initState() {
    super.initState();
    _controller = widget.config.developerToolsEnabled
        ? dev.Controller()
        : dev.Controller.disabled();

    // Mounted once at the composition root, exactly like the real app host
    // does in `main.dart`. `builder` is re-invoked on every `Overlay`
    // rebuild, so `setState` on this widget (e.g. toggling a feature flag)
    // is picked up automatically without calling `markNeedsBuild()` by hand.
    if (widget.config.developerToolsEnabled) {
      _devToolEntry = dev.ToolsOverlay.attach(
        navigatorKey: _navigatorKey,
        builder: (context) => DeveloperTools(
          controller: _controller,
          navigatorKey: _navigatorKey,
          configuration: dev.Configuration(
            title: widget.config.appName,
            panels: [
              dev.Panel(
                id: "sample-panel",
                label: "Sample host panel",
                icon: Icons.widgets_outlined,
                builder: (context) => const _SampleHostPanel(),
              ),
            ],
            menuItems: [
              dev.MenuItem(
                id: "account-tool",
                label: "Account",
                icon: Icons.account_circle_outlined,
                order: 80,
                builder: (context) => const _AccountToolPanel(),
              ),
              dev.MenuItem(
                id: "storage-tool",
                label: "Storage",
                icon: Icons.storage_outlined,
                order: 90,
                builder: (context) => const _StorageToolPanel(),
              ),
            ],
            featureFlags: [
              dev.FeatureFlag(
                id: "mock-home-list",
                label: "Mock Home List",
                description: "Bật để danh sách trang chủ dùng dữ liệu giả lập.",
                getter: () => _mockHomeList,
                setter: (value) => setState(() => _mockHomeList = value),
              ),
              dev.FeatureFlag(
                id: "verbose-logging",
                label: "Verbose Logging",
                description: "Bật để ghi thêm trace log chi tiết.",
                getter: () => _verboseLogging,
                setter: (value) => setState(() => _verboseLogging = value),
              ),
            ],
            hostActions: [
              dev.HostAction(
                label: "Trace: Ping",
                icon: Icons.bolt_outlined,
                onPressed: () => _controller.recordTrace(
                  "Ping ${DateTime.now().toIso8601String()}",
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _devToolEntry?.remove();
    _devToolEntry?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MobileAppShell(
      config: widget.config,
      navigatorKey: _navigatorKey,
      colorSchemeSeed: const Color(0xFF1A6E36),
      home: _HomePage(controller: _controller),
    );
  }
}

/// Demo panel registered by the "host" app via `dev.Configuration
/// .panels` — the SDK only decides when/how to present it, the content is
/// entirely app-owned.
class _SampleHostPanel extends StatelessWidget {
  const _SampleHostPanel();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        "Đây là 1 panel do app host tự đăng ký qua "
        "dev.Configuration.panels — nội dung, widget và state đều "
        "do app quyết định, SDK chỉ điều phối cách hiển thị (tool sheet có "
        "menu đổi chức năng và close chung).",
      ),
    );
  }
}

/// Example only: in a real app this panel reads account state from the host's
/// auth/session service. The SDK deliberately does not own tokens or account
/// storage.
class _AccountToolPanel extends StatelessWidget {
  const _AccountToolPanel();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Host-owned account inspector",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        dev.KeyValueTable(
          rows: const [
            dev.KeyValueRow(label: "user_id", value: "user-42"),
            dev.KeyValueRow(label: "role", value: "admin"),
            dev.KeyValueRow(label: "session", value: "active"),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.logout),
          label: const Text("Đăng xuất tài khoản hiện tại"),
        ),
      ],
    );
  }
}

/// Example only: replace this in the host with its secure storage adapter.
class _StorageToolPanel extends StatefulWidget {
  const _StorageToolPanel();

  @override
  State<_StorageToolPanel> createState() => _StorageToolPanelState();
}

class _StorageToolPanelState extends State<_StorageToolPanel> {
  final _values = <String, String>{
    "access_token": "eyJhbGciOi...",
    "refresh_token": "refresh...",
    "locale": "vi",
  };

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Host-owned storage inspector",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        dev.KeyValueTable(
          rows: [
            for (final entry in _values.entries)
              dev.KeyValueRow(label: entry.key, value: entry.value),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _values.isEmpty ? null : () => setState(_values.clear),
          icon: const Icon(Icons.delete_sweep_outlined),
          label: const Text("Xóa dữ liệu demo"),
        ),
      ],
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage({required this.controller});

  final dev.Controller controller;

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  bool _loading = false;

  static const _sampleJson = {
    "id": "user-42",
    "name": "Nguyễn Văn A",
    "roles": ["admin", "reviewer"],
    "profile": {"__typename": "Profile", "age": 30, "verified": true},
  };

  /// Fires a fake GraphQL call through the controller so the `Network` tool
  /// has something to show — a real app host would call this from
  /// its GraphQL/REST client interceptor instead of a button handler.
  Future<void> _simulateGraphQlCall() async {
    setState(() => _loading = true);
    final id = widget.controller.startNetwork(
      const dev.NetworkRequest(
        label: "GetUserProfile",
        endpoint: "GetUserProfile",
        method: "POST",
        kind: dev.NetworkKind.graphql,
        request: {
          "variables": {"userId": "user-42"},
        },
        document:
            "query GetUserProfile(\$userId: ID!) { user(id: \$userId) { id name } }",
      ),
    );
    widget.controller.recordTrace("GetUserProfile started");
    await Future<void>.delayed(const Duration(milliseconds: 600));
    widget.controller.completeNetwork(
      id,
      response: _sampleJson,
      statusCode: 200,
      duration: const Duration(milliseconds: 600),
    );
    widget.controller.recordTrace("GetUserProfile completed");
    if (mounted) setState(() => _loading = false);
  }

  /// Fires a fake failing REST call so the Network panel's "Error" filter tab
  /// also has an example entry to show.
  Future<void> _simulateFailingRestCall() async {
    final id = widget.controller.startNetwork(
      const dev.NetworkRequest(
        label: "UploadAvatar",
        endpoint: "/v1/users/user-42/avatar",
        method: "POST",
        request: {
          "headers": {"Content-Type": "application/json"},
          "body": {"fileName": "avatar.png"},
        },
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));
    widget.controller.failNetwork(
      id,
      error: "500 Internal Server Error",
      statusCode: 500,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("mobile_devtool preview")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Chạm bubble ở góc màn hình để mở trực tiếp Network. Dùng nút menu "
            "trên thanh tiêu đề để đổi sang Trace / Fuzz Tap Log / Feature "
            "Flags / panel \"Sample host panel\"; Screen Draw và Fuzz Tap có "
            "nút riêng ngay trên header.",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loading
                ? null
                : () => unawaited(_simulateGraphQlCall()),
            icon: const Icon(Icons.cloud_outlined),
            label: const Text("Giả lập GraphQL call thành công"),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => unawaited(_simulateFailingRestCall()),
            icon: const Icon(Icons.error_outline),
            label: const Text("Giả lập REST call lỗi"),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => widget.controller.recordTrace(
              "Nút bấm lúc ${TimeOfDay.now().format(context)}",
            ),
            icon: const Icon(Icons.notes_outlined),
            label: const Text("Ghi 1 trace log"),
          ),
          const Divider(height: 32),
          const Text(
            "JSON Formatter",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                dev.JsonFormatter.format(
                  _sampleJson,
                  omitGraphQLTypeNames: true,
                ),
                style: const TextStyle(fontFamily: "monospace", fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text("KV Table", style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const dev.KeyValueTable(
            rows: [
              dev.KeyValueRow(label: "userId", value: "user-42"),
              dev.KeyValueRow(label: "env", value: "dev"),
              dev.KeyValueRow(label: "token", value: null),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
