import "dart:async";
import "dart:ui";

import "package:flutter/foundation.dart";

/// Free-text filter over a network log list — plain `ValueNotifier` (no
/// dependency on any state-management library) so a widget can `ValueListenableBuilder`
/// directly.
class MobileDevToolNetworkSearch extends ValueNotifier<String> {
  MobileDevToolNetworkSearch() : super("");

  void clear() => value = "";
}

/// Selected status filter for a network log list — `null` means "all".
class MobileDevToolNetworkStatusFilter<T> extends ValueNotifier<T?> {
  MobileDevToolNetworkStatusFilter() : super(null);
}

/// Tracks which secret values (tokens, keys...) the user has revealed, keyed
/// by an arbitrary string the caller chooses (e.g. the storage key).
class MobileDevToolRevealState extends ChangeNotifier {
  final _revealed = <String>{};

  bool isRevealed(String key) => _revealed.contains(key);

  void toggle(String key) {
    if (!_revealed.remove(key)) _revealed.add(key);
    notifyListeners();
  }
}

/// Carries the latest incremental scroll delta from whatever `Scrollable` is
/// under the dev tool chrome — a plain `ChangeNotifier` rather than a
/// `ValueNotifier` so it always fires even when two consecutive deltas
/// happen to be equal (a `ValueNotifier` would silently skip that update).
class MobileDevToolScrollDelta extends ChangeNotifier
    implements ValueListenable<Offset> {
  Offset _value = Offset.zero;

  @override
  Offset get value => _value;

  void emit(Offset delta) {
    _value = delta;
    notifyListeners();
  }
}

/// Draggable-bubble position, clamped to the viewport by the widget that owns
/// the `MediaQuery`.
class MobileDevToolBubblePosition extends ValueNotifier<Offset> {
  MobileDevToolBubblePosition(Offset initial) : super(initial);
}

/// Fades the bubble after a period of inactivity — call [interact] on every
/// drag/tap to reset the idle timer.
class MobileDevToolBubbleIdle extends ValueNotifier<bool> {
  MobileDevToolBubbleIdle() : super(false) {
    _restartTimer();
  }

  static const _idleDelay = Duration(seconds: 3);

  Timer? _timer;

  void interact() {
    value = false;
    _restartTimer();
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer(_idleDelay, () => value = true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
