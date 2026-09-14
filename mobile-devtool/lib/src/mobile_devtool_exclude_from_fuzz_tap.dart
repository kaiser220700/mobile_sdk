import "package:flutter/widgets.dart";
import "package:flutter/semantics.dart";

/// Semantics marker used by the fuzz runner when traversing the public
/// semantics tree.
const mobileDevToolFuzzTapExcludeTag = SemanticsTag("mobile-devtool-excluded");

/// Marks a subtree as belonging to the dev tool's own UI (bubble, panels,
/// overlays) so a fuzz-tap runner can exclude it from scanning — avoids the
/// runner tapping its own "Stop" button and logging it as a user action.
class ExcludeFromFuzzTap extends StatelessWidget {
  const ExcludeFromFuzzTap({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    hidden: true,
    tagForChildren: mobileDevToolFuzzTapExcludeTag,
    child: child,
  );
}
