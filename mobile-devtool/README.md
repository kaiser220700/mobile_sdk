# mobile_devtool

Non-production network/trace logging, a draggable launcher, tool menu, host
actions and custom panels. Version 1.0.0 does not depend on Fuzz or Screen Draw.

```dart
import 'package:mobile_devtool/mobile_devtool.dart' as dev;

final logs = dev.Controller();
logs.recordTrace('Host initialized');
// Dispose logs with its owner.
```

Mount `dev.ToolsOverlay` in a root OverlayEntry using its `attach` helper, or
compose it in a full-screen Stack. The host owns the OverlayEntry lifecycle and
controller disposal. `Configuration` controls appearance, `menuItems` / `panels`
register screens, and `quickActions` registers header actions with `onSelect`.
Quick actions whose IDs are in `hiddenMenuItemIds` are omitted.

`dev.Recorder` is an optional static recording facade. Call `attachInstance`
once at the composition root and `detachInstance` before disposing that
controller. Prefer injected `dev.Controller` where the host already has DI.

## Optional tools

Fuzz Tap and Screen Draw are independent experimental packages. The DevTool
shell no longer creates or mounts them. See
[working example composition](../example/lib/developer_tools.dart) and
[1.0.0 migration](../docs/migration-1.0.0.md). Tools, route/scroll signals,
overlay visibility and disposal belong to host composition.

Only the exports in `lib/mobile_devtool.dart` are public. Internal implementation
files such as the root menu/theme/info widgets are not an integration API.
Existing public MobileDevTool names remain compatibility aliases/types in 1.x;
see [the name mapping](../docs/sdk-api-naming.md).

## Production boundary

Production integrations requiring no DevTool source/dependency must omit this
package, its imports, wrappers and assets entirely. A disabled controller only
disables logging; it does not remove a dependency.

Refresh/load-more belongs to `mobile_ui_kit` (`ui.RefreshView`,
`ui.RefreshScope`), also re-exported by `mobile_sdk`. The deprecated DevTool
refresh names are retained only for migration.

Distribution remains Git-based (`publish_to: none`). Minimum supported SDK:
Flutter 3.44.6 / Dart 3.12.2.
