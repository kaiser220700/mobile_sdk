import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import "package:mobile_sdk_firebase_remote_config/mobile_sdk_firebase_remote_config.dart"
    as remote;

void main() {
  test('concurrent starts await the same initialization', () async {
    final transport = _GatedTransport();
    final source = _source(transport);
    final first = source.start();
    var secondDone = false;
    final second = source.start().then((_) => secondDone = true);
    await Future<void>.delayed(Duration.zero);
    expect(secondDone, isFalse);
    transport.configureGate.complete();
    await Future.wait([first, second]);
    expect(transport.configureCalls, 1);
    await source.dispose();
  });

  test('disposal ignores late initialization and rejects reuse', () async {
    final transport = _GatedTransport();
    final statuses = <String>[];
    final source = _source(transport, statuses.add);
    final starting = source.start();
    await source.dispose();
    transport.configureGate.complete();
    await starting;
    expect(transport.updatesController.hasListener, isFalse);
    expect(statuses, isEmpty);
    await expectLater(source.start(), throwsStateError);
    await expectLater(source.load(), throwsStateError);
    await source.dispose();
    expect(transport.disposeCalls, 1);
  });

  test('concurrent loads share fetch and late completion cannot emit after dispose', () async {
    final transport = _GatedTransport()..configureGate.complete();
    final source = _source(transport);
    await source.start();
    final first = source.load();
    final second = source.load();
    expect(transport.fetchCalls, 1);
    await source.dispose();
    transport.fetchGate.complete();
    await Future.wait([first, second]);
  });

  test(
    'keeps last good snapshot when fetch fails or config is invalid',
    () async {
      final enabled = remote.ConfigKey.bool('enabled', defaultValue: false);
      final interval = remote.ConfigKey.int(
        'interval',
        defaultValue: 60,
        min: 15,
        max: 3600,
      );
      final transport = remote.InMemoryTransport();
      final statuses = <String>[];
      final source = remote.Source(
        schema: remote.ConfigSchema([enabled, interval]),
        settings: const remote.Settings(
          fetchTimeout: Duration(seconds: 1),
          minimumFetchInterval: Duration.zero,
        ),
        transport: transport,
        onStatus: statuses.add,
      );
      await source.start();
      expect((await source.load()).require(enabled), false);
      transport.values = {'enabled': 'true', 'interval': '20'};
      expect((await source.load()).require(interval), 20);
      transport.values = {'enabled': 'false', 'interval': '1'};
      expect((await source.load()).require(enabled), true);
      expect(statuses, contains('validation_failed'));
      transport.failFetch = true;
      expect((await source.load()).require(interval), 20);
      expect(statuses, contains('fetch_failed'));
      await source.dispose();
    },
  );

  test('allows retrying initialization after transport setup fails', () async {
    final transport = remote.InMemoryTransport()..failConfigure = true;
    final statuses = <String>[];
    final source = remote.Source(
      schema: remote.ConfigSchema([
        remote.ConfigKey.bool('enabled', defaultValue: false),
      ]),
      settings: const remote.Settings(
        fetchTimeout: Duration(seconds: 1),
        minimumFetchInterval: Duration.zero,
      ),
      transport: transport,
      onStatus: statuses.add,
    );

    await source.start();
    expect(statuses, contains('initialize_failed'));
    expect(source.load(), throwsStateError);

    transport.failConfigure = false;
    await source.start();
    await expectLater(source.load(), completion(isA<remote.ConfigSnapshot>()));
    await source.dispose();
  });
}

remote.Source _source(
  _GatedTransport transport, [
  void Function(String)? onStatus,
]) => remote.Source(
  schema: remote.ConfigSchema([
    remote.ConfigKey.bool('enabled', defaultValue: false),
  ]),
  settings: const remote.Settings(
    fetchTimeout: Duration(seconds: 1),
    minimumFetchInterval: Duration.zero,
  ),
  transport: transport,
  onStatus: onStatus,
);

class _GatedTransport implements remote.Transport {
  final configureGate = Completer<void>();
  final fetchGate = Completer<void>();
  final updatesController = StreamController<void>.broadcast();
  int configureCalls = 0;
  int fetchCalls = 0;
  int disposeCalls = 0;
  @override
  Future<void> configure(
    remote.Settings settings,
    Map<String, String> defaults,
  ) async {
    configureCalls++;
    await configureGate.future;
  }

  @override
  Map<String, String> read(Iterable<String> keys) => {
    for (final key in keys) key: 'false',
  };
  @override
  Stream<void> get updates => updatesController.stream;
  @override
  Future<bool> fetchAndActivate() async {
    fetchCalls++;
    await fetchGate.future;
    return true;
  }

  @override
  Future<bool> activate() async => true;
  @override
  Future<void> dispose() async {
    disposeCalls++;
    await updatesController.close();
  }
}
