import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "mobile_devtool_fuzz_run_preset.dart";
import "mobile_devtool_fuzz_tap_runner.dart";
import "mobile_devtool_theme.dart";

/// Opens a standalone bottom sheet to configure and start a Fuzz Tap session.
Future<void> showMobileDevToolFuzzPresetSheet(
  BuildContext context, {
  required MobileDevToolFuzzTapRunner runner,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  barrierColor: MobileDevToolTheme.bottomSheetBarrierColor,
  builder: (context) => MobileDevToolFuzzPresetSheet(runner: runner),
);

/// 3-step flow: pick a preset (or "Custom") → if custom, pick tick
/// interval/session duration → preview + scope constraints, then "Run"
/// actually calls [MobileDevToolFuzzTapRunner.start].
class MobileDevToolFuzzPresetSheet extends StatefulWidget {
  const MobileDevToolFuzzPresetSheet({
    required this.runner,
    this.onDone,
    super.key,
  });

  final MobileDevToolFuzzTapRunner runner;
  final VoidCallback? onDone;

  @override
  State<MobileDevToolFuzzPresetSheet> createState() =>
      _MobileDevToolFuzzPresetSheetState();
}

class _MobileDevToolFuzzPresetSheetState
    extends State<MobileDevToolFuzzPresetSheet> {
  int _step = 0;
  bool _cameFromCustom = false;
  MobileDevToolFuzzRunConfig? _selectedConfig;
  Duration _customTickInterval = mobileDevToolFuzzCustomTickIntervalOptions[2];
  Duration? _customSessionDuration =
      mobileDevToolFuzzCustomSessionDurationOptions[2];
  bool _restrictToCurrentRoute = false;
  final _keywordsController = TextEditingController();

  @override
  void dispose() {
    _keywordsController.dispose();
    super.dispose();
  }

  MobileDevToolFuzzRunConfig _buildCustomConfig() => MobileDevToolFuzzRunConfig(
    label: "Tùy chỉnh",
    description:
        "Cấu hình tự chọn — tick $_customTickInterval, "
        "thời lượng ${_customSessionDuration == null ? 'không giới hạn' : '$_customSessionDuration'}.",
    tickInterval: _customTickInterval,
    sessionDuration: _customSessionDuration,
  );

  List<String> _parseKeywords(String raw) =>
      raw.split(",").map((k) => k.trim()).where((k) => k.isNotEmpty).toList();

  void _run() {
    final config = _selectedConfig;
    if (config == null) return;
    final withConstraints = MobileDevToolFuzzRunConfig(
      label: config.label,
      description: config.description,
      tickInterval: config.tickInterval,
      sessionDuration: config.sessionDuration,
      restrictToCurrentRoute: _restrictToCurrentRoute,
      extraExcludeKeywords: _parseKeywords(_keywordsController.text),
    );
    widget.runner.start(config: withConstraints);
    if (widget.onDone case final onDone?) {
      onDone();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      surfaceTintColor: Colors.transparent,
      color: MobileDevToolTheme.surface,
      borderRadius: MobileDevToolTheme.surfaceRadius,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: 16 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStep(context),
              const SizedBox(height: 16),
              _buildNav(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    return switch (_step) {
      0 => _PresetListStep(
        onSelectPreset: (preset) {
          setState(() {
            _selectedConfig = preset.toConfig();
            _cameFromCustom = false;
            _step = 2;
          });
        },
        onSelectCustom: () {
          setState(() {
            _selectedConfig = _buildCustomConfig();
            _cameFromCustom = true;
            _step = 1;
          });
        },
      ),
      1 => _CustomStep(
        tickInterval: _customTickInterval,
        sessionDuration: _customSessionDuration,
        onTickInterval: (value) => setState(() => _customTickInterval = value),
        onSessionDuration:
            (value) => setState(() => _customSessionDuration = value),
      ),
      _ => _PreviewStep(
        config: _selectedConfig,
        restrictToCurrentRoute: _restrictToCurrentRoute,
        onRestrictToCurrentRoute:
            (value) => setState(() => _restrictToCurrentRoute = value),
        keywordsController: _keywordsController,
      ),
    };
  }

  Widget _buildNav() {
    return Row(
      children: [
        if (_step > 0)
          TextButton(
            onPressed:
                () => setState(
                  () => _step = _step == 2 && !_cameFromCustom ? 0 : _step - 1,
                ),
            child: const Text("Quay lại"),
          ),
        const Spacer(),
        if (_step == 1)
          FilledButton(
            onPressed: () {
              setState(() => _selectedConfig = _buildCustomConfig());
              setState(() => _step = 2);
            },
            child: const Text("Xem trước"),
          ),
        if (_step == 2)
          FilledButton(
            onPressed: _selectedConfig == null ? null : _run,
            child: const Text("Chạy"),
          ),
      ],
    );
  }
}

class _PresetListStep extends StatelessWidget {
  const _PresetListStep({
    required this.onSelectPreset,
    required this.onSelectCustom,
  });

  final ValueChanged<MobileDevToolFuzzRunPreset> onSelectPreset;
  final VoidCallback onSelectCustom;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final preset in MobileDevToolFuzzRunPreset.values)
          ListTile(
            leading: const Icon(LucideIcons.bot),
            title: Text(preset.label),
            subtitle: Text(preset.description),
            onTap: () => onSelectPreset(preset),
          ),
        ListTile(
          leading: const Icon(LucideIcons.slidersHorizontal),
          title: const Text("Tùy chỉnh"),
          subtitle: const Text("Tự chọn tick interval và thời lượng phiên."),
          onTap: onSelectCustom,
        ),
      ],
    );
  }
}

