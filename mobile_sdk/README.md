# mobile_sdk

Unified entry point for existing shared SDK modules and Firebase-independent
configuration/telemetry contracts. Firebase integrations are separate opt-in
packages, so importing `mobile_sdk` does not pull native Firebase plugins.

```yaml
dependencies:
  mobile_sdk:
    path: ../mobile_sdk
```

```dart
import 'package:mobile_sdk/mobile_sdk.dart' as ui;
```

See [Firebase implementation](../docs/firebase-implementation.md) for the
available adapter and rollout status.

## UI naming (1.0.0)

UI names are now unprefixed when imported with `as ui`. See the
[complete mapping](../docs/ui-api-naming.md). The examples below use the 1.0.0 names; `v0.7.0` still uses the `UiKit*` names in the migration table.

## Production without DevTool (SDK-12, 0.7.0)

`mobile_sdk` no longer depends on or exports `mobile_devtool`. This is a breaking
change from 0.6.6. Refresh/load-more is owned by `mobile_ui_kit` and re-exported
by `mobile_sdk`; neither production package requires DevTool.

```dart
import 'package:mobile_sdk/mobile_sdk.dart' as ui;

ui.RefreshView(
  onRefresh: reloadTasks,
  enableLoadMore: true,
  onLoadMore: loadNextPage, // Future<bool>: true if another page exists
  child: taskList,
);
```

Migration keeps constructor arguments and callback behavior unchanged:

| Old DevTool name | Production name in v0.7.0 | New name (1.0.0) |
| --- | --- | --- |
| `MobileDevToolRefreshLoadMore` | `UiKitRefreshLoadMore` | `ui.RefreshView` |
| `MobileDevToolRefreshConfiguration` | `UiKitRefreshConfiguration` | `ui.RefreshScope` |
| `MobileDevToolRefreshContentBuilder` | `UiKitRefreshContentBuilder` | `ui.RefreshContentBuilder` |
| `MobileDevToolLoadMoreContentBuilder` | `UiKitLoadMoreContentBuilder` | `ui.LoadMoreContentBuilder` |

Controllers, indicator widgets and status enums remain exported with their
existing names. You can also import `package:mobile_ui_kit/mobile_ui_kit.dart`
directly. DevTool retains deprecated aliases pointing at the same implementation.
Apps that need developer tooling must depend on and import `mobile_devtool`
explicitly in their development integration. Merely hiding its launcher does
not remove the dependency from a production graph.

For station-app: migrate SDK pins together to a published revision containing
this change, rename the refresh APIs, and remove development wrappers/assets
from the production source. Run the app's no-DevTool gate, refresh/pagination
tests and Prod APK build before distribution. The SDK change alone does not
remove existing DevTool source or assets from the app. This production path is
available starting with 0.7.0; 0.6.6 does not provide it.

## Other module APIs (1.0.0)

Use `sdk.AppShell`, `sdk.ConfigSchema`, `sdk.UpdateChecker` and
`sdk.UpdatePolicy` from an `as sdk` umbrella import, or import each package
directly with its module alias. Firebase and DevTool remain separate opt-ins.
See the [SDK-wide naming and migration guide](../docs/sdk-api-naming.md).
