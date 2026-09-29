import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:core' as core;

/// Origin of a value exposed to the application.
enum ConfigValueSource { defaultValue, cache, remote }

/// A typed, validated configuration key with a value compiled into the app.
final class ConfigKey<T> {
  ConfigKey.custom(
    this.name, {
    required this.defaultValue,
    required T Function(String) decoder,
    String? encodedDefault,
  }) : _decoder = decoder,
       _encodedDefault = encodedDefault {
    if (!RegExp(r'^[a-z][a-z0-9_]{0,63}$').hasMatch(name)) {
      throw ArgumentError.value(
        name,
        'name',
        'Use lowercase letters, digits and underscores',
      );
    }
  }

  static ConfigKey<core.bool> bool(
    String name, {
    required core.bool defaultValue,
  }) => ConfigKey<core.bool>.custom(
    name,
    defaultValue: defaultValue,
    decoder: (raw) {
      if (raw == 'true') return true;
      if (raw == 'false') return false;
      throw const FormatException('Expected true or false');
    },
  );

  static ConfigKey<core.int> int(
    String name, {
    required core.int defaultValue,
    core.int? min,
    core.int? max,
  }) {
    if ((min != null && defaultValue < min) ||
        (max != null && defaultValue > max)) {
      throw ArgumentError.value(
        defaultValue,
        'defaultValue',
        'Outside declared range',
      );
    }
    return ConfigKey<core.int>.custom(
      name,
      defaultValue: defaultValue,
      decoder: (raw) {
        final value = core.int.tryParse(raw);
        if (value == null ||
            (min != null && value < min) ||
            (max != null && value > max)) {
          throw const FormatException('Invalid integer or range');
        }
        return value;
      },
    );
  }

  static ConfigKey<core.double> double(
    String name, {
    required core.double defaultValue,
    core.double? min,
    core.double? max,
  }) {
    if (!defaultValue.isFinite ||
        (min != null && defaultValue < min) ||
        (max != null && defaultValue > max)) {
      throw ArgumentError.value(
        defaultValue,
        'defaultValue',
        'Outside declared range',
      );
    }
    return ConfigKey<core.double>.custom(
      name,
      defaultValue: defaultValue,
      decoder: (raw) {
        final value = core.double.tryParse(raw);
        if (value == null ||
            !value.isFinite ||
            (min != null && value < min) ||
            (max != null && value > max)) {
          throw const FormatException('Invalid double or range');
        }
        return value;
      },
    );
  }

  static ConfigKey<String> string(
    String name, {
    required String defaultValue,
    core.int? maxLength,
  }) {
    if (maxLength != null && defaultValue.length > maxLength) {
      throw ArgumentError.value(defaultValue, 'defaultValue', 'Too long');
    }
    return ConfigKey<String>.custom(
      name,
      defaultValue: defaultValue,
      decoder: (raw) {
        if (maxLength != null && raw.length > maxLength)
          throw const FormatException('String too long');
        return raw;
      },
    );
  }

  static ConfigKey<E> enumValue<E extends Enum>(
    String name, {
    required E defaultValue,
    required List<E> values,
  }) => ConfigKey<E>.custom(
    name,
    defaultValue: defaultValue,
    decoder: (raw) {
      for (final value in values) {
        if (value.name == raw) return value;
      }
      throw const FormatException('Unknown enum value');
    },
  );

  static ConfigKey<T> json<T>(
    String name, {
    required T defaultValue,
    required T Function(Object?) decoder,
    Object? defaultJson,
  }) => ConfigKey<T>.custom(
    name,
    defaultValue: defaultValue,
    encodedDefault: jsonEncode(defaultJson ?? defaultValue),
    decoder: (raw) => decoder(jsonDecode(raw)),
  );

  final String name;
  final T defaultValue;
  final T Function(String) _decoder;
  final String? _encodedDefault;

  T decode(String raw) => _decoder(raw);

  String encodeDefault() {
    if (_encodedDefault case final encoded?) return encoded;
    final value = defaultValue;
    if (value is Enum) return value.name;
    if (value is String) return value;
    return jsonEncode(value);
  }
}

/// Immutable values from one successful schema validation.
final class ConfigSnapshot {
  ConfigSnapshot._(Map<String, Object?> values, this.source, this.loadedAt)
    : _values = Map.unmodifiable(values);

  final Map<String, Object?> _values;
  final ConfigValueSource source;
  final DateTime loadedAt;

  T require<T>(ConfigKey<T> key) {
    if (!_values.containsKey(key.name))
      throw StateError('Unknown config key: ${key.name}');
    return _values[key.name] as T;
  }
}

/// Validates an entire candidate before exposing any of its values.
final class MobileRemoteConfigSchema {
  MobileRemoteConfigSchema(Iterable<ConfigKey<dynamic>> keys)
    : _keys = List.unmodifiable(keys) {
    if (_keys.isEmpty) throw ArgumentError('Schema must have at least one key');
    if (_keys.map((key) => key.name).toSet().length != _keys.length) {
      throw ArgumentError('Duplicate config key');
    }
  }

  final List<ConfigKey<dynamic>> _keys;
  Iterable<String> get names => _keys.map((key) => key.name);
  Map<String, String> get encodedDefaults => Map.unmodifiable({
    for (final key in _keys) key.name: key.encodeDefault(),
  });

  ConfigKey<T> key<T>(String name) {
    for (final key in _keys) {
      if (key.name == name && key is ConfigKey<T>) return key;
    }
    throw ArgumentError.value(name, 'name', 'Unknown key or incorrect type');
  }

  ConfigSnapshot defaults() =>
      decode(const {}, source: ConfigValueSource.defaultValue);

  ConfigSnapshot decode(
    Map<String, String> raw, {
    required ConfigValueSource source,
  }) {
    final result = <String, Object?>{};
    for (final key in _keys) {
      final encoded = raw[key.name];
      try {
        result[key.name] = encoded == null
            ? key.defaultValue
            : key.decode(encoded);
      } catch (_) {
        throw FormatException('Invalid config key: ${key.name}');
      }
    }
    return ConfigSnapshot._(result, source, DateTime.now().toUtc());
  }
}

abstract interface class ConfigSource {
  Future<ConfigSnapshot> load();
  Stream<ConfigSnapshot> get changes;
}

/// Mutable test source with the same contract as a remote adapter.
final class InMemoryConfigSource implements ConfigSource {
  InMemoryConfigSource(this.schema) : _snapshot = schema.defaults();

  final MobileRemoteConfigSchema schema;
  final StreamController<ConfigSnapshot> _controller =
      StreamController.broadcast();
  ConfigSnapshot _snapshot;

  @override
  Future<ConfigSnapshot> load() async => _snapshot;

  @override
  Stream<ConfigSnapshot> get changes => _controller.stream;

  void publish(Map<String, String> values) {
    _snapshot = schema.decode(values, source: ConfigValueSource.remote);
    _controller.add(_snapshot);
  }

  Future<void> dispose() => _controller.close();
}
