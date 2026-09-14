/// Runtime configuration owned by the app host.
///
/// SDK packages should receive capabilities and configuration from this
/// object; they should not decide which app flavor is running.
enum AppEnvironment { dev, sit, uat, prod }

class AppConfig {
  const AppConfig({
    required this.environment,
    required this.appName,
    this.enableDeveloperTools = false,
  });

  static const demo = AppConfig(
    environment: AppEnvironment.dev,
    appName: "Mobile SDK Example",
    enableDeveloperTools: true,
  );

  final AppEnvironment environment;
  final String appName;
  final bool enableDeveloperTools;

  bool get isProduction => environment == AppEnvironment.prod;

  /// Production is never allowed to mount developer tooling.
  bool get developerToolsEnabled => enableDeveloperTools && !isProduction;

  AppConfig copyWith({
    AppEnvironment? environment,
    String? appName,
    bool? enableDeveloperTools,
  }) {
    return AppConfig(
      environment: environment ?? this.environment,
      appName: appName ?? this.appName,
      enableDeveloperTools: enableDeveloperTools ?? this.enableDeveloperTools,
    );
  }
}
