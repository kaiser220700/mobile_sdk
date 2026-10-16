import "package:mobile_sdk_core/mobile_sdk_core.dart" as core;
import 'package:test/test.dart';

enum Mode { off, on }

void main() {
  final enabled = core.ConfigKey.bool('enabled', defaultValue: false);
  final seconds = core.ConfigKey.int(
    'seconds',
    defaultValue: 60,
    min: 15,
    max: 3600,
  );
  final mode = core.ConfigKey.enumValue(
    'mode',
    defaultValue: Mode.off,
    values: Mode.values,
  );
  final schema = core.ConfigSchema([enabled, seconds, mode]);

  test('typed defaults and immutable snapshot', () {
    final snapshot = schema.defaults();
    expect(snapshot.require(enabled), false);
    expect(snapshot.require(seconds), 60);
    expect(snapshot.source, core.ConfigValueSource.defaultValue);
    expect(() => schema.key<String>('seconds'), throwsArgumentError);
  });

  test('rejects entire invalid candidate', () {
    expect(
      () => schema.decode({
        'enabled': 'true',
        'seconds': '1',
        'mode': 'on',
      }, source: core.ConfigValueSource.remote),
      throwsFormatException,
    );
  });

  test('in-memory source publishes validated values', () async {
    final source = core.InMemoryConfigSource(schema);
    final next = source.changes.first;
    source.publish({'enabled': 'true', 'mode': 'on'});
    expect((await next).require(enabled), true);
    expect((await source.load()).require(mode), Mode.on);
    await source.dispose();
  });

  test('telemetry drops fields outside allow-list', () {
    final event = core.TelemetryEvent('app_start', {
      'environment': 'local',
      'unknown': 'x',
    });
    expect(event.allowOnly({'environment'}).parameters, {
      'environment': 'local',
    });
  });
}
