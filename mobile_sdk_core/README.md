# mobile_sdk_core

## Public API naming (candidate/development)

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

### Vietnamese dong in words

Import this optional pure Dart entrypoint when presenting whole dong amounts:

```dart
import 'package:mobile_sdk_core/money.dart';

final label = vietnameseDongInWords(1005);
// một nghìn không trăm lẻ năm đồng
final large = vietnameseDongBigIntInWords(BigInt.parse('1000000000000000000000'));
```

Amounts are integer dong, not cents or floating-point values. Negative amounts
use “âm”; zero is “không đồng”. Output is lowercase and uses “lẻ”, “nghìn”,
“mốt” and “lăm”. This converts amounts to text; it does not provide speech audio
or perform financial calculations.

An optional local AOT microbenchmark lives in `benchmark/money_benchmark.dart`;
compile it with `dart compile exe` before interpreting timings. It measures
conversion throughput, not UI frame time or application memory leaks.
