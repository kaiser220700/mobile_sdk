# Flutter 3.50 migration

The workspace now targets Flutter 3.50.0 and Dart 3.14.0. Both FVM configs,
CI jobs, and the available package/example constraints use this baseline.
Older SDKs are no longer in the CI support matrix.

## Local setup

```sh
fvm install
fvm flutter --version
./tool/verify_workspace.sh
npm ci
npm run test:web
npm run build
```

`verify_workspace.sh` selects the repository FVM SDK automatically. For another
installation, set `FLUTTER_BIN` to its Flutter executable.

## Material consumers

The UI packages and examples import the standalone design library:

```yaml
dependencies:
  material_ui: ^1.11.0
```

```dart
import 'package:material_ui/material_ui.dart';
import 'package:mobile_ui_kit/mobile_ui_kit.dart' as ui;
```

Migrate the host's Material imports, themes, and localization delegates together.
Standalone `ThemeData`, `ColorScheme`, component themes, and other design types
are distinct from the types in `package:flutter/material.dart`. This is a
breaking consumer change recorded in each affected package's Unreleased notes;
no release tag or published version is created by this migration.

For localized hosts, use `GlobalMaterialLocalizations.delegates` from
`material_ui`. Add `cupertino_ui` directly if the host imports Cupertino APIs.
The Dart-only core and update helpers do not gain a design-library dependency.

`pull_to_refresh_flutter3` still uses the SDK design libraries. `RefreshView`
wraps its refresher in Flutter's temporary `MaterialUiCompatibilityBridge` to
supply the matching legacy theme and localization data. Hosts do not need a
second app-wide wrapper for this integration. Remove the bridge when the refresh
dependency migrates; its deprecation suppression is limited to this call.

## Compatibility helper and native runners

`mobile_app_base` has been restored as the optional compatibility helper already
exported by `mobile_sdk` and used by both legacy demos. Its AppConfig,
AppEnvironment, AppShell and MobileAppShell entrypoints remain available. AppShell
now uses standalone Material types and requires Flutter 3.50 / Dart 3.14, matching
the rest of the workspace. The catalog retains this package and release metadata
validation can read its pubspec/changelog again.

Native example runners remain removed. Android/iOS builds require an app-owned
runner; the production example covers widget integration. Historical native
build reports apply to their original snapshots, not Flutter 3.50.

## Validation on 2026-11-16

The installed SDK reports Flutter 3.50.0 (framework `ab2912035e`) and Dart 3.14.0.

| Check | Result |
| --- | --- |
| Dependency resolution for all 14 packages/examples | Pass, including the restored app helper and all umbrella consumers |
| Analysis for all 14 packages/examples | Pass, including the nested DevTool example |
| Dart/Flutter tests across the workspace | Pass: 142 tests in 13 test groups; the DevTool example has no test directory |
| Dart 3.14 formatting across all package lib/test directories | Pass: 171 files, no changes required |
| Dependency boundaries | Pass: production, DevTool, Fuzz and Screen Draw |
| Portal tests (`npm run test:web`) | Pass: 6 tests |
| Release policy unit tests | Pass: 6 tests |
| Portal and Flutter Web release build (`npm run build`) | Pass; Wasm dry run also succeeded |
| Built portal package catalog | All 10 packages present, no dependency/catalog issues |
| Full workspace verification (`./tool/verify_workspace.sh`) | Pass |
| Release metadata validation | Pass |
| Android/iOS builds or device validation | Not performed; native example runners remain removed |

The Dart/Flutter test counts are UI Kit 72, DevTool 27, Fuzz 11,
Screen Draw 1, core 6, update 5, Firebase core 3, Firebase Remote Config 5,
UI showcase 2, production consumer 2, app helper 2, compatibility umbrella 3,
and SDK example 3. Firebase checks use the repository's fake-backed tests;
they do not validate a live Firebase project.

The helper was restored after the initial Flutter upgrade exposed its deletion.
This rerun supersedes the earlier partial workspace verification: dependency
resolution, umbrella compatibility tests and release metadata now all pass.

## References

- [Flutter 3.50 release notes](https://docs.flutter.dev/release/release-notes/release-notes-3.50.0)
- [Material/Cupertino migration and compatibility bridge](https://docs.flutter.dev/release/breaking-changes/material-ui-and-cupertino-ui)
