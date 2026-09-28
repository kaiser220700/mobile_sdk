import "package:flutter/material.dart";

/// Host-configurable screen shell; routing and app-bar composition stay host-owned.
class UiKitScaffold extends StatelessWidget {
  const UiKitScaffold({
    required this.child,
    this.appBar,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.safeArea = true,
    this.padding,
    super.key,
  });
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool safeArea;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: backgroundColor,
    resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    appBar: appBar,
    bottomNavigationBar: bottomNavigationBar,
    body: safeArea
        ? SafeArea(
            child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
          )
        : child,
  );
}
