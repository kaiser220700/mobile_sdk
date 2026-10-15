import "dart:convert";
import "dart:io";

import "package:flutter_test/flutter_test.dart";
import "package:mobile_sdk/mobile_sdk.dart";

void main() {
  test("resolved production entry point does not include DevTool", () {
    final config =
        jsonDecode(File(".dart_tool/package_config.json").readAsStringSync())
            as Map<String, dynamic>;
    final packages = (config["packages"] as List).map(
      (package) => (package as Map)["name"],
    );
    expect(packages, isNot(contains("mobile_devtool")));
  });
  test("exports each SDK module through one entry point", () {
    expect(AppConfig.demo.appName, isNotEmpty);
    expect(RefreshController(), isA<RefreshController>());
    expect(UiKitLoadingController(), isA<UiKitLoadingController>());
    expect(
      const MobileUpdatePolicy()
          .evaluate(
            currentVersion: "1.0.0",
            config: const MobileUpdateConfig.disabled(),
          )
          .shouldPrompt,
      isFalse,
    );
  });
}
