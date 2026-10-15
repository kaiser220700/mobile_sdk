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
import 'package:mobile_sdk/mobile_sdk.dart';
```

See [Firebase implementation](../docs/firebase-implementation.md) for the
available adapter and rollout status.

## Production without DevTool (SDK-12, 0.7.0)

`mobile_sdk` no longer depends on or exports `mobile_devtool`. This is a breaking
change from 0.6.6. Refresh/load-more is owned by `mobile_ui_kit` and re-exported
by `mobile_sdk`; neither production package requires DevTool.

```dart
import 'package:mobile_sdk/mobile_sdk.dart';

UiKitRefreshLoadMore(
  onRefresh: reloadTasks,
  enableLoadMore: true,
  onLoadMore: loadNextPage, // Future<bool>: true if another page exists
  child: taskList,
);
```

Migration keeps constructor arguments and callback behavior unchanged:

| Old DevTool name | Production name |
| --- | --- |
| `MobileDevToolRefreshLoadMore` | `UiKitRefreshLoadMore` |
| `MobileDevToolRefreshConfiguration` | `UiKitRefreshConfiguration` |
| `MobileDevToolRefreshContentBuilder` | `UiKitRefreshContentBuilder` |
| `MobileDevToolLoadMoreContentBuilder` | `UiKitLoadMoreContentBuilder` |

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
