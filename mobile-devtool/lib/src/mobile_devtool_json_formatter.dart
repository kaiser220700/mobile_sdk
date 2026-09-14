import "dart:convert";

class MobileDevToolJsonFormatter {
  const MobileDevToolJsonFormatter._();

  static const _encoder = JsonEncoder.withIndent("  ");

  static String format(dynamic value, {bool omitGraphQLTypeNames = false}) {
    final normalized = _normalize(value);
    final displayValue = omitGraphQLTypeNames
        ? _omitGraphQLTypeNames(normalized)
        : normalized;
    try {
      if (displayValue is Map ||
          displayValue is List ||
          displayValue is num ||
          displayValue is bool ||
          displayValue == null) {
        return _encoder.convert(displayValue);
      }
    } on Object {
      // Fall back to a safe textual representation.
    }
    return displayValue.toString();
  }

  static String formatGraphQLDocument(String document) => document.replaceAll(
    RegExp(r"^[ \t]*__typename[ \t]*(\r?\n|$)", multiLine: true),
    "",
  );

  static dynamic _normalize(dynamic value) {
    if (value is! String) return value;

    final trimmed = value.trim();
    if ((trimmed.startsWith("{") && trimmed.endsWith("}")) ||
        (trimmed.startsWith("[") && trimmed.endsWith("]"))) {
      try {
        return jsonDecode(trimmed);
      } on FormatException {
        return value;
      }
    }
    return value;
  }

  static dynamic _omitGraphQLTypeNames(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.fromEntries(
        value.entries
            .where((entry) => entry.key.toString() != "__typename")
            .map(
              (entry) => MapEntry(
                entry.key.toString(),
                _omitGraphQLTypeNames(entry.value),
              ),
            ),
      );
    }
    if (value is Iterable) {
      return value.map(_omitGraphQLTypeNames).toList(growable: false);
    }
    return value;
  }
}
