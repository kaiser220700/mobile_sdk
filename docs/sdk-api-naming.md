# Public API naming across SDK packages

Status: stable API in 1.0.0. Package names and existing public names remain
available. New names are type aliases sharing the same implementation, state,
controllers and static methods. They do not introduce duplicate services.

## Conventions

- Import packages with a module alias: `ui`, `core`, `app`, `updates`,
  `firebase`, `remote`, `dev`. These aliases are caller choices, not API.
- Remove product prefixes that do not describe a responsibility.
- Keep domain terms where they distinguish contracts: `AppConfig` configures
  app composition, `UpdateConfig` configures update policy, `ConfigKey` describes
  a typed setting. Do not shorten these all to an ambiguous `Config`.
- Keep already clear names such as `TelemetryEvent`, `ConfigSnapshot`,
  `ConfigSource` and `AppEnvironment`.
- A source loads configuration, a transport talks to a provider, a schema
  validates values, a policy makes a decision, and a checker coordinates I/O.
- Compatibility names are retained, supported throughout 1.x.
  Constructor parameters, defaults, ownership and runtime behavior are unchanged.

The [UI naming guide](ui-api-naming.md) covers UI classes and the additive
button `child` support. Use import aliases to avoid collisions with Flutter
and provider SDKs, including the native `RemoteConfigSettings`.

## Responsibilities and boundaries

| Package | Recommended API | Responsibility |
| --- | --- | --- |
| mobile_app_base | `app.AppShell`, `app.AppConfig` | Flutter app wiring and environment; host retains business logic |
| mobile_sdk_core | `core.ConfigSchema`, `core.ConfigKey` | Provider-independent validation and typed values; schema is also usable offline |
| mobile_update | `updates.UpdateChecker`, `updates.UpdatePolicy` | Checker loads inputs; policy decides whether to prompt |
| mobile_sdk_firebase_core | `firebase.Bootstrap`, `firebase.Runtime` | Start selected adapters and dispose their lifecycle; host initializes native Firebase |
| mobile_sdk_firebase_remote_config | `remote.Source`, `remote.Transport` | Source validates snapshots; transport handles provider I/O |
| mobile_devtool | `dev.Controller`, `dev.ToolsOverlay`, `dev.Launcher` | Non-production logging, tool UI and launcher |
| mobile_devtool | `dev.Recorder` | Optional static recording facade; dependency injection may use Controller directly |

`updates.AppVersion` is the existing numeric major/minor/patch parser, not a
new full SemVer implementation. `dev.KeyValueTable` renders data;
`ui.KeyValue` is a production UI component. Refresh/load-more remains owned
by UI (`ui.RefreshView`), rather than gaining another DevTool alias.

The umbrella `mobile_sdk` exports app, core, UI and update APIs. Firebase
adapters and DevTool remain explicit opt-ins. Generic names like
`firebase.Runtime` and `remote.Source` stay in their dedicated packages.
Implementation imports and non-exported DevTool experiments remain internal.

## Examples

```dart
import 'package:mobile_sdk_core/mobile_sdk_core.dart' as core;
import 'package:mobile_update/mobile_update.dart' as updates;
import 'package:mobile_devtool/mobile_devtool.dart' as dev;

final schema = core.ConfigSchema([
  core.ConfigKey.bool('maintenance', defaultValue: false),
]);
final decision = const updates.UpdatePolicy().evaluate(
  currentVersion: '1.0.0',
  config: const updates.UpdateConfig.disabled(),
);
final logs = dev.Controller();
logs.recordTrace('Host initialized');
// Dispose logs when its owner is destroyed.
logs.dispose();
```

Firebase and Remote Config wiring is shown in their package READMEs. Do not
include the DevTool import in a production integration. Workspace tests and
both DevTool/SDK examples use the new names through the public barrels.

## Migration mapping


### mobile_sdk_core

| Existing name | New public name |
| --- | --- |
| `MobileRemoteConfigSchema` | `core.ConfigSchema` |

### mobile_app_base

