import 'package:mobile_update/mobile_update.dart' as updates;
import 'package:test/test.dart';

class _ConfigSource implements updates.UpdateConfigSource {
  _ConfigSource(this.config);
  final updates.UpdateConfig config;

  @override
  Future<updates.UpdateConfig> fetch() async => config;
}

void main() {
  test(
    'checker coordinates host inputs and returns the policy decision',
    () async {
      final calls = <String>[];
      final checker = updates.UpdateChecker(
        configSource: _ConfigSource(
          const updates.UpdateConfig(
            enabled: true,
            minVersion: '2.0.0',
            latestVersion: '3.0.0',
            storeUrl: 'https://example.com/app',
          ),
        ),
        loadCurrentVersion: () async {
          calls.add('version');
          return '1.0.0';
        },
      );
      final result = await checker.check();
      expect(calls, ['version']);
      expect(result.currentVersion, '1.0.0');
      expect(result.decision.requirement, updates.UpdateRequirement.force);
    },
  );

  test('disabled updates skip the host version loader', () async {
    final checker = updates.UpdateChecker(
      configSource: _ConfigSource(const updates.UpdateConfig.disabled()),
      loadCurrentVersion: () => throw StateError('Must not load'),
    );
    final result = await checker.check();
    expect(result.decision.requirement, updates.UpdateRequirement.none);
    expect(result.currentVersion, isEmpty);
  });
}
