import "dart:async";

import "package:flutter/foundation.dart";

@immutable
class MobileDevToolLiveProviderInfo {
  const MobileDevToolLiveProviderInfo({required this.name});

  final String name;
}

/// Tracks Riverpod providers from creation to disposal without subscribing to
/// their state — a host `ProviderObserver` forwards its lifecycle callbacks
/// here. `onLog` defaults to [debugPrint] and can be overridden or disabled
/// (`onLog: (_) {}`) by the host.
class MobileDevToolProviderObserver {
  MobileDevToolProviderObserver({void Function(String message)? onLog})
    : _onLog = onLog ?? debugPrint;

  final void Function(String message) _onLog;
  final _providers = <Object, MobileDevToolLiveProviderInfo>{};
  final liveProviders = ValueNotifier<List<MobileDevToolLiveProviderInfo>>(
    const [],
  );
  bool _publishScheduled = false;

  void didAddProvider(Object provider, String? name) {
    _providers[provider] = MobileDevToolLiveProviderInfo(
      name: name ?? provider.runtimeType.toString(),
    );
    _schedulePublish();
    _onLog("+ ${name ?? provider.runtimeType}");
  }

  void didDisposeProvider(Object provider, String? name) {
    _providers.remove(provider);
    _schedulePublish();
    _onLog("- ${name ?? provider.runtimeType}");
  }

  void didUpdateProvider(Object provider, String? name) {
    _onLog("~ ${name ?? provider.runtimeType}");
  }

  void _schedulePublish() {
    if (_publishScheduled) return;
    _publishScheduled = true;
    scheduleMicrotask(() {
      _publishScheduled = false;
      liveProviders.value = [..._providers.values]
        ..sort((a, b) => a.name.compareTo(b.name));
    });
  }
}
