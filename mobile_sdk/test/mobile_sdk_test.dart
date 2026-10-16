import "dart:convert";
import "dart:io";

import "package:flutter_test/flutter_test.dart";
import "package:mobile_sdk/mobile_sdk.dart" as sdk;
import "package:mobile_sdk/mobile_sdk.dart" as ui;

void main() {
  test("production entry point keeps DevTool and Firebase opt-in", () {
    final config =
        jsonDecode(File(".dart_tool/package_config.json").readAsStringSync())
            as Map<String, dynamic>;
    final packages = (config["packages"] as List).map(
      (package) => (package as Map)["name"],
    );
    for (final optional in [
      "mobile_devtool",
      "firebase_core",
      "firebase_remote_config",
      "mobile_sdk_firebase_core",
      "mobile_sdk_firebase_remote_config",
    ]) {
      expect(packages, isNot(contains(optional)));
    }
  });
  test("exports each SDK module through one entry point", () {
    expect(sdk.AppConfig.demo.appName, isNotEmpty);
    final enabled = sdk.ConfigKey.bool("enabled", defaultValue: false);
    final schema = sdk.ConfigSchema([enabled]);
    expect(schema.defaults().require(enabled), isFalse);
    expect(ui.RefreshController(), isA<ui.RefreshController>());
    expect(ui.LoadingController(), isA<ui.LoadingController>());
    expect(
      const sdk.UpdatePolicy()
          .evaluate(
            currentVersion: "1.0.0",
            config: const sdk.UpdateConfig.disabled(),
          )
          .shouldPrompt,
      isFalse,
    );
  });
}
