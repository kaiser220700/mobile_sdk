import 'dart:convert';
import 'dart:io';

import 'package:mobile_sdk_core/money.dart';

/// Run an optimized local helper benchmark, not a UI frame benchmark:
/// dart compile exe benchmark/money_benchmark.dart -o /tmp/sdk-money-benchmark
void main() {
  const amounts = [0, 15, 21, 105, 1005, 1000001, -25000, 1234567890123];
  const iterations = 20000;
  const samples = 9;
  var checksum = 0;
  for (var i = 0; i < iterations; i++) {
    checksum += vietnameseDongInWords(amounts[i % amounts.length]).length;
  }
  final measurements = <double>[];
  for (var sample = 0; sample < samples; sample++) {
    final watch = Stopwatch()..start();
    for (var i = 0; i < iterations; i++) {
      checksum += vietnameseDongInWords(amounts[i % amounts.length]).length;
    }
    watch.stop();
    measurements.add(watch.elapsedMicroseconds / iterations);
  }
  measurements.sort();
  stdout.writeln(
    jsonEncode({
      'runtime': Platform.version,
      'os': Platform.operatingSystem,
      'iterations_per_sample': iterations,
      'samples': samples,
      'median_microseconds_per_conversion': measurements[samples ~/ 2],
      'slowest_sample_microseconds_per_conversion': measurements.last,
      'process_max_rss_bytes': ProcessInfo.maxRss,
      'checksum': checksum,
    }),
  );
}
