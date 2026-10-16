import "package:flutter_test/flutter_test.dart";
import "package:mobile_app_base/mobile_app_base.dart" as app;

void main() {
  test("production never enables developer tools", () {
    const config = app.AppConfig(
      environment: app.AppEnvironment.prod,
      appName: "Production",
      enableDeveloperTools: true,
    );

    expect(config.developerToolsEnabled, isFalse);
  });

  test("demo config enables developer tools", () {
    expect(app.AppConfig.demo.developerToolsEnabled, isTrue);
  });
}
