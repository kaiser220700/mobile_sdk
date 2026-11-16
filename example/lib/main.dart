import "dart:async";

import "developer_tools.dart";

import "package:material_ui/material_ui.dart";
import "package:mobile_devtool/mobile_devtool.dart" as dev;
import "package:mobile_sdk/mobile_sdk.dart" as sdk;
import "package:mobile_sdk/mobile_sdk.dart" as ui;

void main() => runApp(const MobileSdkExampleApp());

class MobileSdkExampleApp extends StatefulWidget {
  const MobileSdkExampleApp({super.key, this.config = sdk.AppConfig.demo});

  final sdk.AppConfig config;

  @override
  State<MobileSdkExampleApp> createState() => _MobileSdkExampleAppState();
}

class _MobileSdkExampleAppState extends State<MobileSdkExampleApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final dev.Controller _devToolController;
  OverlayEntry? _devToolEntry;
  bool _mockData = false;

  @override
  void initState() {
    super.initState();
    _devToolController = widget.config.developerToolsEnabled
        ? dev.Controller()
        : dev.Controller.disabled();

    if (widget.config.developerToolsEnabled) {
      _devToolEntry = dev.ToolsOverlay.attach(
        navigatorKey: _navigatorKey,
        builder: (context) => DeveloperTools(
          controller: _devToolController,
          navigatorKey: _navigatorKey,
          configuration: dev.Configuration(
            title: widget.config.appName,
            featureFlags: [
              dev.FeatureFlag(
                id: "mock-data",
                label: "Mock data",
                description: "Bật dữ liệu giả lập trong app demo.",
                getter: () => _mockData,
                setter: (value) => setState(() => _mockData = value),
              ),
            ],
            panels: [
              dev.Panel(
                id: "sdk-summary",
                label: "SDK summary",
                icon: Icons.inventory_2_outlined,
                builder: (context) => const _SdkSummaryPanel(),
              ),
            ],
            hostActions: [
              dev.HostAction(
                label: "Trace: host action",
                icon: Icons.bolt_outlined,
                onPressed: () => _devToolController.recordTrace(
                  "Host action ${DateTime.now().toIso8601String()}",
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
    _devToolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return sdk.AppShell(
      config: widget.config,
      navigatorKey: _navigatorKey,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF176B87),
        useMaterial3: true,
        extensions: const [
          ui.ThemeData.fromDefaults(
            primary: Color(0xFF176B87),
            primaryBg: Color(0xFFE3F4F8),
            focusRing: Color(0xFF72C7D8),
          ),
        ],
      ),
      home: _SdkHomePage(controller: _devToolController, mockData: _mockData),
    );
  }
}

class _SdkHomePage extends StatefulWidget {
  const _SdkHomePage({required this.controller, required this.mockData});

  final dev.Controller controller;
  final bool mockData;

  @override
  State<_SdkHomePage> createState() => _SdkHomePageState();
}

class _SdkHomePageState extends State<_SdkHomePage> {
  final _loadingController = ui.LoadingController();
  final _toastQueue = ui.ToastQueue();
  final _popoverController = ui.OverlayController();
  final _otpController = ui.OtpController(length: 4);
  final _textController = TextEditingController();
  final _passwordController = TextEditingController(text: "secret");

  Set<String> _expandedIds = {};
  _SdkSection? _section;
  bool _selected = false;
  bool _checked = true;
  bool _switched = true;
  bool _skeletonEnabled = true;
  double _progress = .62;
  String _searchValue = "";
  String _activeTab = "overview";
  sdk.UpdateCheckResult? _updateResult;
  sdk.UpdateDecision? _updateDecision;

  @override
  void dispose() {
    _loadingController.dispose();
    _toastQueue.dispose();
    _popoverController.dispose();
    _otpController.dispose();
    _textController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showToast(ui.ToastType type, String message) {
    _toastQueue.enqueue(
      ui.ToastRequest(
        type: type,
        builder: (context) => _ToastCard(type: type, message: message),
      ),
    );
  }

  Future<void> _showLoading(ui.LoadingStep step) async {
    if (step == ui.LoadingStep.spinner) {
      _loadingController.showSpinner();
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
    }
    if (step == ui.LoadingStep.success) {
      _loadingController.showSuccess();
    } else if (step == ui.LoadingStep.error) {
      _loadingController.showError();
    }
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) _loadingController.hide();
  }

  Future<void> _checkUpdate() async {
    final checker = sdk.UpdateChecker(
      configSource: _DemoConfigSource(),
      loadCurrentVersion: () async => "1.4.0",
    );
    final result = await checker.check();
    if (!mounted) return;
    setState(() {
      _updateResult = result;
      _updateDecision = result.decision;
    });
    if (result.decision.shouldPrompt) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_showUpdateDialog(result));
      });
    }
  }

  Future<void> _showUpdateDialog(sdk.UpdateCheckResult result) async {
    final decision = result.decision;
    if (!decision.shouldPrompt) return;

    final forced = decision.isForced;
    await ui.Dialog.show(
      context,
      title: forced ? "Cần cập nhật ứng dụng" : "Có phiên bản mới",
      description: forced
          ? "Phiên bản ${result.currentVersion} không còn được hỗ trợ. "
                "Hãy cập nhật lên ${result.config.latestVersion} để tiếp tục."
          : "Đã có phiên bản ${result.config.latestVersion}. "
                "Bạn có muốn cập nhật ngay không?",
      semantic: forced ? ui.DialogSemantic.error : ui.DialogSemantic.warning,
      icon: forced ? Icons.system_update_alt : Icons.system_update_outlined,
      dismissible: !forced,
      actions: [
        ui.DialogAction(
          label: "Cập nhật ngay",
          variant: forced ? ui.ButtonVariant.danger : ui.ButtonVariant.primary,
          onPressed: () => _showToast(
            ui.ToastType.success,
            "Mở store: ${result.config.storeUrl}",
          ),
        ),
        if (!forced)
          ui.DialogAction(
            label: "Để sau",
            variant: ui.ButtonVariant.ghost,
            onPressed: () {},
          ),
      ],
    );
  }

  String get _headerTitle => switch (_section) {
    null => "Mobile SDK",
    _SdkSection.uiKit => "UI Kit",
    _SdkSection.devTool => "DevTool",
    _SdkSection.update => "Update",
  };

  void _openSection(_SdkSection section) {
    Navigator.of(context).pop();
    setState(() => _section = section);
  }

  void _openMenu() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.widgets_outlined),
              title: const Text("UI Kit"),
              subtitle: const Text("Interaction primitives and overlays"),
              onTap: () => _openSection(_SdkSection.uiKit),
            ),
            ListTile(
              leading: const Icon(Icons.build_outlined),
              title: const Text("DevTool"),
              subtitle: const Text("Network, trace and feature flags"),
              onTap: () => _openSection(_SdkSection.devTool),
            ),
            ListTile(
              leading: const Icon(Icons.system_update_outlined),
              title: const Text("Update"),
              subtitle: const Text("Version policy and update decision"),
              onTap: () => _openSection(_SdkSection.update),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: "Mobile SDK Example",
      applicationVersion: "0.1.0",
      children: const [
        Text(
          "Một app demo chung cho mobile_ui_kit, mobile_devtool và mobile_update.",
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surfaceContainerHighest;

    return ui.ToastOverlay(
      queue: _toastQueue,
      child: ui.LoadingOverlay(
        controller: _loadingController,
        barrierColor: Colors.black54,
        builder: (context, step) => _LoadingCard(step: step),
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: _section == null ? "Mở menu" : "Quay lại",
              icon: Icon(_section == null ? Icons.menu : Icons.arrow_back),
              onPressed: _section == null
                  ? _openMenu
                  : () => setState(() => _section = null),
            ),
            title: Text(_headerTitle),
            centerTitle: true,
            actions: [
              IconButton(
                tooltip: "Thông tin",
                icon: const Icon(Icons.info_outline),
                onPressed: _showAbout,
              ),
            ],
          ),
          body: switch (_section) {
            null => _buildRoot(theme),
            _SdkSection.uiKit => _buildUiKitTab(theme, surface),
            _SdkSection.devTool => _buildDevToolTab(theme, surface),
            _SdkSection.update => _buildUpdateTab(theme, surface),
          },
        ),
      ),
    );
  }

  Widget _buildRoot(ThemeData theme) {
    final colors = theme.colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text("SDK showcase", style: theme.textTheme.headlineSmall),
        const SizedBox(height: 6),
        const Text("Chọn một package để xem example và tương tác trực tiếp."),
        const SizedBox(height: 20),
        _PackageCard(
          icon: Icons.widgets_outlined,
          title: "UI Kit",
          description:
              "Pressable, overlay, OTP, loading, toast, skeleton và animation.",
          color: colors.primaryContainer,
          onTap: () => setState(() => _section = _SdkSection.uiKit),
        ),
        _PackageCard(
          icon: Icons.build_outlined,
          title: "DevTool",
          description: "Network log, trace, feature flag và host panel trong bubble overlay.",
          color: colors.secondaryContainer,
          onTap: () => setState(() => _section = _SdkSection.devTool),
        ),
        _PackageCard(
          icon: Icons.system_update_outlined,
          title: "Update",
          description:
              "Kiểm tra version và quyết định update none, soft hoặc force.",
          color: colors.tertiaryContainer,
          onTap: () => setState(() => _section = _SdkSection.update),
        ),
      ],
    );
  }

  Widget _buildUiKitTab(ThemeData theme, Color surface) {
    final colors = theme.colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionIntro(
          title: "mobile_ui_kit",
          description: "Headless interaction primitives: app quyết định style, SDK quản lý behavior.",
        ),
        const _UiKitCoverageCard(),
        _Section(
          title: "Foundation / feedback",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ui.Title(
                text: "Account overview",
                description: "Title, avatar, badge, icon và card shell.",
                headingSize: ui.TitleHeadingSize.lg,
                bottomSpacing: 12,
              ),
              ui.CardShell(
                shadow: true,
                child: Row(
                  children: [
                    const ui.Avatar(
                      initials: "NA",
                      size: ui.AvatarSize.lg,
                      status: ui.AvatarStatus.online,
                      ring: true,
                      semanticsLabel: "Nguyễn An đang online",
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Nguyễn An",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 4),
                          Text("Mobile Engineer"),
                        ],
                      ),
                    ),
                    const ui.Icon(
                      Icons.verified_outlined,
                      color: ui.IconColor.success,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ui.Badge(
                    label: "Primary",
                    semantic: ui.BadgeSemantic.primary,
                  ),
                  ui.Badge(
                    label: "Success",
                    variant: ui.BadgeVariant.solid,
                    semantic: ui.BadgeSemantic.success,
                  ),
                  ui.Badge(count: 128, semantic: ui.BadgeSemantic.info),
                  ui.Badge(
                    variant: ui.BadgeVariant.dot,
                    semantic: ui.BadgeSemantic.warning,
                    semanticsLabel: "Có cảnh báo mới",
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ui.AlertBanner(
                title: "Profile đã được xác thực",
                description: "Bạn có thể tiếp tục sử dụng toàn bộ tính năng.",
                semantic: ui.AlertSemantic.success,
                action: ui.AlertAction(
                  label: "Xem chi tiết",
                  onPressed: () =>
                      _showToast(ui.ToastType.normal, "Đã chọn xem chi tiết"),
                ),
              ),
            ],
          ),
        ),
        _Section(
          title: "Buttons / form controls",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ui.Button.text(
                    onPressed: () => _showToast(
                      ui.ToastType.success,
                      "Primary button pressed",
                    ),
                    label: "Primary",
                  ),
                  ui.Button.text(
                    onPressed: () {},
                    label: "Outline",
                    variant: ui.ButtonVariant.outline,
                  ),
                  ui.Button.icon(
                    onPressed: () {},
                    icon: Icons.add,
                    semanticsLabel: "Add item",
                    variant: ui.ButtonVariant.ghost,
                  ),
                  const ui.Button.text(
                    onPressed: null,
                    label: "Disabled",
                    disabled: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ui.Checkbox(
                value: _checked,
                label: "Nhận thông báo từ app",
                description: "Có thể thay đổi trong phần cài đặt.",
                onChanged: (value) => setState(() => _checked = value),
              ),
              const SizedBox(height: 4),
              ui.Switch(
                value: _switched,
                label: "Biometric login",
                sublabel: "Dùng Face ID hoặc vân tay khi đăng nhập.",
                onChanged: (value) => setState(() => _switched = value),
              ),
              const SizedBox(height: 16),
              ui.TextField(
                controller: _textController,
                label: "Display name",
                placeholder: "Nhập tên hiển thị",
                isRequired: true,
                iconLeft: Icons.person_outline,
                helperText: "Tối đa 40 ký tự.",
              ),
              const SizedBox(height: 12),
              ui.TextField(
                controller: _passwordController,
                label: "Password",
                type: ui.TextFieldType.password,
                variant: ui.TextFieldVariant.success,
                iconLeft: Icons.lock_outline,
                showPasswordLabel: "Hiện mật khẩu",
                hidePasswordLabel: "Ẩn mật khẩu",
              ),
            ],
          ),
        ),
        _Section(
          title: "Search / Tabs / List",
          child: Column(
            children: [
              ui.Search(
                value: _searchValue,
                placeholder: "Tìm trong SDK...",
                semanticsLabel: "Tìm kiếm package",
                onChanged: (value) => setState(() => _searchValue = value),
                onClear: () => setState(() => _searchValue = ""),
              ),
              const SizedBox(height: 16),
              ui.Tabs(
                activeId: _activeTab,
                onChanged: (value) => setState(() => _activeTab = value),
                items: const [
                  ui.TabItem(
                    id: "overview",
                    label: "Overview",
                    icon: Icons.dashboard_outlined,
                    badge: ui.TabBadge(count: 3),
                  ),
                  ui.TabItem(
                    id: "activity",
                    label: "Activity",
                    icon: Icons.history,
                    badge: ui.TabBadge(dot: true),
                  ),
                  ui.TabItem(id: "disabled", label: "Disabled", disabled: true),
                ],
              ),
              ui.ListItem(
                title: _searchValue.isEmpty
                    ? "mobile_ui_kit"
                    : "Kết quả: $_searchValue",
                description: "Reusable headless components",
                leading: const ui.Icon(
                  Icons.widgets_outlined,
                  color: ui.IconColor.primary,
                ),
                selected: _activeTab == "overview",
                divider: ui.ListItemDivider.inset,
                onTap: () =>
                    _showToast(ui.ToastType.normal, "ui.ListItem pressed"),
              ),
              ui.ListItem(
                title: "mobile_devtool",
                description: "Network, trace và host panels",
                leading: const ui.Icon(
                  Icons.build_outlined,
                  color: ui.IconColor.info,
                ),
                divider: ui.ListItemDivider.full,
                onTap: () =>
                    _showToast(ui.ToastType.normal, "ui.ListItem pressed"),
              ),
            ],
          ),
        ),
        _Section(
          title: "Dialog",
          child: ui.Button.text(
            onPressed: () {
              unawaited(
                ui.Dialog.show(
                  context,
                  title: "Xác nhận thao tác",
                  description: "Đây là dialog dùng chung từ mobile_ui_kit.",
                  semantic: ui.DialogSemantic.info,
                  actions: [
                    ui.DialogAction(
                      label: "Tiếp tục",
                      variant: ui.ButtonVariant.primary,
                      onPressed: () {},
                    ),
                    ui.DialogAction(
                      label: "Hủy",
                      variant: ui.ButtonVariant.ghost,
                      onPressed: () {},
                    ),
                  ],
                ),
              );
            },
            label: "Preview ui.Dialog",
          ),
        ),
        _Section(
          title: "Pressable states / Item",
          child: Column(
            children: [
              ui.Pressable(
                selected: _selected,
                onPress: () => setState(() => _selected = !_selected),
                builder: (context, states, child) => AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:
                        states.contains(ui.PressableState.pressed) || _selected
                        ? colors.primaryContainer
                        : surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _selected ? "Pressable selected" : "Tap để chọn Pressable",
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ui.Pressable(
                onPress: () {},
                builder: (context, states, child) => DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Icon(Icons.touch_app_outlined),
                        SizedBox(width: 10),
                        Text("Pressable enabled"),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ui.Pressable(
                builder: (context, states, child) => DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Icon(Icons.block_outlined),
                        SizedBox(width: 10),
                        Text("Pressable disabled"),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ui.Item(
                title: const Text("ui.Item title"),
                subtitle: const Text("Row có prefix và suffix"),
                prefix: CircleAvatar(
                  radius: 18,
                  backgroundColor: colors.primaryContainer,
                  child: Icon(Icons.person_outline, color: colors.primary),
                ),
                suffix: const Icon(Icons.chevron_right),
                onPress: () =>
                    _showToast(ui.ToastType.normal, "ui.Item pressed"),
              ),
              ui.Item(
                title: Text(
                  "ui.Item disabled",
                  style: TextStyle(
                    color: colors.onSurface.withValues(alpha: .45),
                  ),
                ),
                subtitle: Text(
                  "Không nhận tương tác",
                  style: TextStyle(
                    color: colors.onSurface.withValues(alpha: .35),
                  ),
                ),
                suffix: Icon(
                  Icons.lock_outline,
                  color: colors.onSurface.withValues(alpha: .35),
                ),
                enabled: false,
              ),
            ],
          ),
        ),
        _Section(
          title: "Radio states / Progress / Divider",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ui.Radio(
                value: _selected,
                selectedColor: colors.primary,
                borderColor: colors.outline,
                label: const Text("ui.Radio selected"),
                onChanged: (value) => setState(() => _selected = value),
              ),
              const SizedBox(height: 12),
              ui.Radio(
                value: !_selected,
                selectedColor: colors.primary,
                borderColor: colors.outline,
                label: const Text("ui.Radio unchecked"),
                onChanged: (value) => setState(() => _selected = !value),
              ),
              const SizedBox(height: 12),
              ui.Radio(
                value: false,
                enabled: false,
                selectedColor: colors.primary,
                borderColor: colors.outline,
                disabledColor: colors.onSurface.withValues(alpha: .3),
                label: const Text("ui.Radio disabled"),
              ),
              const SizedBox(height: 16),
              ui.DeterminateProgress(
                value: _progress,
                height: 10,
                trackColor: colors.surfaceContainerHighest,
                fillColor: colors.primary,
                borderRadius: BorderRadius.circular(8),
                semanticsLabel: "SDK progress",
              ),
              Row(
                children: [
                  const Text("ui.DeterminateProgress"),
                  const Spacer(),
                  IconButton(
                    onPressed: () => setState(
                      () => _progress = (_progress + .1).clamp(0, 1),
                    ),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              ui.Divider(color: colors.outlineVariant),
              const SizedBox(height: 12),
              SizedBox(
                height: 32,
                child: Row(
                  children: [
                    const Text("Vertical"),
                    const SizedBox(width: 12),
                    ui.Divider(
                      axis: Axis.vertical,
                      color: colors.outlineVariant,
                      thickness: 2,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "ui.Divider axis=vertical",
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _Section(
          title: "Accordion / Tooltip",
          child: Column(
            children: [
              ui.Accordion(
                expandedIds: _expandedIds,
                onChanged: (value) => setState(() => _expandedIds = value),
                dividerColor: colors.outlineVariant,
                items: [
                  const ui.AccordionItem(
                    id: "behavior",
                    title: Text("ui.Accordion behavior"),
                    content: Padding(
                      padding: EdgeInsets.fromLTRB(0, 8, 0, 12),
                      child: Text(
                        "Expanded state được quản lý ở app layer bằng Set<String>.",
                      ),
                    ),
                  ),
                  ui.AccordionItem(
                    id: "disabled",
                    title: const Text("Disabled item"),
                    content: const Text("Không thể mở"),
                    disabled: true,
                  ),
                ],
                trailingBuilder: (context, expanded) =>
                    Icon(expanded ? Icons.expand_less : Icons.expand_more),
              ),
              const SizedBox(height: 12),
              ui.Tooltip(
                tipBuilder: (context) =>
                    const Text("Tooltip xuất hiện khi long-press"),
                decoration: BoxDecoration(
                  color: colors.inverseSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(10),
                child: FilledButton.tonalIcon(
                  onPressed: () {},
                  icon: const Icon(Icons.info_outline),
                  label: const Text("Long-press để xem Tooltip"),
                ),
              ),
            ],
          ),
        ),
        _Section(
          title: "Anchored Overlay / OTP",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ui.AnchoredOverlay(
                controller: _popoverController,
                barrierDismissible: true,
                overlayBuilder: (context) => Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      "Popover neo theo target",
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
                child: OutlinedButton.icon(
                  onPressed: _popoverController.toggle,
                  icon: const Icon(Icons.menu_open),
                  label: const Text("Toggle anchored overlay"),
                ),
              ),
              const SizedBox(height: 16),
              ui.OtpField(
                controller: _otpController,
                decorationBuilder: (context, index, hasFocus) =>
                    InputDecoration(
                      counterText: "",
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: colors.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: colors.primary, width: 2),
                      ),
                    ),
                textStyle: theme.textTheme.titleLarge,
                onCompleted: (value) =>
                    _showToast(ui.ToastType.success, "OTP hoàn tất: $value"),
              ),
            ],
          ),
        ),
        _Section(
          title: "Loading / Toast",
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () =>
                    unawaited(_showLoading(ui.LoadingStep.spinner)),
                child: const Text("Spinner"),
              ),
              OutlinedButton(
                onPressed: () =>
                    unawaited(_showLoading(ui.LoadingStep.success)),
                child: const Text("Success"),
              ),
              OutlinedButton(
                onPressed: () => unawaited(_showLoading(ui.LoadingStep.error)),
                child: const Text("Error"),
              ),
              for (final type in ui.ToastType.values)
                OutlinedButton(
                  onPressed: () => _showToast(type, "Toast ${type.name}"),
                  child: Text(type.name),
                ),
            ],
          ),
        ),
        _Section(
          title: "Skeleton / ListEntrance",
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _skeletonEnabled,
                title: const Text("ui.Skeleton enabled"),
                onChanged: (value) => setState(() => _skeletonEnabled = value),
              ),
              ui.Skeleton(
                enabled: _skeletonEnabled,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ui.Bone.circle(size: 42),
                  title: ui.Bone.text(words: 3),
                  subtitle: ui.Bone.text(words: 6),
                ),
              ),
              const SizedBox(height: 8),
              for (var index = 0; index < 3; index++)
                ui.ListEntrance(
                  index: index,
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text("${index + 1}")),
                      title: Text("Animated item ${index + 1}"),
                      subtitle: const Text("ui.ListEntrance fade + slide"),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDevToolTab(ThemeData theme, Color surface) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionIntro(
          title: "mobile_devtool",
          description: "Bubble ở góc màn hình mở Network, Trace, Feature Flags và các built-in tools.",
        ),
        _Section(
          title: "Generate sample logs",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                onPressed: () => unawaited(_simulateNetwork()),
                icon: const Icon(Icons.cloud_outlined),
                label: const Text("Simulate successful GraphQL request"),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => unawaited(_simulateFailure()),
                icon: const Icon(Icons.error_outline),
                label: const Text("Simulate failed REST request"),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => widget.controller.recordTrace(
                  "Manual trace from SDK example",
                ),
                icon: const Icon(Icons.notes_outlined),
                label: const Text("Record trace"),
              ),
            ],
          ),
        ),
        _Section(
          title: "Shared data helpers",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                dev.JsonFormatter.format(const {
                  "sdk": "mobile",
                  "packages": 3,
                  "enabled": true,
                }),
                style: const TextStyle(fontFamily: "monospace"),
              ),
              const SizedBox(height: 12),
              dev.KeyValueTable(
                rows: [
                  const dev.KeyValueRow(label: "environment", value: "example"),
                  const dev.KeyValueRow(label: "ui_kit", value: "enabled"),
                  dev.KeyValueRow(
                    label: "mock_data",
                    value: "${widget.mockData}",
                  ),
                ],
              ),
            ],
          ),
        ),
        Card(
          color: surface,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Trong app thật, controller được tạo một lần ở composition root và "
              "dùng dev.Controller.disabled() cho production.",
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateTab(ThemeData theme, Color surface) {
    final decision = _updateDecision;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionIntro(
          title: "mobile_update",
          description: "Framework-agnostic helper: host cung cấp config source, version loader và UI prompt.",
        ),
        _Section(
          title: "Policy check",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Demo config: minimum 2.0.0, latest 1.5.0, current 1.4.0",
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _checkUpdate,
                icon: const Icon(Icons.refresh),
                label: const Text("Run sdk.UpdateChecker"),
              ),
              if (decision != null) ...[
                const SizedBox(height: 16),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: decision.isForced
                        ? theme.colorScheme.errorContainer
                        : surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "Decision: ${decision.requirement.name.toUpperCase()}\n"
                      "shouldPrompt=${decision.shouldPrompt}, isForced=${decision.isForced}",
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
                if (decision.shouldPrompt) ...[
                  const SizedBox(height: 12),
                  ui.Button.text(
                    onPressed: () =>
                        unawaited(_showUpdateDialog(_updateResult!)),
                    label: decision.isForced
                        ? "Preview force update dialog"
                        : "Preview soft update dialog",
                    variant: decision.isForced
                        ? ui.ButtonVariant.danger
                        : ui.ButtonVariant.outline,
                    fullWidth: true,
                  ),
                ],
              ],
            ],
          ),
        ),
        const _Section(
          title: "What the host owns",
          child: Text(
            "Remote config adapter, app version adapter và store launcher remain "
            "in the host app. Dialog preview bên trên dùng ui.Dialog; app thật "
            "có thể thay bằng màn hình/localized copy riêng. mobile_update chỉ "
            "trả về none, soft hoặc force.",
          ),
        ),
      ],
    );
  }

  Future<void> _simulateNetwork() async {
    final id = widget.controller.startNetwork(
      const dev.NetworkRequest(
        label: "GetSdkCatalog",
        endpoint: "/v1/sdk/catalog",
        method: "GET",
        kind: dev.NetworkKind.rest,
        request: {"source": "example"},
      ),
    );
    widget.controller.recordTrace("GetSdkCatalog started");
    await Future<void>.delayed(const Duration(milliseconds: 500));
    widget.controller.completeNetwork(
      id,
      response: const {
        "packages": ["mobile_ui_kit", "mobile_devtool", "mobile_update"],
      },
      statusCode: 200,
      duration: const Duration(milliseconds: 500),
    );
    widget.controller.recordTrace("GetSdkCatalog completed");
  }

  Future<void> _simulateFailure() async {
    final id = widget.controller.startNetwork(
      const dev.NetworkRequest(
        label: "UploadDiagnostics",
        endpoint: "/v1/diagnostics",
        method: "POST",
        request: {"logs": 3},
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 350));
    widget.controller.failNetwork(
      id,
      error: "503 Service Unavailable",
      statusCode: 503,
    );
  }
}

