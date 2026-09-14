/// Describes the general Fuzz Tap workflow — shown on the preview step so the
/// user knows what the runner will do before pressing "Run", regardless of
/// preset or custom config.
const String mobileDevToolFuzzRunWorkflowDescription =
    "Mỗi tick: quét toàn bộ widget bấm/chuyển trạng thái được đang hiển thị, "
    "thỉnh thoảng cuộn ngẫu nhiên 1 Scrollable để lộ nội dung ẩn, rồi chọn "
    "ngẫu nhiên 1 target và gọi callback — không hit-test hay mô phỏng gesture "
    "thật. Tự dừng ngay khi gặp lỗi network mới hoặc không còn widget bấm được "
    "sau vài tick liên tiếp; nếu không, dừng khi hết thời lượng phiên hoặc bấm "
    "Dừng thủ công.";

const List<Duration> mobileDevToolFuzzCustomTickIntervalOptions = [
  Duration(milliseconds: 500),
  Duration(seconds: 1),
  Duration(seconds: 2),
  Duration(seconds: 5),
];

const List<Duration?> mobileDevToolFuzzCustomSessionDurationOptions = [
  Duration(minutes: 1),
  Duration(minutes: 2),
  Duration(minutes: 5),
  Duration(minutes: 10),
  null,
];

/// Preset config for a Fuzz Tap session — only changes tick frequency and
/// session duration, NOT the scope of widgets/targets the runner picks from.
enum MobileDevToolFuzzRunPreset {
  light(
    label: "Nhẹ",
    description:
        "Tick mỗi 5s, chạy tối đa 2 phút — dò lỗi nhẹ nhàng, ít gây nhiễu log.",
    tickInterval: Duration(seconds: 5),
    sessionDuration: Duration(minutes: 2),
  ),

  standard(
    label: "Chuẩn",
    description:
        "Tick mỗi 2s, chạy tối đa 5 phút — cân bằng tốc độ dò lỗi và độ ổn định.",
    tickInterval: Duration(seconds: 2),
    sessionDuration: Duration(minutes: 5),
  ),

  aggressive(
    label: "Dồn dập",
    description:
        "Tick mỗi 500ms, chạy tối đa 3 phút — dò crash nhanh, dễ gây log dồn dập.",
    tickInterval: Duration(milliseconds: 500),
    sessionDuration: Duration(minutes: 3),
  ),

  unlimited(
    label: "Không giới hạn",
    description:
        "Tick mỗi 2s, không tự dừng theo thời lượng — chỉ dừng khi bấm Dừng hoặc gặp lỗi/stuck.",
    tickInterval: Duration(seconds: 2),
    sessionDuration: null,
  );

  const MobileDevToolFuzzRunPreset({
    required this.label,
    required this.description,
    required this.tickInterval,
    required this.sessionDuration,
  });

  final String label;
  final String description;
  final Duration tickInterval;
  final Duration? sessionDuration;

  MobileDevToolFuzzRunConfig toConfig({
    bool restrictToCurrentRoute = false,
    List<String> extraExcludeKeywords = const [],
  }) => MobileDevToolFuzzRunConfig(
    label: label,
    description: description,
    tickInterval: tickInterval,
    sessionDuration: sessionDuration,
    restrictToCurrentRoute: restrictToCurrentRoute,
    extraExcludeKeywords: extraExcludeKeywords,
  );
}

/// Actual run config — built by [MobileDevToolFuzzRunPreset.toConfig] or
/// directly when the user picks "Custom".
class MobileDevToolFuzzRunConfig {
  const MobileDevToolFuzzRunConfig({
    required this.label,
    required this.description,
    required this.tickInterval,
    required this.sessionDuration,
    this.restrictToCurrentRoute = false,
    this.extraExcludeKeywords = const [],
  });

  final String label;
  final String description;
  final Duration tickInterval;
  final Duration? sessionDuration;

  /// When `true`, the runner stops itself if the route changes right after a
  /// tap (suspected self-navigation) instead of continuing to fuzz the new
  /// screen.
  final bool restrictToCurrentRoute;

  /// Extra keywords (on top of the runner's built-in picker/camera keywords)
  /// whose matching widget label excludes it from being tapped.
  final List<String> extraExcludeKeywords;
}
