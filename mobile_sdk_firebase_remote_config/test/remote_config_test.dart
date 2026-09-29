import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_sdk_firebase_remote_config/mobile_sdk_firebase_remote_config.dart';

void main() {
  test(
    'keeps last good snapshot when fetch fails or config is invalid',
    () async {
      final enabled = ConfigKey.bool('enabled', defaultValue: false);
      final interval = ConfigKey.int(
        'interval',
        defaultValue: 60,
        min: 15,
        max: 3600,
      );
      final transport = InMemoryRemoteConfigTransport();
      final statuses = <String>[];
      final source = MobileRemoteConfigSource(
        schema: MobileRemoteConfigSchema([enabled, interval]),
        settings: const MobileRemoteConfigSettings(
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
}
