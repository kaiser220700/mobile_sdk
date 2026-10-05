/// Remote configuration consumed by the mobile update policy.
class MobileUpdateConfig {
  const MobileUpdateConfig({
    required this.enabled,
    required this.minVersion,
    required this.latestVersion,
    required this.storeUrl,
  });

  const MobileUpdateConfig.disabled()
    : enabled = false,
      minVersion = "",
      latestVersion = "",
      storeUrl = "";

  factory MobileUpdateConfig.fromJson(Map<String, Object?> json) {
    return MobileUpdateConfig(
      enabled: _boolOrFalse(json["enabled"]),
      minVersion: _stringOrEmpty(json["min_version"]),
      latestVersion: _stringOrEmpty(json["latest_version"]),
      storeUrl: _stringOrEmpty(json["store_url"]),
    );
  }

  static bool _boolOrFalse(Object? value) => value is bool && value;

  static String _stringOrEmpty(Object? value) => value is String ? value : "";

  /// Kill-switch. When false, the SDK returns the `none` requirement.
  final bool enabled;

  /// Versions below this threshold must update before continuing.
  final String minVersion;

  /// Versions below this threshold are encouraged to update but may continue.
  final String latestVersion;

  /// Store URL opened by the host app when the user chooses to update.
  final String storeUrl;
}
