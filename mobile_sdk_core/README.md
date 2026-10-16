# mobile_sdk_core

## Public API naming (1.0.0)

Import with `as core` and use the concise names documented in the
[SDK API naming guide](../docs/sdk-api-naming.md). Existing names remain
available for migration; runtime behavior and constructor parameters are unchanged.

```dart
import 'package:mobile_sdk_core/mobile_sdk_core.dart' as core;
```

Firebase-independent typed config, telemetry contracts, and in-memory fakes.
Import this package when building an adapter without pulling in FlutterFire.

```dart
final schema = core.ConfigSchema([
  core.ConfigKey.bool('maintenance', defaultValue: false),
]);
final snapshot = schema.defaults();
```
