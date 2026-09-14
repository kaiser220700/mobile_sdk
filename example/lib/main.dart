// This showcase is part of the repository workspace and uses APIs excluded
// from the published package surface.
// ignore_for_file: implementation_imports

import "dart:async";

import "package:flutter/material.dart";
import "package:mobile_app_base/mobile_app_base.dart";
import "package:mobile_devtool/mobile_devtool.dart";
import "package:mobile_devtool/src/mobile_devtool_chrome.dart";
import "package:mobile_devtool/src/mobile_devtool_configuration.dart";
import "package:mobile_devtool/src/mobile_devtool_json_formatter.dart";
import "package:mobile_devtool/src/mobile_devtool_kv_table.dart";
import "package:mobile_ui_kit/mobile_ui_kit.dart";
import "package:mobile_update/mobile_update.dart";

void main() => runApp(const MobileSdkExampleApp());

class MobileSdkExampleApp extends StatefulWidget {
  const MobileSdkExampleApp({super.key, this.config = AppConfig.demo});

  final AppConfig config;

  @override
  State<MobileSdkExampleApp> createState() => _MobileSdkExampleAppState();
}

class _MobileSdkExampleAppState extends State<MobileSdkExampleApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final MobileDevToolController _devToolController;
  OverlayEntry? _devToolEntry;
  bool _mockData = false;

  @override
  void initState() {
    super.initState();
    _devToolController = widget.config.developerToolsEnabled
        ? MobileDevToolController()
        : MobileDevToolController.disabled();

    if (widget.config.developerToolsEnabled) {
      _devToolEntry = MobileDevToolChrome.attach(
        navigatorKey: _navigatorKey,
        builder: (context) => MobileDevToolChrome(
          controller: _devToolController,
          navigatorKey: _navigatorKey,
          configuration: MobileDevToolConfiguration(
            title: widget.config.appName,
            featureFlags: [
              MobileDevToolFeatureFlag(
                id: "mock-data",
                label: "Mock data",
                description: "Bật dữ liệu giả lập trong app demo.",
                getter: () => _mockData,
                setter: (value) => setState(() => _mockData = value),
              ),
            ],
            panels: [
              MobileDevToolPanel(
                id: "sdk-summary",
                label: "SDK summary",
                icon: Icons.inventory_2_outlined,
                builder: (context) => const _SdkSummaryPanel(),
              ),
            ],
            hostActions: [
              MobileDevToolHostAction(
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
    _devToolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MobileAppShell(
      config: widget.config,
      navigatorKey: _navigatorKey,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF176B87),
        useMaterial3: true,
        extensions: const [
          UiKitThemeData(
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

  final MobileDevToolController controller;
  final bool mockData;

  @override
  State<_SdkHomePage> createState() => _SdkHomePageState();
}

class _SdkHomePageState extends State<_SdkHomePage> {
  final _loadingController = UiKitLoadingController();
  final _toastQueue = UiKitToastQueue();
  final _popoverController = UiKitOverlayController();
  final _otpController = UiKitOtpController(length: 4);
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
  MobileUpdateCheckResult? _updateResult;
  MobileUpdateDecision? _updateDecision;

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

  void _showToast(UiKitToastType type, String message) {
    _toastQueue.enqueue(
      UiKitToastRequest(
        type: type,
        builder: (context) => _ToastCard(type: type, message: message),
      ),
    );
  }

  Future<void> _showLoading(UiKitLoadingStep step) async {
    if (step == UiKitLoadingStep.spinner) {
      _loadingController.showSpinner();
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
    }
    if (step == UiKitLoadingStep.success) {
      _loadingController.showSuccess();
    } else if (step == UiKitLoadingStep.error) {
      _loadingController.showError();
    }
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) _loadingController.hide();
  }

  Future<void> _checkUpdate() async {
    final checker = MobileUpdateChecker(
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

  Future<void> _showUpdateDialog(MobileUpdateCheckResult result) async {
    final decision = result.decision;
    if (!decision.shouldPrompt) return;

    final forced = decision.isForced;
    await UiKitDialog.show(
      context,
      title: forced ? "Cần cập nhật ứng dụng" : "Có phiên bản mới",
      description: forced
          ? "Phiên bản ${result.currentVersion} không còn được hỗ trợ. "
                "Hãy cập nhật lên ${result.config.latestVersion} để tiếp tục."
          : "Đã có phiên bản ${result.config.latestVersion}. "
                "Bạn có muốn cập nhật ngay không?",
      semantic: forced
          ? UiKitDialogSemantic.error
          : UiKitDialogSemantic.warning,
      icon: forced ? Icons.system_update_alt : Icons.system_update_outlined,
      dismissible: !forced,
      actions: [
        UiKitDialogAction(
          label: "Cập nhật ngay",
          variant: forced
              ? UiKitButtonVariant.danger
              : UiKitButtonVariant.primary,
          onPressed: () => _showToast(
            UiKitToastType.success,
            "Mở store: ${result.config.storeUrl}",
          ),
        ),
        if (!forced)
          UiKitDialogAction(
            label: "Để sau",
            variant: UiKitButtonVariant.ghost,
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

    return UiKitToastOverlay(
      queue: _toastQueue,
      child: UiKitLoadingOverlay(
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
          description:
              "Network log, trace, feature flag và host panel trong bubble overlay.",
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
          description:
              "Headless interaction primitives: app quyết định style, SDK quản lý behavior.",
        ),
        const _UiKitCoverageCard(),
        _Section(
          title: "Foundation / feedback",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const UiKitTitle(
                text: "Account overview",
                description: "Title, avatar, badge, icon và card shell.",
                headingSize: UiKitTitleHeadingSize.lg,
                bottomSpacing: 12,
              ),
              UiKitCardShell(
                shadow: true,
                child: Row(
                  children: [
                    const UiKitAvatar(
                      initials: "NA",
                      size: UiKitAvatarSize.lg,
                      status: UiKitAvatarStatus.online,
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
                    const UiKitIcon(
                      Icons.verified_outlined,
                      color: UiKitIconColor.success,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  UiKitBadge(
                    label: "Primary",
                    semantic: UiKitBadgeSemantic.primary,
                  ),
                  UiKitBadge(
                    label: "Success",
                    variant: UiKitBadgeVariant.solid,
                    semantic: UiKitBadgeSemantic.success,
                  ),
                  UiKitBadge(count: 128, semantic: UiKitBadgeSemantic.info),
                  UiKitBadge(
                    variant: UiKitBadgeVariant.dot,
                    semantic: UiKitBadgeSemantic.warning,
                    semanticsLabel: "Có cảnh báo mới",
                  ),
                ],
              ),
              const SizedBox(height: 12),
              UiKitAlertBanner(
                title: "Profile đã được xác thực",
                description: "Bạn có thể tiếp tục sử dụng toàn bộ tính năng.",
                semantic: UiKitAlertSemantic.success,
                action: UiKitAlertAction(
                  label: "Xem chi tiết",
                  onPressed: () =>
                      _showToast(UiKitToastType.normal, "Đã chọn xem chi tiết"),
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
                  UiKitButton.text(
                    onPressed: () => _showToast(
                      UiKitToastType.success,
                      "Primary button pressed",
                    ),
                    label: "Primary",
                  ),
                  UiKitButton.text(
                    onPressed: () {},
                    label: "Outline",
                    variant: UiKitButtonVariant.outline,
                  ),
                  UiKitButton.icon(
                    onPressed: () {},
                    icon: Icons.add,
                    semanticsLabel: "Add item",
                    variant: UiKitButtonVariant.ghost,
                  ),
                  const UiKitButton.text(
                    onPressed: null,
                    label: "Disabled",
                    disabled: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              UiKitCheckbox(
                value: _checked,
                label: "Nhận thông báo từ app",
                description: "Có thể thay đổi trong phần cài đặt.",
                onChanged: (value) => setState(() => _checked = value),
              ),
              const SizedBox(height: 4),
              UiKitSwitch(
                value: _switched,
                label: "Biometric login",
                sublabel: "Dùng Face ID hoặc vân tay khi đăng nhập.",
                onChanged: (value) => setState(() => _switched = value),
              ),
              const SizedBox(height: 16),
              UiKitTextField(
                controller: _textController,
                label: "Display name",
                placeholder: "Nhập tên hiển thị",
                isRequired: true,
                iconLeft: Icons.person_outline,
                helperText: "Tối đa 40 ký tự.",
              ),
              const SizedBox(height: 12),
              UiKitTextField(
                controller: _passwordController,
                label: "Password",
                type: UiKitTextFieldType.password,
                variant: UiKitTextFieldVariant.success,
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
              UiKitSearch(
                value: _searchValue,
                placeholder: "Tìm trong SDK...",
                semanticsLabel: "Tìm kiếm package",
                onChanged: (value) => setState(() => _searchValue = value),
                onClear: () => setState(() => _searchValue = ""),
              ),
              const SizedBox(height: 16),
              UiKitTabs(
                activeId: _activeTab,
                onChanged: (value) => setState(() => _activeTab = value),
                items: const [
                  UiKitTabItem(
                    id: "overview",
                    label: "Overview",
                    icon: Icons.dashboard_outlined,
                    badge: UiKitTabBadge(count: 3),
                  ),
                  UiKitTabItem(
                    id: "activity",
                    label: "Activity",
                    icon: Icons.history,
                    badge: UiKitTabBadge(dot: true),
                  ),
                  UiKitTabItem(
                    id: "disabled",
                    label: "Disabled",
                    disabled: true,
                  ),
                ],
              ),
              UiKitListItem(
                title: _searchValue.isEmpty
                    ? "mobile_ui_kit"
                    : "Kết quả: $_searchValue",
                description: "Reusable headless components",
                leading: const UiKitIcon(
                  Icons.widgets_outlined,
                  color: UiKitIconColor.primary,
                ),
                selected: _activeTab == "overview",
                divider: UiKitListItemDivider.inset,
                onTap: () =>
                    _showToast(UiKitToastType.normal, "UiKitListItem pressed"),
              ),
              UiKitListItem(
                title: "mobile_devtool",
                description: "Network, trace và host panels",
                leading: const UiKitIcon(
                  Icons.build_outlined,
                  color: UiKitIconColor.info,
                ),
                divider: UiKitListItemDivider.full,
                onTap: () =>
                    _showToast(UiKitToastType.normal, "UiKitListItem pressed"),
              ),
            ],
          ),
        ),
        _Section(
          title: "Dialog",
          child: UiKitButton.text(
            onPressed: () {
              unawaited(
                UiKitDialog.show(
                  context,
                  title: "Xác nhận thao tác",
                  description: "Đây là dialog dùng chung từ mobile_ui_kit.",
                  semantic: UiKitDialogSemantic.info,
                  actions: [
                    UiKitDialogAction(
                      label: "Tiếp tục",
                      variant: UiKitButtonVariant.primary,
                      onPressed: () {},
                    ),
                    UiKitDialogAction(
                      label: "Hủy",
                      variant: UiKitButtonVariant.ghost,
                      onPressed: () {},
                    ),
                  ],
                ),
              );
            },
            label: "Preview UiKitDialog",
          ),
        ),
        _Section(
          title: "Pressable states / Item",
          child: Column(
            children: [
              UiKitPressable(
                selected: _selected,
                onPress: () => setState(() => _selected = !_selected),
                builder: (context, states, child) => AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:
                        states.contains(UiKitPressableState.pressed) ||
                            _selected
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
              UiKitPressable(
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
              UiKitPressable(
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
              UiKitItem(
                title: const Text("UiKitItem title"),
                subtitle: const Text("Row có prefix và suffix"),
                prefix: CircleAvatar(
                  radius: 18,
                  backgroundColor: colors.primaryContainer,
                  child: Icon(Icons.person_outline, color: colors.primary),
                ),
                suffix: const Icon(Icons.chevron_right),
                onPress: () =>
                    _showToast(UiKitToastType.normal, "UiKitItem pressed"),
              ),
              UiKitItem(
                title: Text(
                  "UiKitItem disabled",
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
              UiKitRadio(
                value: _selected,
                selectedColor: colors.primary,
                borderColor: colors.outline,
                label: const Text("UiKitRadio selected"),
                onChanged: (value) => setState(() => _selected = value),
              ),
              const SizedBox(height: 12),
              UiKitRadio(
                value: !_selected,
                selectedColor: colors.primary,
                borderColor: colors.outline,
                label: const Text("UiKitRadio unchecked"),
                onChanged: (value) => setState(() => _selected = !value),
              ),
              const SizedBox(height: 12),
              UiKitRadio(
                value: false,
                enabled: false,
                selectedColor: colors.primary,
                borderColor: colors.outline,
                disabledColor: colors.onSurface.withValues(alpha: .3),
                label: const Text("UiKitRadio disabled"),
              ),
              const SizedBox(height: 16),
              UiKitDeterminateProgress(
                value: _progress,
                height: 10,
                trackColor: colors.surfaceContainerHighest,
                fillColor: colors.primary,
                borderRadius: BorderRadius.circular(8),
                semanticsLabel: "SDK progress",
              ),
              Row(
                children: [
                  const Text("UiKitDeterminateProgress"),
                  const Spacer(),
                  IconButton(
                    onPressed: () => setState(
                      () => _progress = (_progress + .1).clamp(0, 1),
                    ),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              UiKitDivider(color: colors.outlineVariant),
              const SizedBox(height: 12),
              SizedBox(
                height: 32,
                child: Row(
                  children: [
                    const Text("Vertical"),
                    const SizedBox(width: 12),
                    UiKitDivider(
                      axis: Axis.vertical,
                      color: colors.outlineVariant,
                      thickness: 2,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "UiKitDivider axis=vertical",
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
              UiKitAccordion(
                expandedIds: _expandedIds,
                onChanged: (value) => setState(() => _expandedIds = value),
                dividerColor: colors.outlineVariant,
                items: [
                  const UiKitAccordionItem(
                    id: "behavior",
                    title: Text("UiKitAccordion behavior"),
                    content: Padding(
                      padding: EdgeInsets.fromLTRB(0, 8, 0, 12),
                      child: Text(
                        "Expanded state được quản lý ở app layer bằng Set<String>.",
                      ),
                    ),
                  ),
                  UiKitAccordionItem(
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
              UiKitTooltip(
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
              UiKitAnchoredOverlay(
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
              UiKitOtpField(
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
                    _showToast(UiKitToastType.success, "OTP hoàn tất: $value"),
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
                    unawaited(_showLoading(UiKitLoadingStep.spinner)),
                child: const Text("Spinner"),
              ),
              OutlinedButton(
                onPressed: () =>
                    unawaited(_showLoading(UiKitLoadingStep.success)),
                child: const Text("Success"),
              ),
              OutlinedButton(
                onPressed: () =>
                    unawaited(_showLoading(UiKitLoadingStep.error)),
                child: const Text("Error"),
              ),
              for (final type in UiKitToastType.values)
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
                title: const Text("UiKitSkeleton enabled"),
                onChanged: (value) => setState(() => _skeletonEnabled = value),
              ),
              UiKitSkeleton(
                enabled: _skeletonEnabled,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Bone.circle(size: 42),
                  title: Bone.text(words: 3),
                  subtitle: Bone.text(words: 6),
                ),
              ),
              const SizedBox(height: 8),
              for (var index = 0; index < 3; index++)
                UiKitListEntrance(
                  index: index,
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text("${index + 1}")),
                      title: Text("Animated item ${index + 1}"),
                      subtitle: const Text("UiKitListEntrance fade + slide"),
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
          description:
              "Bubble ở góc màn hình mở Network, Trace, Feature Flags và các built-in tools.",
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
                MobileDevToolJsonFormatter.format(const {
                  "sdk": "mobile",
                  "packages": 3,
                  "enabled": true,
                }),
                style: const TextStyle(fontFamily: "monospace"),
              ),
              const SizedBox(height: 12),
              MobileDevToolKvTable(
                rows: [
                  const MobileDevToolKvRow(
                    label: "environment",
                    value: "example",
                  ),
                  const MobileDevToolKvRow(label: "ui_kit", value: "enabled"),
                  MobileDevToolKvRow(
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
              "dùng MobileDevToolController.disabled() cho production.",
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
          description:
              "Framework-agnostic helper: host cung cấp config source, version loader và UI prompt.",
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
                label: const Text("Run MobileUpdateChecker"),
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
                  UiKitButton.text(
                    onPressed: () =>
                        unawaited(_showUpdateDialog(_updateResult!)),
                    label: decision.isForced
                        ? "Preview force update dialog"
                        : "Preview soft update dialog",
                    variant: decision.isForced
                        ? UiKitButtonVariant.danger
                        : UiKitButtonVariant.outline,
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
            "in the host app. Dialog preview bên trên dùng UiKitDialog; app thật "
            "có thể thay bằng màn hình/localized copy riêng. mobile_update chỉ "
            "trả về none, soft hoặc force.",
          ),
        ),
      ],
    );
  }

  Future<void> _simulateNetwork() async {
    final id = widget.controller.startNetwork(
      const MobileDevToolNetworkRequest(
        label: "GetSdkCatalog",
        endpoint: "/v1/sdk/catalog",
        method: "GET",
        kind: MobileDevToolNetworkKind.rest,
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
      const MobileDevToolNetworkRequest(
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

class _DemoConfigSource implements MobileUpdateConfigSource {
  @override
  Future<MobileUpdateConfig> fetch() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const MobileUpdateConfig(
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
    "StatusPill (UiKitBadge)",
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
    "Progress",
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
                    label: Text("UiKit$name"),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "API behavior: UiKitLoadingController, UiKitToastQueue, "
              "UiKitOverlayController, UiKitOtpController và các enum/state "
              "được dùng trực tiếp trong các section bên dưới.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              "Các component còn lại trong roadmap: Menu, Picker, "
              "IconCircleButton và AppBar.",
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
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

  final UiKitLoadingStep step;

  @override
  Widget build(BuildContext context) {
    final isSpinner = step == UiKitLoadingStep.spinner;
    final isSuccess = step == UiKitLoadingStep.success;
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

  final UiKitToastType type;
  final String message;

  @override
  Widget build(BuildContext context) {
    final color = switch (type) {
      UiKitToastType.normal => Theme.of(context).colorScheme.inverseSurface,
      UiKitToastType.warning => Colors.orange.shade800,
      UiKitToastType.success => Colors.green.shade700,
      UiKitToastType.error => Theme.of(context).colorScheme.error,
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
