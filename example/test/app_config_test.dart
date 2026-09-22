import "package:flutter_test/flutter_test.dart";
import "package:mobile_sdk/mobile_sdk.dart";

void main() {
  test("production never enables developer tools", () {
    const config = AppConfig(
      environment: AppEnvironment.prod,
      appName: "Production",
      enableDeveloperTools: true,
    );

    expect(config.developerToolsEnabled, isFalse);
  });

  test("demo config enables developer tools", () {
    expect(AppConfig.demo.developerToolsEnabled, isTrue);
  });
}
