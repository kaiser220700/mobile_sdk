# mobile_sdk

Optional compatibility umbrella for existing consumers. It still depends on
and exports mobile_app_base, core, UI and update packages. Its package path and
public entrypoint are retained. Firebase and developer tools remain opt-ins.

For new consumers, depend directly on only the modules required:
mobile_ui_kit for UI, mobile_sdk_core for typed config/telemetry, and
mobile_update for update decisions. Host-owned MaterialApp/environment wiring
is the default; mobile_app_base is an optional helper.

This package is 0.8.0-dev.0, not a workspace-wide stable 1.0.0 release.
See [organization](../docs/package-organization.md),
[module API names](../docs/sdk-api-naming.md),
[release workflow](../docs/release-workflow.md), and
[Firebase integration status](../docs/firebase-implementation.md).

Existing integrations can continue importing package:mobile_sdk/mobile_sdk.dart.
New unprefixed UI names may collide with Flutter names, so prefer import aliases.
Earlier breaking DevTool composition changes remain described in the historical
[migration notes](../docs/migration-1.0.0.md).