class _DemoConfigSource implements sdk.UpdateConfigSource {
  @override
  Future<sdk.UpdateConfig> fetch() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const sdk.UpdateConfig(
      enabled: true,
      minVersion: "2.0.0",
      latestVersion: "1.5.0",
      storeUrl: "https://example.com/store",
    );
  }
}

enum _SdkSection { uiKit, devTool, update }

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _UiKitCoverageCard extends StatelessWidget {
  const _UiKitCoverageCard();

  static const _widgets = [
    "AlertBanner",
    "Avatar",
    "Badge",
    "Button",
    "CardShell",
    "Checkbox",
    "SelectField",
    "FilterChip",
    "Dialog",
    "Icon",
    "Pressable",
    "Item",
    "ListItem",
    "Radio",
    "DeterminateProgress",
    "StatTile",
    "KeyValue",
    "Timeline",
    "Stepper",
    "Divider",
    "Accordion",
    "Tooltip",
    "AnchoredOverlay",
    "OtpField",
    "LoadingOverlay",
    "ToastOverlay",
    "Skeleton",
    "ListEntrance",
    "Search",
    "Switch",
    "Tabs",
    "TextField",
    "Title",
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Component coverage",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            const Text(
              "Cuộn xuống để xem và tương tác với toàn bộ widget đang export.",
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final name in _widgets)
                  Chip(
                    avatar: Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: colors.primary,
                    ),
                    label: Text("ui.$name"),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "API behavior: ui.LoadingController, ui.ToastQueue, "
              "ui.OverlayController, ui.OtpController và các enum/state "
              "được dùng trực tiếp trong các section bên dưới.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              "Các component còn lại trong roadmap: Menu, Picker, "
              "IconCircleButton và AppBar.",
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionIntro extends StatelessWidget {
  const _SectionIntro({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(description),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.step});

  final ui.LoadingStep step;

  @override
  Widget build(BuildContext context) {
    final isSpinner = step == ui.LoadingStep.spinner;
    final isSuccess = step == ui.LoadingStep.success;
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSpinner) const CircularProgressIndicator(),
              if (!isSpinner)
                Icon(
                  isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                  size: 42,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
              const SizedBox(height: 12),
              Text(
                isSpinner
                    ? "Loading"
                    : isSuccess
                    ? "Success"
                    : "Error",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToastCard extends StatelessWidget {
  const _ToastCard({required this.type, required this.message});

  final ui.ToastType type;
  final String message;

  @override
  Widget build(BuildContext context) {
    final color = switch (type) {
      ui.ToastType.normal => Theme.of(context).colorScheme.inverseSurface,
      ui.ToastType.warning => Colors.orange.shade800,
      ui.ToastType.success => Colors.green.shade700,
      ui.ToastType.error => Theme.of(context).colorScheme.error,
    };
    return SafeArea(
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(message, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

class _SdkSummaryPanel extends StatelessWidget {
  const _SdkSummaryPanel();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        "Một app example duy nhất đang compose cả mobile_ui_kit, mobile_devtool "
        "và mobile_update. Nội dung panel này do app host đăng ký.",
      ),
    );
  }
}
