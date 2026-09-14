/// Remote configuration consumed by the mobile update policy.
class MobileUpdateConfig {
  const MobileUpdateConfig({
    required this.enabled,
    required this.minVersion,
    required this.latestVersion,
    required this.storeUrl,
  });

  const MobileUpdateConfig.disabled() : enabled = false, minVersion = "", latestVersion = "", storeUrl = "";

  factory MobileUpdateConfig.fromJson(Map<String, Object?> json) {
    return MobileUpdateConfig(
      enabled: json["enabled"] as bool? ?? false,
      minVersion: json["min_version"] as String? ?? "",
      latestVersion: json["latest_version"] as String? ?? "",
      storeUrl: json["store_url"] as String? ?? "",
    );
  }

  /// Kill-switch. When false, the SDK returns the `none` requirement.
  final bool enabled;

  /// Versions below this threshold must update before continuing.
  final String minVersion;

  /// Versions below this threshold are encouraged to update but may continue.
  final String latestVersion;

  /// Store URL opened by the host app when the user chooses to update.
  final String storeUrl;
}
