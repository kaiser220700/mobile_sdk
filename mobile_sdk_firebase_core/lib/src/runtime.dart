import 'package:firebase_core/firebase_core.dart';

/// Modules are opted into by the host app and supplied as adapters.
enum MobileFirebaseModule {
  analytics,
  crashlytics,
  performance,
  remoteConfig,
  messaging,
  appCheck,
  inAppMessaging,
}

final class MobileFirebasePrivacy {
  const MobileFirebasePrivacy({
    this.analyticsEnabled = false,
    this.crashlyticsEnabled = false,
    this.allowedEventKeys = const {},
  });

  final bool analyticsEnabled;
  final bool crashlyticsEnabled;
  final Set<String> allowedEventKeys;
}

abstract interface class MobileFirebaseAdapter {
  MobileFirebaseModule get module;
  Future<void> initialize(FirebaseApp app, MobileFirebasePrivacy privacy);
  Future<void> dispose();
}

final class MobileFirebaseRuntime {
  MobileFirebaseRuntime._(this.app, this.privacy, this.modules, this._adapters);

  final FirebaseApp app;
  final MobileFirebasePrivacy privacy;
  final Set<MobileFirebaseModule> modules;
  final List<MobileFirebaseAdapter> _adapters;
  bool _disposed = false;

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    for (final adapter in _adapters.reversed) {
      await adapter.dispose();
    }
  }
}

final class MobileFirebase {
  const MobileFirebase._();

  /// The host initializes Firebase and supplies only the adapters it needs.
  /// Successfully started adapters are disposed if a later one fails.
  static Future<MobileFirebaseRuntime> initialize({
    required FirebaseApp app,
    required Set<MobileFirebaseModule> modules,
    required MobileFirebasePrivacy privacy,
    required Iterable<MobileFirebaseAdapter> adapters,
  }) async {
    final byModule = <MobileFirebaseModule, MobileFirebaseAdapter>{};
    for (final adapter in adapters) {
      if (byModule.containsKey(adapter.module)) {
        throw ArgumentError('Duplicate adapter: ${adapter.module.name}');
      }
      byModule[adapter.module] = adapter;
    }
    if (!byModule.keys.toSet().containsAll(modules)) {
      throw ArgumentError('Missing adapter for selected module');
    }
    final started = <MobileFirebaseAdapter>[];
    try {
      for (final module in MobileFirebaseModule.values) {
        if (!modules.contains(module)) continue;
        final adapter = byModule[module]!;
        started.add(adapter);
        await adapter.initialize(app, privacy);
      }
    } catch (_) {
      for (final adapter in started.reversed) {
        try {
          await adapter.dispose();
        } catch (_) {
          // Keep the initialization error as the primary failure.
        }
      }
      rethrow;
    }
    return MobileFirebaseRuntime._(
      app,
      privacy,
      Set.unmodifiable(modules),
      List.unmodifiable(started),
    );
  }
}
