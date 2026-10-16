/// Optional compatibility umbrella for the mobile libraries.
///
/// New consumers should depend directly on the packages they need.
/// This entrypoint retains app, UI, update and core exports for existing users.
/// Firebase adapters and developer tools remain explicit opt-ins.
library;

export "package:mobile_app_base/mobile_app_base.dart";
export "package:mobile_sdk_core/mobile_sdk_core.dart";
export "package:mobile_ui_kit/mobile_ui_kit.dart";
export "package:mobile_update/mobile_update.dart";
