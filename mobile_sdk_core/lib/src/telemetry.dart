/// Primitive fields allowed in telemetry. Identifiers and sensitive values
/// must be excluded by the host application's allow-list.
final class TelemetryEvent {
  TelemetryEvent(this.name, Map<String, Object> parameters)
    : parameters = Map.unmodifiable(parameters) {
    if (!RegExp(r'^[a-z][a-z0-9_]{0,39}$').hasMatch(name)) {
      throw ArgumentError.value(name, 'name', 'Invalid event name');
    }
    for (final entry in parameters.entries) {
      if (!RegExp(r'^[a-z][a-z0-9_]{0,39}$').hasMatch(entry.key) ||
          entry.value is! String &&
              entry.value is! num &&
              entry.value is! bool) {
        throw ArgumentError.value(entry.key, 'parameters', 'Invalid field');
      }
      if (entry.value is String && (entry.value as String).length > 100) {
        throw ArgumentError.value(entry.key, 'parameters', 'Value too long');
      }
    }
  }

  final String name;
  final Map<String, Object> parameters;

  TelemetryEvent allowOnly(Set<String> allowedKeys) => TelemetryEvent(name, {
    for (final entry in parameters.entries)
      if (allowedKeys.contains(entry.key)) entry.key: entry.value,
  });
}

abstract interface class TelemetryReporter {
  Future<void> event(TelemetryEvent event);
  Future<T> trace<T>(String name, Future<T> Function() action);
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
  });
}

final class InMemoryTelemetryReporter implements TelemetryReporter {
  final List<TelemetryEvent> events = [];
  final List<Object> errors = [];

  @override
  Future<void> event(TelemetryEvent event) async => events.add(event);

  @override
  Future<T> trace<T>(String name, Future<T> Function() action) => action();

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
  }) async {
    errors.add(error);
  }
}
