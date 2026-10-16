import "dart:async";

import "package:flutter/material.dart";
import "package:mobile_ui_kit/mobile_ui_kit.dart" as ui;

import "component_catalog.dart";
import "example_colors.dart";
import "foundation_preview.dart";

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
      theme: ui.Theme.material(tokens: _colors.theme),
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
  final _loading = ui.LoadingController();
  final _toastQueue = ui.ToastQueue();
  final _overlay = ui.OverlayController();
  final _otp = ui.OtpController(length: 4);
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

    return ui.ToastOverlay(
      queue: _toastQueue,
      child: ui.LoadingOverlay(
        controller: _loading,
        barrierColor: Colors.black54,
        builder: (context, step) => _LoadingPreview(step: step),
        child: Scaffold(
          appBar: AppBar(
            title: const Text("UI Kit Preview"),
            actions: [
              IconButton(
                tooltip: "UI foundations",
                icon: const Icon(Icons.dashboard_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const FoundationPreview(),
                  ),
                ),
              ),
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
      flutterWidget: "ui.AlertBanner",
      description: "Thông báo inline với semantic và action.",
      builder: (context) => ui.AlertBanner(
        title: "Profile đã được xác thực",
        description: "Bạn có thể tiếp tục sử dụng toàn bộ tính năng.",
        semantic: ui.AlertSemantic.success,
        action: ui.AlertAction(
          label: "Xem chi tiết",
          onPressed: () => _showToast(ui.ToastType.normal, "Alert action"),
        ),
      ),
    ),
    PreviewDefinition(
      id: "avatar",
      category: "foundation",
      html: "<img alt=\"...\">",
      flutterWidget: "ui.Avatar",
      description: "Avatar initials, size, ring và status.",
      builder: (context) => const Wrap(
        spacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ui.Avatar(initials: "NA", size: ui.AvatarSize.sm),
          ui.Avatar(
            initials: "NA",
            size: ui.AvatarSize.md,
            ring: true,
            status: ui.AvatarStatus.online,
          ),
          ui.Avatar(
            icon: Icons.person_outline,
            size: ui.AvatarSize.lg,
            shape: ui.AvatarShape.rounded,
          ),
        ],
      ),
    ),
    PreviewDefinition(
      id: "badge",
      category: "feedback",
      html: "<span>...</span>",
      flutterWidget: "ui.Badge",
      description: "Label/count badge theo semantic và variant.",
      builder: (context) => const Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ui.Badge(label: "Primary", semantic: ui.BadgeSemantic.primary),
          ui.Badge(
            label: "Success",
            variant: ui.BadgeVariant.solid,
            semantic: ui.BadgeSemantic.success,
          ),
          ui.Badge(count: 128, semantic: ui.BadgeSemantic.info),
          ui.Badge(
            variant: ui.BadgeVariant.dot,
            semantic: ui.BadgeSemantic.warning,
          ),
        ],
      ),
    ),
    PreviewDefinition(
      id: "status-pill",
      category: "feedback",
      html: "<span data-status>...</span>",
      flutterWidget: "ui.Badge",
      description:
          "Status pill dùng chung ui.Badge, tránh thêm component trùng tên.",
      builder: (context) => const Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ui.Badge.text(label: "Active", semantic: ui.BadgeSemantic.success),
          ui.Badge.textIcon(
            label: "Pending",
            icon: Icons.schedule_outlined,
            semantic: ui.BadgeSemantic.warning,
          ),
          ui.Badge.icon(
            icon: Icons.verified_outlined,
            semantic: ui.BadgeSemantic.info,
            semanticsLabel: "Verified",
          ),
        ],
      ),
    ),
    PreviewDefinition(
      id: "button",
      category: "actions",
      html: "<button type=\"button\">...</button>",
      flutterWidget: "ui.Button",
      description: "Các variant, icon, loading và disabled.",
      builder: (context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ui.Button.text(
            onPressed: () => _showToast(ui.ToastType.success, "Button pressed"),
            label: "Primary",
          ),
          const ui.Button.text(onPressed: null, label: "Disabled"),
          ui.Button.icon(
            onPressed: () {},
            icon: Icons.add,
            semanticsLabel: "Add",
            variant: ui.ButtonVariant.outline,
          ),
        ],
      ),
    ),
    PreviewDefinition(
      id: "card-shell",
      category: "layout",
      html: "<section>...</section>",
      flutterWidget: "ui.CardShell",
      description: "Surface có border/shadow để app lồng nội dung.",
      builder: (context) =>
          const ui.CardShell(shadow: true, child: Text("CardShell content")),
    ),
    PreviewDefinition(
      id: "checkbox",
      category: "forms",
      html: "<input type=\"checkbox\">",
      flutterWidget: "ui.Checkbox",
      description: "Checked, indeterminate, error và disabled.",
      builder: (context) => Column(
        children: [
          ui.Checkbox(
            value: _checked,
            label: "Nhận thông báo",
            onChanged: (value) => setState(() => _checked = value),
          ),
          ui.Checkbox(
            value: false,
            indeterminate: _indeterminate,
            label: "Indeterminate",
            onChanged: (value) =>
                setState(() => _indeterminate = !_indeterminate),
          ),
          const ui.Checkbox(value: true, label: "Disabled", disabled: true),
        ],
      ),
    ),
    PreviewDefinition(
      id: "select-field",
      category: "forms",
      html: "<select>...</select>",
      flutterWidget: "ui.SelectField",
      description: "Field chọn giá trị; host app sở hữu menu/options.",
      builder: (context) => ui.SelectField(
        label: "Environment",
        value: "Preview",
        isRequired: true,
        leading: const Icon(Icons.tune_outlined),
        onTap: () => _showToast(ui.ToastType.normal, "Open select options"),
      ),
    ),
    PreviewDefinition(
      id: "filter-chip",
      category: "forms",
      html: "<button role=\"checkbox\">...</button>",
      flutterWidget: "ui.FilterChip",
      description: "Chip toggle cho filter list/table.",
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          var selected = true;
          return StatefulBuilder(
            builder: (context, setState) => Wrap(
              spacing: 8,
              children: [
                ui.FilterChip(
                  label: "Active",
                  selected: selected,
                  leadingIcon: Icons.circle,
                  onSelected: (_) => setState(() => selected = !selected),
                ),
                const ui.FilterChip(label: "Disabled", enabled: false),
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
      flutterWidget: "ui.Dialog",
      description: "Dialog action của app layer, package chỉ điều phối.",
      builder: (context) => ui.Button.text(
        onPressed: () => unawaited(
          ui.Dialog.show(
            context,
            title: "Xác nhận thao tác",
            description: "Dialog dùng chung từ mobile_ui_kit.",
            semantic: ui.DialogSemantic.info,
            actions: [ui.DialogAction(label: "Đóng", onPressed: () {})],
          ),
        ),
        label: "Open dialog",
      ),
    ),
    PreviewDefinition(
      id: "divider",
      category: "layout",
      html: "<hr>",
      flutterWidget: "ui.Divider",
      description: "Divider ngang/dọc nhận màu từ theme.",
      builder: (context) => const Column(
        children: [
          Text("Above"),
          SizedBox(height: 8),
          ui.Divider(),
          SizedBox(height: 8),
          Text("Below"),
        ],
      ),
    ),
    PreviewDefinition(
      id: "icon",
      category: "foundation",
      html: "<svg aria-hidden=\"true\">...</svg>",
      flutterWidget: "ui.Icon",
      description: "Icon size và semantic color thống nhất.",
      builder: (context) => const Wrap(
        spacing: 16,
        children: [
          ui.Icon(
            Icons.home_outlined,
            color: ui.IconColor.primary,
            size: ui.IconSize.sm,
          ),
          ui.Icon(Icons.check_circle_outline, color: ui.IconColor.success),
          ui.Icon(
            Icons.warning_amber_outlined,
            color: ui.IconColor.warning,
            size: ui.IconSize.lg,
          ),
        ],
      ),
    ),
    PreviewDefinition(
      id: "item",
      category: "navigation",
      html: "<button class=\"item\">...</button>",
      flutterWidget: "ui.Item",
      description: "Row primitive với prefix, subtitle và suffix.",
      builder: (context) => ui.Item(
        title: const Text("Account settings"),
        subtitle: const Text("Profile, password và bảo mật"),
        prefix: const ui.Icon(Icons.person_outline),
        suffix: const ui.Icon(Icons.chevron_right),
        onPress: () => _showToast(ui.ToastType.normal, "Item pressed"),
      ),
    ),
    PreviewDefinition(
      id: "list-item",
      category: "navigation",
      html: "<li>...</li>",
      flutterWidget: "ui.ListItem",
      description: "List row có selected, leading/trailing, divider.",
      builder: (context) => Column(
        children: [
          ui.ListItem(
            title: "Selected item",
            description: "Description",
            selected: true,
            divider: ui.ListItemDivider.inset,
            leading: const ui.Icon(Icons.widgets_outlined),
          ),
          ui.ListItem(
            title: "Disabled item",
            disabled: true,
            onTap: () {},
            leading: const ui.Icon(Icons.lock_outline),
          ),
        ],
      ),
    ),
    PreviewDefinition(
      id: "list-entrance",
      category: "motion",
      html: "<li data-enter>...</li>",
      flutterWidget: "ui.ListEntrance",
      description: "Fade + slide stagger cho list entrance.",
      builder: (context) => Column(
        children: [
          for (var i = 0; i < 3; i++)
            ui.ListEntrance(
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
      id: "timeline-motion",
      category: "motion",
      html: "<div data-motion-timeline>...</div>",
      flutterWidget: "ui.Motion",
      description:
          "Một clock chung điều phối reward landing, attention pulse và CTA nudge.",
      builder: (context) => const _TimelineMotionPreview(),
    ),
    PreviewDefinition(
      id: "accordion",
      category: "disclosure",
      html: "<details><summary>...</summary></details>",
      flutterWidget: "ui.Accordion",
      description: "ID-based expand/collapse và disabled item.",
      builder: (context) => ui.Accordion(
        expandedIds: _expanded,
        onChanged: (value) => setState(() => _expanded = value),
        dividerColor: Theme.of(context).extension<ui.ThemeData>()!.border,
        items: const [
          ui.AccordionItem(
            id: "overview",
            title: Text("Overview"),
            content: Padding(
              padding: EdgeInsets.all(12),
              child: Text("Content của accordion item."),
            ),
          ),
          ui.AccordionItem(
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
      flutterWidget: "ui.LoadingOverlay",
      description: "Nút demo spinner, success và error overlay.",
      builder: (context) => Wrap(
        spacing: 8,
        children: [
          OutlinedButton(
            onPressed: () => unawaited(_showLoading(ui.LoadingStep.spinner)),
            child: const Text("Spinner"),
          ),
          OutlinedButton(
            onPressed: () => unawaited(_showLoading(ui.LoadingStep.success)),
            child: const Text("Success"),
          ),
          OutlinedButton(
            onPressed: () => unawaited(_showLoading(ui.LoadingStep.error)),
            child: const Text("Error"),
          ),
        ],
      ),
    ),
    PreviewDefinition(
      id: "otp-field",
      category: "forms",
      html: "<input inputmode=\"numeric\" autocomplete=\"one-time-code\">",
      flutterWidget: "ui.OtpField",
      description: "OTP controller + decoration/overlay builder.",
      builder: (context) => ui.OtpField(
        controller: _otp,
        decorationBuilder: (context, index, focused) => InputDecoration(
          contentPadding: EdgeInsets.zero,
          counterText: "",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: focused
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).extension<ui.ThemeData>()!.border,
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
      flutterWidget: "ui.AnchoredOverlay",
      description: "Popover neo vào trigger và dismiss qua barrier.",
      builder: (context) => ui.AnchoredOverlay(
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
      flutterWidget: "ui.Pressable",
      description:
          "Expose hovered/pressed/selected/disabled state cho app layer.",
      builder: (context) => ui.Pressable(
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
            color: states.contains(ui.PressableState.selected)
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).extension<ui.ThemeData>()!.surfaceMuted,
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
      flutterWidget: "ui.DeterminateProgress",
      description: "Animated determinate progress với value 0..1.",
      builder: (context) => Column(
        children: [
          ui.DeterminateProgress(
            value: _progress,
            height: 10,
            fillColor: Theme.of(context).colorScheme.primary,
            trackColor: Theme.of(context).extension<ui.ThemeData>()!.border,
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
      flutterWidget: "ui.Radio",
      description: "Selected, unselected và disabled radio.",
      builder: (context) => Column(
        children: [
          ui.Radio(
            value: _selectedIds.contains("radio"),
            label: const Text("Selected radio"),
            onChanged: (_) => setState(() => _selectedIds.add("radio")),
          ),
          const ui.Radio(
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
      flutterWidget: "ui.Search",
      description: "Search with clear and reactive value.",
      builder: (context) => ui.Search(
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
      flutterWidget: "ui.StatTile",
      description: "Metric tile có value, icon và trend.",
      builder: (context) => ui.StatTile(
        label: "Active users",
        value: "12,480",
        icon: Icons.people_outline,
        trend: ui.StatTrend.up,
        trendLabel: "+12.4%",
        description: "vs last month",
        onTap: () => _showToast(ui.ToastType.normal, "Stat tile pressed"),
      ),
    ),
    PreviewDefinition(
      id: "key-value",
      category: "data",
      html: "<dl><dt>...</dt><dd>...</dd></dl>",
      flutterWidget: "ui.KeyValue",
      description: "Metadata row cho detail/settings screen.",
      builder: (context) => Column(
        children: [
          ui.KeyValue(
            label: "Status",
            value: "Active",
            valueWidget: const ui.Badge.text(
              label: "Active",
              semantic: ui.BadgeSemantic.success,
            ),
          ),
          ui.KeyValue(
            label: "Request ID",
            value: "req_123456",
            compact: true,
            onCopy: () => _showToast(ui.ToastType.success, "Copied"),
          ),
        ],
      ),
    ),
    PreviewDefinition(
      id: "skeleton",
      category: "feedback",
      html: "<div aria-busy=\"true\">...</div>",
      flutterWidget: "ui.Skeleton",
      description: "Toggle shimmer loading ở app layer.",
      builder: (context) => Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _skeletonEnabled,
            title: const Text("Enabled"),
            onChanged: (value) => setState(() => _skeletonEnabled = value),
          ),
          ui.Skeleton(
            enabled: _skeletonEnabled,
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ui.Bone.circle(size: 42),
              title: ui.Bone.text(words: 3),
              subtitle: ui.Bone.text(words: 6),
            ),
          ),
        ],
      ),
    ),
    PreviewDefinition(
      id: "switch",
      category: "forms",
      html: "<input type=\"checkbox\" role=\"switch\">",
      flutterWidget: "ui.Switch",
      description: "Boolean switch có label, sublabel và disabled.",
      builder: (context) => Column(
        children: [
          ui.Switch(
            value: _switched,
            label: "Biometric login",
            sublabel: "Dùng Face ID hoặc vân tay.",
            onChanged: (value) => setState(() => _switched = value),
          ),
          const ui.Switch(value: true, label: "Disabled", disabled: true),
        ],
      ),
    ),
    PreviewDefinition(
      id: "tabs",
      category: "navigation",
      html: "<div role=\"tablist\">...</div>",
      flutterWidget: "ui.Tabs",
      description: "Underline/pill tabs, active và badge.",
      builder: (context) => Column(
        children: [
          ui.Tabs(
            activeId: _activeTab,
            onChanged: (value) => setState(() => _activeTab = value),
            items: const [
              ui.TabItem(
                id: "overview",
                label: "Overview",
                icon: Icons.dashboard_outlined,
              ),
              ui.TabItem(
                id: "activity",
                label: "Activity",
                badge: ui.TabBadge(dot: true),
              ),
              ui.TabItem(id: "disabled", label: "Disabled", disabled: true),
            ],
          ),
          const SizedBox(height: 8),
          ui.Tabs(
            variant: ui.TabsVariant.pill,
            activeId: _activeTab,
            onChanged: (value) => setState(() => _activeTab = value),
            items: const [
              ui.TabItem(id: "overview", label: "Overview"),
              ui.TabItem(id: "activity", label: "Activity"),
            ],
          ),
        ],
      ),
    ),
    PreviewDefinition(
      id: "text-field",
      category: "forms",
      html: "<input>...</input>",
      flutterWidget: "ui.TextField",
      description: "Text, password, helper/error và icon states.",
      builder: (context) => ui.TextField(
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
      flutterWidget: "ui.Timeline",
      description: "Timeline dọc với completed/current/upcoming/error.",
      builder: (context) => const ui.Timeline(
        items: [
          ui.TimelineItem(
            title: "Order created",
            time: "09:10",
            status: ui.TimelineStatus.completed,
          ),
          ui.TimelineItem(
            title: "Payment confirmed",
            description: "Waiting for fulfillment",
            time: "09:12",
            status: ui.TimelineStatus.current,
            icon: Icons.sync,
          ),
          ui.TimelineItem(
            title: "Delivered",
            time: "--",
            status: ui.TimelineStatus.upcoming,
            icon: Icons.local_shipping_outlined,
          ),
        ],
      ),
    ),
    PreviewDefinition(
      id: "stepper",
      category: "navigation",
      html: "<ol data-stepper>...</ol>",
      flutterWidget: "ui.Stepper",
      description: "Stepper dọc cho flow nhiều bước.",
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          var current = 1;
          return StatefulBuilder(
            builder: (context, setState) => ui.Stepper(
              currentIndex: current,
              onStepTapped: (index) => setState(() => current = index),
              steps: const [
                ui.Step(title: "Account", subtitle: "Basic information"),
                ui.Step(title: "Preferences", subtitle: "Choose your options"),
                ui.Step(title: "Complete", subtitle: "Review and submit"),
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
      flutterWidget: "ui.Title",
      description: "Heading + description theo size token.",
      builder: (context) => const ui.Title(
        text: "Account overview",
        description: "Title component của UI Kit",
        isRequired: true,
      ),
    ),
    PreviewDefinition(
      id: "toast-overlay",
      category: "feedback",
      html: "<div role=\"status\">...</div>",
      flutterWidget: "ui.ToastOverlay",
      description: "Queue toast; visual builder thuộc app layer.",
      builder: (context) => Wrap(
        spacing: 8,
        children: [
          for (final type in ui.ToastType.values)
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
      flutterWidget: "ui.Tooltip",
      description: "Long-press trigger, tự dismiss theo duration.",
      builder: (context) => ui.Tooltip(
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

  Future<void> _showLoading(ui.LoadingStep step) async {
    if (step == ui.LoadingStep.spinner) _loading.showSpinner();
    if (step == ui.LoadingStep.success) _loading.showSuccess();
    if (step == ui.LoadingStep.error) _loading.showError();
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) _loading.hide();
  }

  void _showToast(ui.ToastType type, String message) {
    _toastQueue.enqueue(
      ui.ToastRequest(
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

class _TimelineMotionPreview extends StatelessWidget {
  const _TimelineMotionPreview();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return ui.Motion(
      duration: const Duration(milliseconds: 2400),
      loop: true,
      builder: (BuildContext context, ui.MotionFrame frame, Widget? child) {
        final double landingScale = frame.valueAt(const [
          ui.MotionKeyframe(0, .82),
          ui.MotionKeyframe(.2, 1.08, Curves.easeOutBack),
          ui.MotionKeyframe(.32, 1),
          ui.MotionKeyframe(1, 1),
        ]);
        final double landingOpacity = frame.valueAt(const [
          ui.MotionKeyframe(0, 0),
          ui.MotionKeyframe(.16, 1, Curves.easeOut),
          ui.MotionKeyframe(1, 1),
        ]);
        final double pulseScale = frame.valueAt(const [
          ui.MotionKeyframe(0, 1),
          ui.MotionKeyframe(.54, 1),
          ui.MotionKeyframe(.68, 1.05, Curves.easeOut),
          ui.MotionKeyframe(.82, 1, Curves.easeIn),
          ui.MotionKeyframe(1, 1),
        ]);
        final double nudge = frame.valueAt(const [
          ui.MotionKeyframe(0, 0),
          ui.MotionKeyframe(.74, 0),
          ui.MotionKeyframe(.8, 6, Curves.easeOut),
          ui.MotionKeyframe(.86, -3, Curves.easeInOut),
          ui.MotionKeyframe(.92, 0, Curves.easeOut),
          ui.MotionKeyframe(1, 0),
        ]);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Opacity(
              opacity: landingOpacity,
              child: Transform.scale(
                scale: landingScale,
                child: Chip(
                  avatar: Icon(Icons.stars_rounded, color: colors.primary),
                  label: const Text("Reward landing"),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Transform.scale(
              scale: pulseScale,
              alignment: Alignment.centerLeft,
              child: Text(
                "Attention pulse",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 12),
            Transform.translate(
              offset: Offset(nudge, 0),
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward),
                label: const Text("CTA nudge"),
              ),
            ),
          ],
        );
      },
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
  final ui.LoadingStep step;

  @override
  Widget build(BuildContext context) {
    final success = step == ui.LoadingStep.success;
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
                  : step == ui.LoadingStep.error
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
