import "mobile_update_config.dart";
import "mobile_update_policy.dart";

abstract interface class MobileUpdateConfigSource {
  Future<MobileUpdateConfig> fetch();
}

typedef MobileAppVersionLoader = Future<String> Function();

class MobileUpdateCheckResult {
  const MobileUpdateCheckResult({required this.config, required this.currentVersion, required this.decision});

  final MobileUpdateConfig config;
  final String currentVersion;
  final MobileUpdateDecision decision;
}

/// Coordinates config loading and policy evaluation without coupling the SDK
/// to Firebase, Riverpod, package_info_plus, or a particular UI framework.
class MobileUpdateChecker {
  const MobileUpdateChecker({
    required this.configSource,
    required this.loadCurrentVersion,
    this.policy = const MobileUpdatePolicy(),
  });

  final MobileUpdateConfigSource configSource;
  final MobileAppVersionLoader loadCurrentVersion;
  final MobileUpdatePolicy policy;

  Future<MobileUpdateCheckResult> check() async {
    final config = await configSource.fetch();
    if (!config.enabled) {
      return MobileUpdateCheckResult(config: config, currentVersion: "", decision: const MobileUpdateDecision.none());
    }

    final currentVersion = await loadCurrentVersion();
    return MobileUpdateCheckResult(
      config: config,
      currentVersion: currentVersion,
      decision: policy.evaluate(currentVersion: currentVersion, config: config),
    );
  }
}
