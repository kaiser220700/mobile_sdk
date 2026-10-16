# Shared Flutter libraries

A monorepo of independently chosen Flutter packages. Distribution remains
Git-based; pub.dev publication is disabled. There is no workspace-wide 1.0.0
release: each package earns its own version and stability contract.

## Choose a package by responsibility

| Group | Packages | When to use |
| --- | --- | --- |
| Application libraries | mobile_ui_kit | Reusable UI and interaction behavior |
| Application libraries | mobile_sdk_core | Typed config/telemetry contracts when the app needs them |
| Application libraries | mobile_update | Update decisions and host-supplied config/version loading |
| Service adapters | mobile_sdk_firebase_core, mobile_sdk_firebase_remote_config | Explicit Firebase integration |
| Developer tools | mobile_devtool, mobile_fuzz, mobile_screen_draw | Non-production diagnostics and optional tools |
| Compatibility helpers | mobile_app_base | Optional app wiring; the host normally owns MaterialApp/config |
| Compatibility umbrella | mobile_sdk | Existing consumers that want app/core/UI/update together |

The [package catalog](docs/package-catalog.json) records responsibility and
readiness. Versions live in each pubspec, not in a shared version field.
UI Kit is currently `1.0.0-rc.1`, a candidate rather than a stable 1.0.0.
Other existing libraries are `0.8.0-dev.0`; Fuzz/Screen Draw are `0.1.0-dev.0`.
Matching version numbers do not imply a release dependency between packages.

## Default integration: only what the app uses

After the package tag is published, a UI-only app can use:

```yaml
dependencies:
  mobile_ui_kit:
    git:
      url: https://github.com/kaiser220700/mobile_sdk.git
      ref: mobile_ui_kit/v1.0.0-rc.1
      path: mobile_ui_kit
```

```dart
import 'package:flutter/material.dart';
import 'package:mobile_ui_kit/mobile_ui_kit.dart' as ui;

// The app owns its MaterialApp, routes and environment configuration.
ui.Button(onPressed: save, child: const Text('Save'));
```

Until a package tag is published, use an approved full commit revision instead.
Add config, update or Firebase packages only when the app needs those functions.

## Existing consumers

All package directories remain at their existing root paths. The
`package:mobile_sdk/mobile_sdk.dart` umbrella still exports app/core/UI/update
and still depends on mobile_app_base; its public exports have not been trimmed.
Existing consumers need not migrate simply for this organizational change.
It remains separate from Firebase and developer tools.

Direct package integration is recommended for new consumers. It avoids
pulling app composition into a UI-only app. See
[organization and compatibility](docs/package-organization.md),
[API names](docs/sdk-api-naming.md), [UI names](docs/ui-api-naming.md) and
[package release workflow](docs/release-workflow.md).

## Validation

Minimum supported toolchain: Flutter 3.44.6 / Dart 3.12.2. CI also exercises
Flutter 3.47.4. Run `./tool/verify_workspace.sh` for package resolution, format,
analysis, tests, release-policy tests and dependency boundaries.

`production_example` uses only mobile_ui_kit and host-owned MaterialApp.
`example` retains umbrella compatibility coverage and explicitly composes
optional developer tools. Existing Git tags/revisions remain unchanged.
