import 'dart:math' as math;
import 'package:flutter/widgets.dart';

/// Keeps bottom actions clear of device padding, including inside a Scaffold.
class BottomActionArea extends StatelessWidget {
  const BottomActionArea({required this.child, this.minimum = 16, super.key})
    : assert(minimum >= 0);

  final Widget child;
  final double minimum;

  @override
  Widget build(BuildContext context) {
    final inset = math.max(
      MediaQuery.paddingOf(context).bottom,
      MediaQueryData.fromView(View.of(context)).padding.bottom,
    );
    return Padding(
      padding: EdgeInsets.only(bottom: math.max(minimum, inset)),
      child: MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: child,
      ),
    );
  }
}
