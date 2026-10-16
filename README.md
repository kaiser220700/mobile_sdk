# Mobile SDK

Stable shared Flutter capabilities, prepared for 1.0.0. Distribution uses Git;
pub.dev publication remains disabled.

## Packages

| Package | Scope |
| --- | --- |
| mobile_sdk | Production umbrella: app, core, UI and updates |
| mobile_app_base | App environment and Flutter app composition |
| mobile_sdk_core | Provider-independent configuration and telemetry contracts |
| mobile_ui_kit | UI components, behavior and accessibility |
| mobile_update | Host-driven version/config loading and update decisions |
| mobile_sdk_firebase_core | Opt-in Firebase adapter lifecycle |
| mobile_sdk_firebase_remote_config | Opt-in typed Firebase Remote Config |
| mobile_devtool | Non-production logging, launcher and tool menu |
| mobile_fuzz | Experimental 0.1.0 Semantics-based crash exploration |
| mobile_screen_draw | Experimental 0.1.0 screen annotations |

Stable packages share version 1.0.0. Experimental tools have independent
versions and are not covered by the stable 1.x API promise.

## Integration

After the release tag is published:

```yaml
dependencies:
  mobile_sdk:
    git:
      url: https://github.com/kaiser220700/mobile_sdk.git
      ref: v1.0.0
      path: mobile_sdk
```

```dart
import 'package:mobile_sdk/mobile_sdk.dart' as sdk;
import 'package:mobile_sdk/mobile_sdk.dart' as ui;
```

Use `sdk.AppShell`, `sdk.ConfigSchema`, `sdk.UpdatePolicy`, `ui.Button` and
`ui.RefreshView`. Firebase and developer tools require explicit opt-in package
dependencies. Keep developer tool imports/assets out of production source.

See [migration](docs/migration-1.0.0.md),
[API names](docs/sdk-api-naming.md), [UI names](docs/ui-api-naming.md),
[release evidence](docs/release-1.0.0.md) and
[release workflow](docs/release-workflow.md).

## Validation

Supported minimum: Flutter 3.44.6 / Dart 3.12.2. CI also exercises Flutter 3.47.4.
Run `./tool/verify_workspace.sh` for all dependencies, formatting, analysis,
tests and package boundaries; `./tool/verify_release_metadata.sh main` checks
stable/experimental version policy.

`example` is the full developer showcase. `production_example` is a production
consumer with refresh/pagination coverage and no DevTool/Fuzz/Screen Draw or
Firebase in its resolved graph. Its native builds are smoke artifacts rather
than an app-store/Firebase distribution release.

Public registry publication is separate: license/publisher ownership,
hosted dependencies and publish dry-runs must be established first.
