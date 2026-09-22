import "package:flutter/widgets.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mobile_sdk/mobile_sdk.dart";

void main() {
  test("exports each SDK module through one entry point", () {
    expect(AppConfig.demo.appName, isNotEmpty);
    expect(MobileDevToolController(), isA<ChangeNotifier>());
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
