import "dart:async";

import "package:flutter/material.dart";
import "package:mobile_ui_kit/mobile_ui_kit.dart";

import "component_catalog.dart";
import "example_colors.dart";

void main() => runApp(const UiKitPreviewApp());

class UiKitPreviewApp extends StatefulWidget {
  const UiKitPreviewApp({super.key});

  @override
  State<UiKitPreviewApp> createState() => _UiKitPreviewAppState();
}

class _UiKitPreviewAppState extends State<UiKitPreviewApp> {
  ExampleColors _colors = const ExampleColors();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "mobile_ui_kit preview",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _colors.primary),
        scaffoldBackgroundColor: _colors.surface,
        useMaterial3: true,
        extensions: [_colors.theme],
      ),
      home: _PreviewHome(
        colors: _colors,
        onColorsChanged: (colors) => setState(() => _colors = colors),
      ),
    );
  }
}

class _PreviewHome extends StatefulWidget {
  const _PreviewHome({required this.colors, required this.onColorsChanged});

  final ExampleColors colors;
  final ValueChanged<ExampleColors> onColorsChanged;

  @override
  State<_PreviewHome> createState() => _PreviewHomeState();
}

class _PreviewHomeState extends State<_PreviewHome> {
  final _loading = UiKitLoadingController();
  final _toastQueue = UiKitToastQueue();
  final _overlay = UiKitOverlayController();
  final _otp = UiKitOtpController(length: 4);
  final _text = TextEditingController(text: "Nguyễn An");
  final _scrollController = ScrollController();

  Set<String> _expanded = {"overview"};
  final Set<String> _selectedIds = {};
  String _category = "all";
  String _query = "";
  String _activeTab = "overview";
  String _searchValue = "";
  double _progress = .62;
  bool _checked = true;
  bool _indeterminate = false;
  bool _switched = true;
  bool _skeletonEnabled = true;

