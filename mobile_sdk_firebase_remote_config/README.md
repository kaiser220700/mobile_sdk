# mobile_sdk_firebase_remote_config

Typed Remote Config adapter. The host app initializes Firebase and passes its
`FirebaseApp`; this package owns no project identifiers or native config files.

```dart
final schema = MobileRemoteConfigSchema([
  ConfigKey.bool('maintenance_enabled', defaultValue: false),
  ConfigKey.int('refresh_seconds', defaultValue: 60, min: 15, max: 3600),
]);
final source = MobileRemoteConfigSource(
  schema: schema,
  settings: const MobileRemoteConfigSettings(
    fetchTimeout: Duration(seconds: 10),
    minimumFetchInterval: Duration(hours: 1),
  ),
  transport: FirebaseRemoteConfigTransport(Firebase.app()),
);
final runtime = await MobileFirebase.initialize(
  app: Firebase.app(),
  modules: {MobileFirebaseModule.remoteConfig},
  privacy: const MobileFirebasePrivacy(),
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
