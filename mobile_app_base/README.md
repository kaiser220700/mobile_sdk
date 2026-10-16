# mobile_app_base

## Public API naming (1.0.0)

Import with `as app` and use the concise names documented in the
[SDK API naming guide](../docs/sdk-api-naming.md). Existing names remain
available for migration; runtime behavior and constructor parameters are unchanged.

```dart
import 'package:mobile_app_base/mobile_app_base.dart' as app;
```

Shared app-host wiring used by both SDK examples in this repository.

The package owns only composition concerns:

- `app.AppConfig`: environment and host capabilities.
- `app.AppShell`: `MaterialApp`, theme and root navigator wiring.

Business features, routing policy, authentication, storage and remote config
remain owned by the consuming app.
