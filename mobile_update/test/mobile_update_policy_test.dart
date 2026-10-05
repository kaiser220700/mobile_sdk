import 'package:mobile_update/mobile_update.dart';
import 'package:test/test.dart';

void main() {
  test('never forces an update without an install destination', () {
    const policy = MobileUpdatePolicy();
    for (final url in ['', 'javascript:alert(1)', 'https:/invalid']) {
      final decision = policy.evaluate(
        currentVersion: '1.0.0',
        config: MobileUpdateConfig(
          enabled: true,
          minVersion: '2.0.0',
          latestVersion: '2.0.0',
          storeUrl: url,
        ),
      );
      expect(decision.requirement, MobileUpdateRequirement.none);
    }
  });

  test('allows a valid store destination', () {
    final decision = const MobileUpdatePolicy().evaluate(
      currentVersion: '1.0.0',
      config: MobileUpdateConfig(
        enabled: true,
        minVersion: '2.0.0',
        latestVersion: '2.0.0',
        storeUrl: 'https://example.com/app',
      ),
    );
    expect(decision.requirement, MobileUpdateRequirement.force);
  });

  test('malformed JSON config fails closed instead of throwing', () {
    final config = MobileUpdateConfig.fromJson({
      'enabled': 'true',
      'min_version': 2,
      'latest_version': ['3.0.0'],
      'store_url': {'url': 'https://example.com/app'},
    });

    expect(config.enabled, isFalse);
    expect(config.minVersion, isEmpty);
    expect(config.latestVersion, isEmpty);
    expect(config.storeUrl, isEmpty);
    expect(
      const MobileUpdatePolicy()
          .evaluate(currentVersion: '1.0.0', config: config)
          .requirement,
      MobileUpdateRequirement.none,
    );
  });
}
