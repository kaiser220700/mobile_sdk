import "package:flutter/widgets.dart";

/// Overlapping avatars for compact participant or assignee summaries.
///
/// The avatar widgets remain host-owned, which allows an app to use images,
/// initials, badges, or [UiKitAvatar] without coupling this layout primitive
/// to a particular avatar implementation.
class UiKitAvatarStack extends StatelessWidget {
  const UiKitAvatarStack({
    required this.avatars,
    this.diameter = 32,
    this.overlap = 10,
    this.maxVisible = 4,
    this.overflowBuilder,
    super.key,
  }) : assert(diameter > 0),
       assert(overlap >= 0 && overlap < diameter),
       assert(maxVisible > 0);

  final List<Widget> avatars;
  final double diameter;
  final double overlap;
  final int maxVisible;
  final Widget Function(BuildContext context, int hiddenCount)? overflowBuilder;

  @override
  Widget build(BuildContext context) {
    final visibleCount = avatars.length < maxVisible
        ? avatars.length
        : maxVisible;
    final hiddenCount = avatars.length - visibleCount;
    final items = <Widget>[...avatars.take(visibleCount)];
    if (hiddenCount > 0 && overflowBuilder != null) {
      items.add(overflowBuilder!(context, hiddenCount));
    }
    if (items.isEmpty) return const SizedBox.shrink();

    final stride = diameter - overlap;
    final width = diameter + (items.length - 1) * stride;
    return SizedBox(
      width: width,
      height: diameter,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var index = items.length - 1; index >= 0; index--)
            Positioned(
              left: index * stride,
              child: SizedBox.square(dimension: diameter, child: items[index]),
            ),
        ],
      ),
    );
  }
}
