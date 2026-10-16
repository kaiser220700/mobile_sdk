import "package:flutter_test/flutter_test.dart";
import "package:mobile_sdk/mobile_sdk.dart" as sdk;

void main() {
  test("production never enables developer tools", () {
    const config = sdk.AppConfig(
      environment: sdk.AppEnvironment.prod,
      appName: "Production",
      enableDeveloperTools: true,
    );

    expect(config.developerToolsEnabled, isFalse);
  });

  test("demo config enables developer tools", () {
    expect(sdk.AppConfig.demo.developerToolsEnabled, isTrue);
  });
}
