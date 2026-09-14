import "package:flutter/foundation.dart";

/// Shows/hides the full-screen Fuzz Tap overlay. Unlike a typical dismiss
/// toggle, this stays visible after a session stops (running/stuck/error/time
/// limit) so the report and next-scenario picker remain reachable — it only
/// hides when the user explicitly closes it.
class MobileDevToolFuzzTapOverlayActive extends ValueNotifier<bool> {
  MobileDevToolFuzzTapOverlayActive() : super(false);

  void show() => value = true;

  void hide() => value = false;
}
