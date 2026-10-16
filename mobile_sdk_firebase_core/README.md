# mobile_sdk_firebase_core

## Public API naming (1.0.0)

Import with `as firebase` and use the concise names documented in the
[SDK API naming guide](../docs/sdk-api-naming.md). Existing names remain
available for migration; runtime behavior and constructor parameters are unchanged.

```dart
import 'package:mobile_sdk_firebase_core/mobile_sdk_firebase_core.dart' as firebase;
```

Lifecycle for host-selected Firebase adapters. The host initializes Firebase
for its flavor, then calls `firebase.Bootstrap.initialize` with the selected module
set and matching adapters. This package imports only `firebase_core`, so apps
using one adapter do not pull in all Firebase plugins. Dispose the returned
runtime during shutdown or test teardown.