  @override
  void dispose() {
    _loading.dispose();
    _toastQueue.dispose();
    _overlay.dispose();
    _otp.dispose();
    _text.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final definitions = _definitions(context)
        .where(
          (item) =>
              (_category == "all" || item.category == _category) &&
              (item.id.contains(_query.toLowerCase()) ||
                  item.flutterWidget.toLowerCase().contains(
                    _query.toLowerCase(),
                  )),
        )
        .toList();

    return UiKitToastOverlay(
      queue: _toastQueue,
      child: UiKitLoadingOverlay(
        controller: _loading,
        barrierColor: Colors.black54,
        builder: (context, step) => _LoadingPreview(step: step),
        child: Scaffold(
          appBar: AppBar(
            title: const Text("UI Kit Preview"),
            actions: [
              IconButton(
                tooltip: "Theme tokens",
                icon: const Icon(Icons.palette_outlined),
                onPressed: () => _showThemeDialog(context),
              ),
              IconButton(
                tooltip: "Component map",
                icon: const Icon(Icons.code_outlined),
                onPressed: () => _showMapDialog(context),
              ),
            ],
          ),
          body: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _buildIntro(context, definitions.length),
              _buildSearchAndFilters(context),
              _buildThemeStrip(context),
              for (final definition in definitions)
                _PreviewCard(
                  definition: definition,
                  child: definition.builder(context),
                ),
              if (definitions.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text("Không tìm thấy component.")),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntro(BuildContext context, int visibleCount) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("mobile_ui_kit", style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          const Text(
            "Một preview sống để đối chiếu HTML và widget app. Mỗi component có id ổn định, state và mapping tương ứng.",
          ),
          const SizedBox(height: 8),
          Text(
            "$visibleCount / ${_definitions(context).length} components · map: preview/component_map.json",
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: "Tìm theo id hoặc Flutter widget…",
            border: OutlineInputBorder(),
          ),
          onChanged: (value) =>
              setState(() => _query = value.trim().toLowerCase()),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final category in previewCategories)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: _category == category,
                    onSelected: (_) => setState(() => _category = category),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildThemeStrip(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = <({String name, Color color, Color? foreground})>[
      (name: "primary", color: widget.colors.primary, foreground: null),
      (
        name: "surface",
        color: widget.colors.surface,
        foreground: widget.colors.text,
      ),
      (
        name: "border",
        color: widget.colors.border,
        foreground: widget.colors.text,
      ),
      (name: "text", color: widget.colors.text, foreground: Colors.white),
      (name: "error", color: widget.colors.error, foreground: Colors.white),
    ];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("Theme tokens", style: theme.textTheme.titleSmall),
                const Spacer(),
                TextButton(
                  onPressed: () => _showThemeDialog(context),
                  child: const Text("Đổi màu"),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final token in tokens)
                  InputChip(
                    avatar: CircleAvatar(backgroundColor: token.color),
                    label: Text(token.name),
                    onPressed: () => _showThemeDialog(context),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<PreviewDefinition> _definitions(BuildContext context) => [
    PreviewDefinition(
      id: "alert-banner",
      category: "feedback",
      html: "<div role=\"alert\">",
      flutterWidget: "UiKitAlertBanner",
      description: "Thông báo inline với semantic và action.",
      builder: (context) => UiKitAlertBanner(
        title: "Profile đã được xác thực",
        description: "Bạn có thể tiếp tục sử dụng toàn bộ tính năng.",
        semantic: UiKitAlertSemantic.success,
        action: UiKitAlertAction(
          label: "Xem chi tiết",
          onPressed: () => _showToast(UiKitToastType.normal, "Alert action"),
        ),
      ),
    ),
    PreviewDefinition(
      id: "avatar",
      category: "foundation",
      html: "<img alt=\"...\">",
      flutterWidget: "UiKitAvatar",
      description: "Avatar initials, size, ring và status.",
      builder: (context) => const Wrap(
        spacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          UiKitAvatar(initials: "NA", size: UiKitAvatarSize.sm),
          UiKitAvatar(
            initials: "NA",
            size: UiKitAvatarSize.md,
            ring: true,
            status: UiKitAvatarStatus.online,
          ),
          UiKitAvatar(
            icon: Icons.person_outline,
            size: UiKitAvatarSize.lg,
            shape: UiKitAvatarShape.rounded,
          ),
        ],
      ),
    ),
    PreviewDefinition(
      id: "badge",
      category: "feedback",
      html: "<span>...</span>",
      flutterWidget: "UiKitBadge",
      description: "Label/count badge theo semantic và variant.",
      builder: (context) => const Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          UiKitBadge(label: "Primary", semantic: UiKitBadgeSemantic.primary),
          UiKitBadge(
            label: "Success",
            variant: UiKitBadgeVariant.solid,
            semantic: UiKitBadgeSemantic.success,
          ),
          UiKitBadge(count: 128, semantic: UiKitBadgeSemantic.info),
          UiKitBadge(
            variant: UiKitBadgeVariant.dot,
            semantic: UiKitBadgeSemantic.warning,
          ),
        ],
      ),
    ),
    PreviewDefinition(
      id: "status-pill",
      category: "feedback",
      html: "<span data-status>...</span>",
      flutterWidget: "UiKitBadge",
      description: "Status pill dùng chung UiKitBadge, tránh thêm component trùng tên.",
      builder: (context) => const Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          UiKitBadge.text(label: "Active", semantic: UiKitBadgeSemantic.success),
          UiKitBadge.textIcon(
            label: "Pending",
            icon: Icons.schedule_outlined,
            semantic: UiKitBadgeSemantic.warning,
          ),
          UiKitBadge.icon(
            icon: Icons.verified_outlined,
            semantic: UiKitBadgeSemantic.info,
            semanticsLabel: "Verified",
          ),
        ],
      ),
    ),
    PreviewDefinition(
      id: "button",
      category: "actions",
      html: "<button type=\"button\">...</button>",
      flutterWidget: "UiKitButton",
      description: "Các variant, icon, loading và disabled.",
      builder: (context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          UiKitButton.text(
            onPressed: () =>
                _showToast(UiKitToastType.success, "Button pressed"),
            label: "Primary",
          ),
          const UiKitButton.text(onPressed: null, label: "Disabled"),
          UiKitButton.icon(
            onPressed: () {},
            icon: Icons.add,
            semanticsLabel: "Add",
            variant: UiKitButtonVariant.outline,
          ),
        ],
      ),
    ),
    PreviewDefinition(
      id: "card-shell",
      category: "layout",
      html: "<section>...</section>",
      flutterWidget: "UiKitCardShell",
      description: "Surface có border/shadow để app lồng nội dung.",
      builder: (context) =>
          const UiKitCardShell(shadow: true, child: Text("CardShell content")),
    ),
    PreviewDefinition(
      id: "checkbox",
      category: "forms",
      html: "<input type=\"checkbox\">",
      flutterWidget: "UiKitCheckbox",
      description: "Checked, indeterminate, error và disabled.",
      builder: (context) => Column(
        children: [
          UiKitCheckbox(
            value: _checked,
            label: "Nhận thông báo",
            onChanged: (value) => setState(() => _checked = value),
          ),
          UiKitCheckbox(
            value: false,
            indeterminate: _indeterminate,
            label: "Indeterminate",
            onChanged: (value) =>
                setState(() => _indeterminate = !_indeterminate),
          ),
          const UiKitCheckbox(value: true, label: "Disabled", disabled: true),
        ],
      ),
    ),
    PreviewDefinition(
      id: "select-field",
      category: "forms",
      html: "<select>...</select>",
      flutterWidget: "UiKitSelectField",
      description: "Field chọn giá trị; host app sở hữu menu/options.",
      builder: (context) => UiKitSelectField(
        label: "Environment",
        value: "Preview",
        isRequired: true,
        leading: const Icon(Icons.tune_outlined),
        onTap: () => _showToast(UiKitToastType.normal, "Open select options"),
      ),
    ),
    PreviewDefinition(
      id: "filter-chip",
      category: "forms",
      html: "<button role=\"checkbox\">...</button>",
      flutterWidget: "UiKitFilterChip",
      description: "Chip toggle cho filter list/table.",
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          var selected = true;
          return StatefulBuilder(
            builder: (context, setState) => Wrap(
              spacing: 8,
              children: [
                UiKitFilterChip(
                  label: "Active",
                  selected: selected,
                  leadingIcon: Icons.circle,
                  onSelected: (_) => setState(() => selected = !selected),
                ),
                const UiKitFilterChip(
                  label: "Disabled",
                  enabled: false,
                ),
              ],
            ),
          );
        },
      ),
    ),
    PreviewDefinition(
      id: "dialog",
      category: "feedback",
      html: "<dialog>...</dialog>",
      flutterWidget: "UiKitDialog",
      description: "Dialog action của app layer, package chỉ điều phối.",
      builder: (context) => UiKitButton.text(
        onPressed: () => unawaited(
          UiKitDialog.show(
            context,
            title: "Xác nhận thao tác",
            description: "Dialog dùng chung từ mobile_ui_kit.",
            semantic: UiKitDialogSemantic.info,
            actions: [UiKitDialogAction(label: "Đóng", onPressed: () {})],
          ),
        ),
        label: "Open dialog",
      ),
    ),
    PreviewDefinition(
      id: "divider",
      category: "layout",
      html: "<hr>",
      flutterWidget: "UiKitDivider",
      description: "Divider ngang/dọc nhận màu từ theme.",
      builder: (context) => const Column(
        children: [
          Text("Above"),
          SizedBox(height: 8),
          UiKitDivider(),
          SizedBox(height: 8),
          Text("Below"),
        ],
      ),
    ),
    PreviewDefinition(
      id: "icon",
      category: "foundation",
      html: "<svg aria-hidden=\"true\">...</svg>",
      flutterWidget: "UiKitIcon",
      description: "Icon size và semantic color thống nhất.",
      builder: (context) => const Wrap(
        spacing: 16,
        children: [
          UiKitIcon(
            Icons.home_outlined,
            color: UiKitIconColor.primary,
            size: UiKitIconSize.sm,
          ),
          UiKitIcon(Icons.check_circle_outline, color: UiKitIconColor.success),
          UiKitIcon(
            Icons.warning_amber_outlined,
            color: UiKitIconColor.warning,
            size: UiKitIconSize.lg,
          ),
        ],
      ),
    ),
    PreviewDefinition(
      id: "item",
      category: "navigation",
      html: "<button class=\"item\">...</button>",
      flutterWidget: "UiKitItem",
      description: "Row primitive với prefix, subtitle và suffix.",
      builder: (context) => UiKitItem(
        title: const Text("Account settings"),
        subtitle: const Text("Profile, password và bảo mật"),
        prefix: const UiKitIcon(Icons.person_outline),
        suffix: const UiKitIcon(Icons.chevron_right),
        onPress: () => _showToast(UiKitToastType.normal, "Item pressed"),
      ),
    ),
    PreviewDefinition(
      id: "list-item",
      category: "navigation",
      html: "<li>...</li>",
      flutterWidget: "UiKitListItem",
      description: "List row có selected, leading/trailing, divider.",
      builder: (context) => Column(
        children: [
          UiKitListItem(
            title: "Selected item",
            description: "Description",
            selected: true,
            divider: UiKitListItemDivider.inset,
            leading: const UiKitIcon(Icons.widgets_outlined),
          ),
          UiKitListItem(
            title: "Disabled item",
            disabled: true,
            onTap: () {},
            leading: const UiKitIcon(Icons.lock_outline),
          ),
        ],
      ),
    ),
    PreviewDefinition(
      id: "list-entrance",
      category: "motion",
      html: "<li data-enter>...</li>",
      flutterWidget: "UiKitListEntrance",
      description: "Fade + slide stagger cho list entrance.",
      builder: (context) => Column(
        children: [
          for (var i = 0; i < 3; i++)
            UiKitListEntrance(
              index: i,
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text("${i + 1}")),
                  title: Text("Animated item ${i + 1}"),
                ),
              ),
            ),
        ],
      ),
    ),
    PreviewDefinition(
      id: "accordion",
      category: "disclosure",
      html: "<details><summary>...</summary></details>",
      flutterWidget: "UiKitAccordion",
      description: "ID-based expand/collapse và disabled item.",
      builder: (context) => UiKitAccordion(
        expandedIds: _expanded,
        onChanged: (value) => setState(() => _expanded = value),
        dividerColor: Theme.of(context).extension<UiKitThemeData>()!.border,
        items: const [
          UiKitAccordionItem(
            id: "overview",
            title: Text("Overview"),
            content: Padding(
              padding: EdgeInsets.all(12),
              child: Text("Content của accordion item."),
            ),
          ),
          UiKitAccordionItem(
            id: "disabled",
            title: Text("Disabled"),
            content: Text("Không mở được"),
            disabled: true,
          ),
        ],
        trailingBuilder: (context, expanded) =>
            Icon(expanded ? Icons.expand_less : Icons.expand_more),
      ),
    ),
    PreviewDefinition(
      id: "loading-overlay",
      category: "feedback",
      html: "<div aria-busy=\"true\">...</div>",
      flutterWidget: "UiKitLoadingOverlay",
      description: "Nút demo spinner, success và error overlay.",
      builder: (context) => Wrap(
        spacing: 8,
        children: [
          OutlinedButton(
            onPressed: () => unawaited(_showLoading(UiKitLoadingStep.spinner)),
            child: const Text("Spinner"),
          ),
          OutlinedButton(
            onPressed: () => unawaited(_showLoading(UiKitLoadingStep.success)),
            child: const Text("Success"),
          ),
          OutlinedButton(
            onPressed: () => unawaited(_showLoading(UiKitLoadingStep.error)),
            child: const Text("Error"),
          ),
        ],
      ),
    ),
    PreviewDefinition(
      id: "otp-field",
      category: "forms",
      html: "<input inputmode=\"numeric\" autocomplete=\"one-time-code\">",
      flutterWidget: "UiKitOtpField",
      description: "OTP controller + decoration/overlay builder.",
      builder: (context) => UiKitOtpField(
        controller: _otp,
        decorationBuilder: (context, index, focused) => InputDecoration(
          contentPadding: EdgeInsets.zero,
          counterText: "",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: focused
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).extension<UiKitThemeData>()!.border,
              width: focused ? 2 : 1,
            ),
          ),
        ),
        overlayBuilder: (context, index, value, hasFocus) => value.isEmpty
            ? null
            : const Center(child: Text("•", style: TextStyle(fontSize: 24))),
        textStyle: const TextStyle(fontSize: 20),
      ),
    ),
    PreviewDefinition(
      id: "anchored-overlay",
      category: "overlay",
      html: "<div popover>...</div>",
      flutterWidget: "UiKitAnchoredOverlay",
      description: "Popover neo vào trigger và dismiss qua barrier.",
      builder: (context) => UiKitAnchoredOverlay(
        controller: _overlay,
        overlayBuilder: (context) => Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(10),
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Text("Anchored overlay content"),
          ),
        ),
        child: OutlinedButton.icon(
          onPressed: _overlay.toggle,
          icon: const Icon(Icons.more_horiz),
          label: const Text("Toggle popover"),
        ),
      ),
    ),
    PreviewDefinition(
      id: "pressable",
      category: "interaction",
      html: "<button>...</button>",
      flutterWidget: "UiKitPressable",
      description:
          "Expose hovered/pressed/selected/disabled state cho app layer.",
      builder: (context) => UiKitPressable(
        selected: _selectedIds.contains("pressable"),
        onPress: () => setState(
          () => _selectedIds.contains("pressable")
              ? _selectedIds.remove("pressable")
              : _selectedIds.add("pressable"),
        ),
        builder: (context, states, child) => AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: states.contains(UiKitPressableState.selected)
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).extension<UiKitThemeData>()!.surfaceMuted,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(states.map((state) => state.name).join(" · ")),
        ),
      ),
    ),
    PreviewDefinition(
      id: "progress",
      category: "feedback",
      html: "<progress value=\"62\" max=\"100\">",
      flutterWidget: "UiKitDeterminateProgress",
      description: "Animated determinate progress với value 0..1.",
      builder: (context) => Column(
        children: [
          UiKitDeterminateProgress(
            value: _progress,
            height: 10,
            fillColor: Theme.of(context).colorScheme.primary,
            trackColor: Theme.of(context).extension<UiKitThemeData>()!.border,
            borderRadius: BorderRadius.circular(8),
            semanticsLabel: "Preview progress",
          ),
          Row(
            children: [
              Text("${(_progress * 100).round()}%"),
              const Spacer(),
              IconButton(
                onPressed: () =>
                    setState(() => _progress = (_progress + .1).clamp(0, 1)),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    ),
    PreviewDefinition(
      id: "radio",
      category: "forms",
      html: "<input type=\"radio\">",
      flutterWidget: "UiKitRadio",
      description: "Selected, unselected và disabled radio.",
      builder: (context) => Column(
        children: [
          UiKitRadio(
            value: _selectedIds.contains("radio"),
            label: const Text("Selected radio"),
            onChanged: (_) => setState(() => _selectedIds.add("radio")),
          ),
          const UiKitRadio(
            value: false,
            enabled: false,
            label: Text("Disabled radio"),
          ),
        ],
      ),
    ),
    PreviewDefinition(
      id: "search",
      category: "forms",
      html: "<input type=\"search\">",
      flutterWidget: "UiKitSearch",
      description: "Search with clear and reactive value.",
      builder: (context) => UiKitSearch(
        value: _searchValue,
        placeholder: "Tìm component…",
        onChanged: (value) => setState(() => _searchValue = value),
        onClear: () => setState(() => _searchValue = ""),
      ),
    ),
    PreviewDefinition(
      id: "stat-tile",
      category: "data",
      html: "<article data-stat>...</article>",
      flutterWidget: "UiKitStatTile",
      description: "Metric tile có value, icon và trend.",
      builder: (context) => UiKitStatTile(
        label: "Active users",
        value: "12,480",
        icon: Icons.people_outline,
        trend: UiKitStatTrend.up,
        trendLabel: "+12.4%",
        description: "vs last month",
        onTap: () => _showToast(UiKitToastType.normal, "Stat tile pressed"),
      ),
    ),
    PreviewDefinition(
      id: "key-value",
      category: "data",
      html: "<dl><dt>...</dt><dd>...</dd></dl>",
      flutterWidget: "UiKitKeyValue",
      description: "Metadata row cho detail/settings screen.",
      builder: (context) => Column(
        children: [
          UiKitKeyValue(label: "Status", value: "Active", valueWidget: const UiKitBadge.text(label: "Active", semantic: UiKitBadgeSemantic.success)),
          UiKitKeyValue(label: "Request ID", value: "req_123456", compact: true, onCopy: () => _showToast(UiKitToastType.success, "Copied")),
        ],
      ),
    ),
    PreviewDefinition(
      id: "skeleton",
      category: "feedback",
      html: "<div aria-busy=\"true\">...</div>",
      flutterWidget: "UiKitSkeleton",
      description: "Toggle shimmer loading ở app layer.",
      builder: (context) => Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _skeletonEnabled,
            title: const Text("Enabled"),
            onChanged: (value) => setState(() => _skeletonEnabled = value),
          ),
          UiKitSkeleton(
            enabled: _skeletonEnabled,
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Bone.circle(size: 42),
              title: Bone.text(words: 3),
              subtitle: Bone.text(words: 6),
            ),
          ),
        ],
      ),
    ),
    PreviewDefinition(
      id: "switch",
      category: "forms",
      html: "<input type=\"checkbox\" role=\"switch\">",
      flutterWidget: "UiKitSwitch",
      description: "Boolean switch có label, sublabel và disabled.",
      builder: (context) => Column(
        children: [
          UiKitSwitch(
            value: _switched,
            label: "Biometric login",
            sublabel: "Dùng Face ID hoặc vân tay.",
            onChanged: (value) => setState(() => _switched = value),
          ),
          const UiKitSwitch(value: true, label: "Disabled", disabled: true),
        ],
      ),
    ),
    PreviewDefinition(
      id: "tabs",
      category: "navigation",
      html: "<div role=\"tablist\">...</div>",
      flutterWidget: "UiKitTabs",
      description: "Underline/pill tabs, active và badge.",
      builder: (context) => Column(
        children: [
          UiKitTabs(
            activeId: _activeTab,
            onChanged: (value) => setState(() => _activeTab = value),
            items: const [
              UiKitTabItem(
                id: "overview",
                label: "Overview",
                icon: Icons.dashboard_outlined,
              ),
              UiKitTabItem(
                id: "activity",
                label: "Activity",
                badge: UiKitTabBadge(dot: true),
              ),
              UiKitTabItem(id: "disabled", label: "Disabled", disabled: true),
            ],
          ),
          const SizedBox(height: 8),
          UiKitTabs(
            variant: UiKitTabsVariant.pill,
            activeId: _activeTab,
            onChanged: (value) => setState(() => _activeTab = value),
            items: const [
              UiKitTabItem(id: "overview", label: "Overview"),
              UiKitTabItem(id: "activity", label: "Activity"),
            ],
          ),
        ],
      ),
    ),
    PreviewDefinition(
      id: "text-field",
      category: "forms",
      html: "<input>...</input>",
      flutterWidget: "UiKitTextField",
      description: "Text, password, helper/error và icon states.",
      builder: (context) => UiKitTextField(
        controller: _text,
        label: "Display name",
        placeholder: "Nhập tên hiển thị",
        isRequired: true,
        iconLeft: Icons.person_outline,
        helperText: "Tối đa 40 ký tự.",
      ),
    ),
    PreviewDefinition(
      id: "timeline",
      category: "data",
      html: "<ol data-timeline>...</ol>",
      flutterWidget: "UiKitTimeline",
      description: "Timeline dọc với completed/current/upcoming/error.",
      builder: (context) => const UiKitTimeline(
        items: [
          UiKitTimelineItem(title: "Order created", time: "09:10", status: UiKitTimelineStatus.completed),
          UiKitTimelineItem(title: "Payment confirmed", description: "Waiting for fulfillment", time: "09:12", status: UiKitTimelineStatus.current, icon: Icons.sync),
          UiKitTimelineItem(title: "Delivered", time: "--", status: UiKitTimelineStatus.upcoming, icon: Icons.local_shipping_outlined),
        ],
      ),
    ),
    PreviewDefinition(
      id: "stepper",
      category: "navigation",
      html: "<ol data-stepper>...</ol>",
      flutterWidget: "UiKitStepper",
      description: "Stepper dọc cho flow nhiều bước.",
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          var current = 1;
          return StatefulBuilder(
            builder: (context, setState) => UiKitStepper(
              currentIndex: current,
              onStepTapped: (index) => setState(() => current = index),
              steps: const [
                UiKitStep(title: "Account", subtitle: "Basic information"),
                UiKitStep(title: "Preferences", subtitle: "Choose your options"),
                UiKitStep(title: "Complete", subtitle: "Review and submit"),
              ],
            ),
          );
        },
      ),
    ),
    PreviewDefinition(
      id: "title",
      category: "typography",
      html: "<h2>...</h2>",
      flutterWidget: "UiKitTitle",
      description: "Heading + description theo size token.",
      builder: (context) => const UiKitTitle(
        text: "Account overview",
        description: "Title component của UI Kit",
        isRequired: true,
      ),
    ),
    PreviewDefinition(
      id: "toast-overlay",
      category: "feedback",
      html: "<div role=\"status\">...</div>",
      flutterWidget: "UiKitToastOverlay",
      description: "Queue toast; visual builder thuộc app layer.",
      builder: (context) => Wrap(
        spacing: 8,
        children: [
          for (final type in UiKitToastType.values)
            OutlinedButton(
              onPressed: () => _showToast(type, "Toast ${type.name}"),
              child: Text(type.name),
            ),
        ],
      ),
    ),
    PreviewDefinition(
      id: "tooltip",
      category: "overlay",
      html: "<div role=\"tooltip\">...</div>",
      flutterWidget: "UiKitTooltip",
      description: "Long-press trigger, tự dismiss theo duration.",
      builder: (context) => UiKitTooltip(
        tipBuilder: (context) => const Text("Long-press để xem tooltip"),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(10),
        child: const OutlinedButton(
          onPressed: null,
          child: Text("Long-press me"),
        ),
      ),
    ),
  ];

  Future<void> _showLoading(UiKitLoadingStep step) async {
    if (step == UiKitLoadingStep.spinner) _loading.showSpinner();
    if (step == UiKitLoadingStep.success) _loading.showSuccess();
    if (step == UiKitLoadingStep.error) _loading.showError();
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) _loading.hide();
  }

  void _showToast(UiKitToastType type, String message) {
    _toastQueue.enqueue(
      UiKitToastRequest(
        type: type,
        builder: (context) => _Toast(type: type, message: message),
      ),
    );
  }

  Future<void> _showThemeDialog(BuildContext context) async {
    final result = await showDialog<ExampleColors>(
      context: context,
      builder: (context) => _ThemeDialog(colors: widget.colors),
    );
    if (result != null) widget.onColorsChanged(result);
  }

  void _showMapDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("HTML ↔ Flutter map"),
        content: const SingleChildScrollView(
          child: Text(
            "Source of truth: mobile_ui_kit/preview/component_map.json\n\n"
            "Use components[].id as the stable key. HTML reads components[].html; app code maps the same key to components[].flutterWidget.",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Đóng"),
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.definition, required this.child});

  final PreviewDefinition definition;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    definition.id,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Chip(label: Text(definition.category)),
              ],
            ),
            const SizedBox(height: 4),
            Text(definition.description, style: theme.textTheme.bodySmall),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.web_outlined, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    definition.html,
                    style: const TextStyle(
                      fontFamily: "monospace",
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.phone_iphone_outlined, size: 16),
                const SizedBox(width: 6),
                Text(
                  definition.flutterWidget,
                  style: const TextStyle(fontFamily: "monospace", fontSize: 12),
                ),
              ],
            ),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}

