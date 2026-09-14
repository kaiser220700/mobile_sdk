import "package:flutter/widgets.dart";
import "package:skeletonizer/skeletonizer.dart";

export "package:skeletonizer/skeletonizer.dart"
    show Bone, PaintingEffect, Skeletonizer;

/// Wrapper mỏng quanh `skeletonizer` — chuẩn hoá tên gọi (`UiKit*`) và điểm
/// phụ thuộc duy nhất cho toàn app, không tự vẽ shimmer riêng. [child] nên
/// dựng bằng `Bone`/`Bone.circle`/`Bone.icon` để mô phỏng anatomy của UI
/// thật; [effect] cho app-layer override hiệu ứng shimmer nếu cần khác mặc
/// định của `skeletonizer`.
class UiKitSkeleton extends StatelessWidget {
  const UiKitSkeleton({
    required this.enabled,
    required this.child,
    this.effect,
    super.key,
  });

  final bool enabled;
  final Widget child;
  final PaintingEffect? effect;

  @override
  Widget build(BuildContext context) =>
      Skeletonizer(enabled: enabled, effect: effect, child: child);
}
