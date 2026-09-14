import "package:flutter/material.dart";

/// Overview of the SDK dev tools and their current package status.
class MobileDevToolInfoPanel extends StatelessWidget {
  const MobileDevToolInfoPanel({super.key});

  static const _publishedTools = [
    (
      name: "Network",
      description: "Theo dõi request, response, status và cURL.",
      icon: Icons.hub_outlined,
    ),
    (
      name: "Trace",
      description: "Ghi và xem trace log trong lúc phát triển.",
      icon: Icons.bug_report_outlined,
    ),
  ];

  static const _developmentTools = [
    (
      name: "Fuzz Tap",
      description: "Tự động quét và thử tap các target trong Semantics tree.",
      icon: Icons.smart_toy_outlined,
    ),
    (
      name: "Fuzz Tap Log",
      description: "Lịch sử các phiên chạy Fuzz Tap.",
      icon: Icons.receipt_long_outlined,
    ),
    (
      name: "Screen Draw",
      description: "Vẽ annotation trực tiếp trên màn hình.",
      icon: Icons.gesture,
    ),
    (
      name: "Feature Flags",
      description: "Bật/tắt các flag do app host đăng ký.",
      icon: Icons.flag_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          "Trạng thái package",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          "Published là các API nằm trong public package archive. Các tool còn lại hiện chỉ dùng cho source workspace và preview nội bộ.",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 20),
        _SectionHeader(
          label: "Published",
          color: Colors.green.shade700,
          icon: Icons.check_circle_outline,
        ),
        for (final tool in _publishedTools) _ToolStatusTile(tool: tool),
        const SizedBox(height: 16),
        _SectionHeader(
          label: "Đang phát triển",
          color: Colors.orange.shade800,
          icon: Icons.construction_outlined,
        ),
        for (final tool in _developmentTools) _ToolStatusTile(tool: tool),
        const SizedBox(height: 16),
        const Text(
          "Tool do app host đăng ký qua panels, menuItems hoặc hostActions không được SDK tự phân loại; trạng thái của chúng do app host quản lý.",
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolStatusTile extends StatelessWidget {
  const _ToolStatusTile({required this.tool});

  final ({String name, String description, IconData icon}) tool;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(tool.icon, color: Theme.of(context).colorScheme.primary),
      title: Text(tool.name),
      subtitle: Text(tool.description),
    );
  }
}
