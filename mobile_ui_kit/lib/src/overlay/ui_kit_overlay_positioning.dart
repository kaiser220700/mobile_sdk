import "package:flutter/widgets.dart";

/// Kết quả tính toán anchor sau khi xét overflow — [childAnchor]/
/// [overlayAnchor] có thể đã bị đảo (flip) theo trục dọc/ngang so với input
/// gốc để overlay không tràn ra ngoài [viewportSize].
class ResolvedOverlayAnchors {
  const ResolvedOverlayAnchors({
    required this.childAnchor,
    required this.overlayAnchor,
    required this.flippedVertically,
    required this.flippedHorizontally,
  });

  final Alignment childAnchor;
  final Alignment overlayAnchor;
  final bool flippedVertically;
  final bool flippedHorizontally;
}

/// Tính anchor pair thực tế cho overlay, tự đảo trục khi overlay tràn khỏi
/// viewport theo hướng ban đầu — thay `FPopover`'s `overflow: .flip` mặc
/// định. Hàm thuần (không phụ thuộc `BuildContext`/widget tree) để unit-test
/// trực tiếp.
///
/// [targetRect]: vị trí + kích thước của widget neo (anchor), tính theo toạ
/// độ global.
/// [overlaySize]: kích thước overlay sẽ hiển thị (đã đo hoặc ước lượng).
/// [viewportSize]: kích thước màn hình/viewport khả dụng.
ResolvedOverlayAnchors resolveFlippedAnchors({
  required Rect targetRect,
  required Size overlaySize,
  required Size viewportSize,
  required Alignment childAnchor,
  required Alignment overlayAnchor,
  bool flipWhenOverflow = true,
}) {
  if (!flipWhenOverflow) {
    return ResolvedOverlayAnchors(
      childAnchor: childAnchor,
      overlayAnchor: overlayAnchor,
      flippedVertically: false,
      flippedHorizontally: false,
    );
  }

  final anchorPoint = Offset(
    targetRect.left + targetRect.width * (childAnchor.x + 1) / 2,
    targetRect.top + targetRect.height * (childAnchor.y + 1) / 2,
  );

  final overlayTopLeft = Offset(
    anchorPoint.dx - overlaySize.width * (overlayAnchor.x + 1) / 2,
    anchorPoint.dy - overlaySize.height * (overlayAnchor.y + 1) / 2,
  );

  final overflowsBottom =
      overlayTopLeft.dy + overlaySize.height > viewportSize.height;
  final overflowsTop = overlayTopLeft.dy < 0;
  final overflowsRight =
      overlayTopLeft.dx + overlaySize.width > viewportSize.width;
  final overflowsLeft = overlayTopLeft.dx < 0;

  var resolvedChildAnchor = childAnchor;
  var resolvedOverlayAnchor = overlayAnchor;
  var flippedVertically = false;
  var flippedHorizontally = false;

  if (overflowsBottom && !overflowsTop) {
    resolvedChildAnchor = Alignment(
      resolvedChildAnchor.x,
      -resolvedChildAnchor.y,
    );
    resolvedOverlayAnchor = Alignment(
      resolvedOverlayAnchor.x,
      -resolvedOverlayAnchor.y,
    );
    flippedVertically = true;
  }

  if (overflowsRight && !overflowsLeft) {
    resolvedChildAnchor = Alignment(
      -resolvedChildAnchor.x,
      resolvedChildAnchor.y,
    );
    resolvedOverlayAnchor = Alignment(
      -resolvedOverlayAnchor.x,
      resolvedOverlayAnchor.y,
    );
    flippedHorizontally = true;
  }

  return ResolvedOverlayAnchors(
    childAnchor: resolvedChildAnchor,
    overlayAnchor: resolvedOverlayAnchor,
    flippedVertically: flippedVertically,
    flippedHorizontally: flippedHorizontally,
  );
}
