import "package:material_ui/material_ui.dart";
import "package:mobile_ui_kit/mobile_ui_kit.dart" as ui;

/// Standalone preview of the main-based hotfix, independent of the 0.8 showcase.
void main() => runApp(const HotfixPreview());

class HotfixPreview extends StatefulWidget {
  const HotfixPreview({super.key});

  @override
  State<HotfixPreview> createState() => _HotfixPreviewState();
}

class _HotfixPreviewState extends State<HotfixPreview> {
  final _otp = ui.OtpController(length: 6);
  final _loading = ui.LoadingController();

  @override
  void dispose() {
    _otp.dispose();
    _loading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ui.Theme.material(
      tokens: ui.ThemeData.fromDefaults(
        sizes: const ui.ComponentSizes(chipHeight: 32, statMinHeight: 96),
      ),
    ),
    home: Scaffold(
      appBar: AppBar(title: const Text("UI Kit hotfix rc.3")),
      body: ui.LoadingOverlay(
        controller: _loading,
        builder: (_, _) => const Center(child: Text("Đang xử lý…")),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ui.ListItem(
              title: "Thông báo chưa đọc",
              description: "Giờ nằm dưới nội dung; chấm ở mép phải.",
              titleStyle: const TextStyle(fontWeight: FontWeight.w600),
              crossAxisAlignment: CrossAxisAlignment.start,
              meta: const Text("Hôm nay, 14:42"),
              trailing: const ui.Badge(variant: ui.BadgeVariant.dot),
              onTap: () {},
            ),
            const SizedBox(height: 16),
            const ui.StatTile(
              label: "Quá hạn",
              value: "12",
              layout: ui.StatTileLayout.valueFirst,
              meta: Text("Kiểu chữ số lấy từ theme.numeric"),
            ),
            const SizedBox(height: 16),
            const ui.AlertBanner(
              title: "Cần bổ sung thông tin",
              quote: "Vui lòng chụp rõ giấy tờ.",
              quoteSource: "Người kiểm tra",
              semantic: ui.AlertSemantic.neutral,
              showBorder: false,
              leading: Icon(Icons.info_outline),
            ),
            const SizedBox(height: 16),
            ui.OtpField(
              controller: _otp,
              semanticLabel: "Mã xác thực",
              decorationBuilder: (context, _, active) => InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: active
                        ? ui.Theme.of(context).primary
                        : ui.Theme.of(context).border,
                  ),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 16),
            const ui.Timeline(
              items: [
                ui.TimelineItem(title: "Đã tạo", meta: Text("Hôm nay, 09:10")),
                ui.TimelineItem(
                  title: "Đã xác nhận",
                  meta: Text("Hôm nay, 09:12"),
                ),
              ],
            ),
            ui.Button(
              label: "Thử loading bên ngoài nút",
              loading: _loading.visible,
              loadingBehavior: ui.ButtonLoadingBehavior.external,
              onPressed: () async {
                final task = _loading.run(() async {
                  await Future<void>.delayed(const Duration(seconds: 1));
                });
                setState(() {});
                await task;
                if (mounted) setState(() {});
              },
            ),
          ],
        ),
      ),
    ),
  );
}