class _CustomStep extends StatelessWidget {
  const _CustomStep({
    required this.tickInterval,
    required this.sessionDuration,
    required this.onTickInterval,
    required this.onSessionDuration,
  });

  final Duration tickInterval;
  final Duration? sessionDuration;
  final ValueChanged<Duration> onTickInterval;
  final ValueChanged<Duration?> onSessionDuration;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Mức độ (tick interval)",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          children: [
            for (final option in mobileDevToolFuzzCustomTickIntervalOptions)
              ChoiceChip(
                label: Text(_formatTickInterval(option)),
                selected: tickInterval == option,
                onSelected: (_) => onTickInterval(option),
              ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          "Thời lượng phiên",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          children: [
            for (final option in mobileDevToolFuzzCustomSessionDurationOptions)
              ChoiceChip(
                label: Text(
                  option == null
                      ? "Không giới hạn"
                      : "${option.inMinutes} phút",
                ),
                selected: sessionDuration == option,
                onSelected: (_) => onSessionDuration(option),
              ),
          ],
        ),
      ],
    );
  }
}

String _formatTickInterval(Duration duration) =>
    duration.inMilliseconds < 1000
        ? "${duration.inMilliseconds}ms"
        : "${duration.inSeconds}s";

class _PreviewStep extends StatelessWidget {
  const _PreviewStep({
    required this.config,
    required this.restrictToCurrentRoute,
    required this.onRestrictToCurrentRoute,
    required this.keywordsController,
  });

  final MobileDevToolFuzzRunConfig? config;
  final bool restrictToCurrentRoute;
  final ValueChanged<bool> onRestrictToCurrentRoute;
  final TextEditingController keywordsController;

  @override
  Widget build(BuildContext context) {
    final config = this.config;
    if (config == null)
      return const Text("Chưa chọn kịch bản — quay lại bước trước để chọn.");

    final durationLabel =
        config.sessionDuration == null
            ? "Không giới hạn"
            : "${config.sessionDuration}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(config.label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(config.description),
        const SizedBox(height: 12),
        _PreviewRow(label: "Tick interval", value: "${config.tickInterval}"),
        _PreviewRow(label: "Thời lượng phiên", value: durationLabel),
        const SizedBox(height: 12),
        const Text("Workflow", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(
          mobileDevToolFuzzRunWorkflowDescription,
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
        const SizedBox(height: 12),
        const Text(
          "Ràng buộc phạm vi",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: restrictToCurrentRoute,
          title: const Text("Chỉ fuzz trong màn hình hiện tại"),
          subtitle: const Text(
            "Tự dừng nếu 1 tap vô tình điều hướng sang màn khác.",
          ),
          onChanged: onRestrictToCurrentRoute,
        ),
        TextField(
          controller: keywordsController,
          decoration: const InputDecoration(
            labelText: "Từ khóa loại trừ bổ sung",
            hintText: "vd: đăng xuất, xoá tài khoản",
            helperText:
                "Cách nhau bởi dấu phẩy — nút có nhãn chứa từ khóa này sẽ không bị fuzz.",
          ),
        ),
      ],
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
