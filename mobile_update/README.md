# mobile_update

## Public API naming (candidate/development)

Import with `as updates` and use the concise names documented in the
[SDK API naming guide](../docs/sdk-api-naming.md). Existing names remain
available for migration; runtime behavior and constructor parameters are unchanged.

```dart
import 'package:mobile_update/mobile_update.dart' as updates;
```

Framework-agnostic update policy SDK for Flutter apps.

The package owns version parsing, force/soft decision logic, and the
config/version loading orchestration. The host app supplies its own remote
config adapter, app-version adapter, update dialog, localization, and store
launcher.

The JSON contract uses `store_url`.

It intentionally has no Firebase, Riverpod, `package_info_plus`, or UI
dependency so multiple apps can reuse it with different infrastructure.

```dart
final decision = const updates.UpdatePolicy().evaluate(
  currentVersion: '1.0.0',
  config: const updates.UpdateConfig.disabled(),
);
```

Use `updates.UpdateChecker` to coordinate a host-supplied config source and
version loader. Policy classes do not launch dialogs or stores themselves.
`updates.AppVersion` retains the existing numeric version parser.
