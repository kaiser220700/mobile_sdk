# mobile_fuzz

Experimental 0.1.0-dev.0, opt-in non-production crash exploration. Independent of
DevTool and the production SDK. Import with `as fuzz`.

```dart
import 'package:mobile_fuzz/mobile_fuzz.dart' as fuzz;

final history = fuzz.SessionLog();
final runner = fuzz.Runner(log: history);
```

Start with `RunConfig` / `Preset`, mount `RunnerOverlay` when needed, and stop
the runner before disposing its SessionLog. Wrap tool UI in ExcludeFromFuzzTap.
Network monitoring is an optional host-owned snapshot reader returning
NetworkFailure(id, message); it does not require a DevTool controller.
Use stable IDs, and keep the reader cheap and side-effect-free.

The runner activates Flutter Semantics actions and occasionally scrolls. It
does not simulate touch gestures or interact with native pickers. See
`../example/lib/developer_tools.dart` for composition and
`../docs/migration-1.0.0.md` for migration.
