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