class _ThemeDialog extends StatefulWidget {
  const _ThemeDialog({required this.colors});
  final ExampleColors colors;

  @override
  State<_ThemeDialog> createState() => _ThemeDialogState();
}

class _ThemeDialogState extends State<_ThemeDialog> {
  late ExampleColors _colors = widget.colors;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Theme tokens"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final token in [
              ("primary", _colors.primary),
              ("surface", _colors.surface),
              ("border", _colors.border),
              ("text", _colors.text),
              ("error", _colors.error),
            ])
              _TokenPicker(
                label: token.$1,
                color: token.$2,
                onChanged: (color) =>
                    setState(() => _setToken(token.$1, color)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() => _colors = const ExampleColors()),
          child: const Text("Reset"),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _colors),
          child: const Text("Apply"),
        ),
      ],
    );
  }

  void _setToken(String name, Color color) {
    _colors = switch (name) {
      "primary" => _colors.copyWith(primary: color),
      "surface" => _colors.copyWith(surface: color),
      "border" => _colors.copyWith(border: color),
      "text" => _colors.copyWith(text: color),
      "error" => _colors.copyWith(error: color),
      _ => _colors,
    };
  }
}

class _TokenPicker extends StatelessWidget {
  const _TokenPicker({
    required this.label,
    required this.color,
    required this.onChanged,
  });
  final String label;
  final Color color;
  final ValueChanged<Color> onChanged;

  static const _presets = [
    Color(0xFF176B87),
    Color(0xFF7C3AED),
    Color(0xFF0F766E),
    Color(0xFFB42318),
    Color(0xFF1D4ED8),
    Colors.white,
    Color(0xFFF7F5F1),
    Color(0xFFE2E8F0),
    Color(0xFF17242A),
    Color(0xFF64748B),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 72, child: Text(label)),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 6,
              children: [
                for (final preset in _presets)
                  InkWell(
                    onTap: () => onChanged(preset),
                    borderRadius: BorderRadius.circular(20),
                    child: CircleAvatar(radius: 13, backgroundColor: preset),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingPreview extends StatelessWidget {
  const _LoadingPreview({required this.step});
  final UiKitLoadingStep step;

  @override
  Widget build(BuildContext context) {
    final success = step == UiKitLoadingStep.success;
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              success
                  ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 42,
                    )
                  : step == UiKitLoadingStep.error
                  ? const Icon(Icons.error, color: Colors.red, size: 42)
                  : const CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text(step.name),
            ],
          ),
        ),
      ),
    );
  }
}

class _Toast extends StatelessWidget {
  const _Toast({required this.type, required this.message});
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
