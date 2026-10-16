# mobile_sdk_firebase_remote_config

## Public API naming (candidate/development)

Import with `as remote` and use the concise names documented in the
[SDK API naming guide](../docs/sdk-api-naming.md). Existing names remain
available for migration; runtime behavior and constructor parameters are unchanged.

```dart
import 'package:mobile_sdk_firebase_remote_config/mobile_sdk_firebase_remote_config.dart' as remote;
```

Typed Remote Config adapter. The host app initializes Firebase and passes its
`FirebaseApp`; this package owns no project identifiers or native config files.

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_sdk_firebase_core/mobile_sdk_firebase_core.dart' as firebase;
import 'package:mobile_sdk_firebase_remote_config/mobile_sdk_firebase_remote_config.dart' as remote;

final schema = remote.ConfigSchema([
  remote.ConfigKey.bool('maintenance_enabled', defaultValue: false),
  remote.ConfigKey.int('refresh_seconds', defaultValue: 60, min: 15, max: 3600),
]);
final source = remote.Source(
  schema: schema,
  settings: const remote.Settings(
    fetchTimeout: Duration(seconds: 10),
    minimumFetchInterval: Duration(hours: 1),
  ),
  transport: remote.FirebaseTransport(Firebase.app()),
);
final runtime = await firebase.Bootstrap.initialize(
  app: Firebase.app(),
  modules: {firebase.Module.remoteConfig},
  privacy: const firebase.Privacy(),
  adapters: [source],
);
final snapshot = await source.load();
final enabled = snapshot.require(schema.key<bool>('maintenance_enabled'));
// On shutdown: await runtime.dispose();
```

Import `firebase_core` and `mobile_sdk_firebase_core` in the host app as well.
The adapter validates a complete candidate and keeps the last good app-facing
snapshot after a fetch or validation failure. Firebase's native cache is used
for offline reads. Firebase's `fetchAndActivate` activates raw values before
app-level validation; do not use this adapter for secrets or authorization.