| Existing name | New public name |
| --- | --- |
| `MobileAppShell` | `app.AppShell` |

### mobile_update

| Existing name | New public name |
| --- | --- |
| `MobileAppVersionLoader` | `updates.AppVersionLoader` |
| `MobileUpdateCheckResult` | `updates.UpdateCheckResult` |
| `MobileUpdateChecker` | `updates.UpdateChecker` |
| `MobileUpdateConfig` | `updates.UpdateConfig` |
| `MobileUpdateConfigSource` | `updates.UpdateConfigSource` |
| `MobileUpdateDecision` | `updates.UpdateDecision` |
| `MobileUpdatePolicy` | `updates.UpdatePolicy` |
| `MobileUpdateRequirement` | `updates.UpdateRequirement` |
| `MobileVersion` | `updates.AppVersion` |

### mobile_sdk_firebase_core

| Existing name | New public name |
| --- | --- |
| `MobileFirebase` | `firebase.Bootstrap` |
| `MobileFirebaseAdapter` | `firebase.Adapter` |
| `MobileFirebaseModule` | `firebase.Module` |
| `MobileFirebasePrivacy` | `firebase.Privacy` |
| `MobileFirebaseRuntime` | `firebase.Runtime` |

### mobile_sdk_firebase_remote_config

| Existing name | New public name |
| --- | --- |
| `FirebaseRemoteConfigTransport` | `remote.FirebaseTransport` |
| `InMemoryRemoteConfigTransport` | `remote.InMemoryTransport` |
| `MobileRemoteConfigSettings` | `remote.Settings` |
| `MobileRemoteConfigSource` | `remote.Source` |
| `RemoteConfigTransport` | `remote.Transport` |

### mobile_devtool

| Existing name | New public name |
| --- | --- |
| `MobileDevTool` | `dev.Recorder` |
| `MobileDevToolBubble` | `dev.Launcher` |
| `MobileDevToolBubbleIdle` | `dev.LauncherIdleState` |
| `MobileDevToolBubblePosition` | `dev.LauncherPosition` |
| `MobileDevToolBuiltInIds` | `dev.BuiltInIds` |
| `MobileDevToolChrome` | `dev.ToolsOverlay` |
| `MobileDevToolConfiguration` | `dev.Configuration` |
| `MobileDevToolController` | `dev.Controller` |
| `MobileDevToolCurlBuilder` | `dev.CurlBuilder` |
| `MobileDevToolFeatureFlag` | `dev.FeatureFlag` |
| `MobileDevToolHostAction` | `dev.HostAction` |
| `MobileDevToolJsonFormatter` | `dev.JsonFormatter` |
| `MobileDevToolKvRow` | `dev.KeyValueRow` |
| `MobileDevToolKvTable` | `dev.KeyValueTable` |
| `MobileDevToolMenu` | `dev.Menu` |
| `MobileDevToolMenuItem` | `dev.MenuItem` |
| `MobileDevToolNetworkDetailOpener` | `dev.NetworkDetailOpener` |
| `MobileDevToolNetworkEntry` | `dev.NetworkEntry` |
| `MobileDevToolNetworkKind` | `dev.NetworkKind` |
| `MobileDevToolNetworkLogDetail` | `dev.NetworkLogDetail` |
| `MobileDevToolNetworkLogPanel` | `dev.NetworkLogPanel` |
| `MobileDevToolNetworkRequest` | `dev.NetworkRequest` |
| `MobileDevToolNetworkStatus` | `dev.NetworkStatus` |
| `MobileDevToolNetworkStatusFilterStyle` | `dev.NetworkStatusFilterStyle` |
| `MobileDevToolPanel` | `dev.Panel` |
| `MobileDevToolThemeBuilder` | `dev.ThemeBuilder` |
| `MobileDevToolTraceEntry` | `dev.TraceEntry` |
| `MobileDevToolTraceLogPanel` | `dev.TraceLogPanel` |

Optional tool extraction and host composition are specified in [1.0.0 migration](migration-1.0.0.md).
