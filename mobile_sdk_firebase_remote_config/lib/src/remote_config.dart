import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:mobile_sdk_core/mobile_sdk_core.dart';
import 'package:mobile_sdk_firebase_core/mobile_sdk_firebase_core.dart';

/// Host-owned policy for each environment.
final class MobileRemoteConfigSettings {
  const MobileRemoteConfigSettings({
    required this.fetchTimeout,
    required this.minimumFetchInterval,
  });

  final Duration fetchTimeout;
  final Duration minimumFetchInterval;
}

/// Narrow transport makes configuration tests independent of Firebase native.
abstract interface class RemoteConfigTransport {
  Future<void> configure(
    MobileRemoteConfigSettings settings,
    Map<String, String> defaults,
  );
  Map<String, String> read(Iterable<String> keys);
  Future<bool> fetchAndActivate();
  Future<bool> activate();
  Stream<void> get updates;
  Future<void> dispose();
}

final class FirebaseRemoteConfigTransport implements RemoteConfigTransport {
  FirebaseRemoteConfigTransport(FirebaseApp app)
    : _remote = FirebaseRemoteConfig.instanceFor(app: app);

  final FirebaseRemoteConfig _remote;

  @override
  Future<void> configure(
    MobileRemoteConfigSettings settings,
    Map<String, String> defaults,
  ) async {
    await _remote.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: settings.fetchTimeout,
        minimumFetchInterval: settings.minimumFetchInterval,
      ),
    );
    await _remote.setDefaults(defaults);
  }

  @override
  Map<String, String> read(Iterable<String> keys) => {
    for (final key in keys) key: _remote.getString(key),
  };

  @override
  Future<bool> fetchAndActivate() => _remote.fetchAndActivate();

  @override
  Future<bool> activate() => _remote.activate();

  @override
  Stream<void> get updates => _remote.onConfigUpdated.map((_) {});

  @override
  Future<void> dispose() async {}
}

/// Validates full snapshots; a failed fetch or invalid value keeps the last
/// good snapshot (or binary defaults on first load).
final class MobileRemoteConfigSource
    implements ConfigSource, MobileFirebaseAdapter {
  MobileRemoteConfigSource({
    required this.schema,
    required this.settings,
    required RemoteConfigTransport transport,
    this.onStatus,
  }) : _transport = transport,
       _snapshot = schema.defaults();

  final MobileRemoteConfigSchema schema;
  final MobileRemoteConfigSettings settings;
  final RemoteConfigTransport _transport;
  final void Function(String status)? onStatus;
  final StreamController<ConfigSnapshot> _changes =
      StreamController.broadcast();
  ConfigSnapshot _snapshot;
  StreamSubscription<void>? _subscription;
  bool _initialized = false;

  @override
  MobileFirebaseModule get module => MobileFirebaseModule.remoteConfig;

  @override
  Stream<ConfigSnapshot> get changes => _changes.stream;

  @override
  Future<void> initialize(FirebaseApp app, MobileFirebasePrivacy privacy) =>
      start();

  /// Starts the transport; test transports do not need a native Firebase app.
  Future<void> start() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await _transport.configure(settings, schema.encodedDefaults);
      _accept(ConfigValueSource.cache);
      _subscription = _transport.updates.listen((_) async {
        try {
          await _transport.activate();
          _accept(ConfigValueSource.remote);
        } catch (_) {
          onStatus?.call('realtime_update_failed');
        }
      });
    } catch (_) {
      onStatus?.call('initialize_failed');
    }
  }

  @override
  Future<ConfigSnapshot> load() async {
    if (!_initialized)
      throw StateError('Initialize the Remote Config module first');
    try {
      await _transport.fetchAndActivate().timeout(settings.fetchTimeout);
      if (_accept(ConfigValueSource.remote)) onStatus?.call('fetch_succeeded');
    } catch (_) {
      onStatus?.call('fetch_failed');
    }
    return _snapshot;
  }

  bool _accept(ConfigValueSource source) {
    try {
      final candidate = schema.decode(
        _transport.read(schema.names),
        source: source,
      );
      _snapshot = candidate;
      _changes.add(candidate);
      return true;
    } on FormatException {
      onStatus?.call('validation_failed');
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
    await _transport.dispose();
    await _changes.close();
  }
}

/// Fake transport for testing adapter behavior without native plugins.
final class InMemoryRemoteConfigTransport implements RemoteConfigTransport {
  final StreamController<void> _updates = StreamController.broadcast();
  Map<String, String> values = {};
  bool failFetch = false;
  Map<String, String> _defaults = {};

  @override
  Future<void> configure(
    MobileRemoteConfigSettings settings,
    Map<String, String> defaults,
  ) async {
    _defaults = Map.of(defaults);
  }

  @override
  Map<String, String> read(Iterable<String> keys) => {
    for (final key in keys) key: values[key] ?? _defaults[key] ?? '',
  };

  @override
  Future<bool> fetchAndActivate() async {
    if (failFetch) throw StateError('Fetch failed');
    return true;
  }

  @override
  Future<bool> activate() async => true;

  @override
  Stream<void> get updates => _updates.stream;

  void notifyUpdated() => _updates.add(null);

  @override
  Future<void> dispose() => _updates.close();
}
