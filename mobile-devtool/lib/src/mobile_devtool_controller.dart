import "dart:convert";

import "package:flutter/foundation.dart";

enum MobileDevToolNetworkKind { graphql, rest }

enum MobileDevToolNetworkStatus { pending, success, error }

class MobileDevToolNetworkRequest {
  const MobileDevToolNetworkRequest({
    required this.label,
    required this.endpoint,
    required this.method,
    this.kind = MobileDevToolNetworkKind.rest,
    this.request,
    this.document,
    this.isExternal = false,
    this.replayUrl,
  });

  final String label;
  final String endpoint;
  final String method;
  final MobileDevToolNetworkKind kind;
  final Map<String, dynamic>? request;
  final String? document;

  /// External storage requests cannot be safely replayed after their signed
  /// query parameters have been redacted.
  final bool isExternal;

  /// Full, short-lived external URL retained only in the in-memory log so its
  /// cURL command can be copied. It is never rendered.
  final String? replayUrl;
}

class MobileDevToolNetworkEntry {
  MobileDevToolNetworkEntry({required this.id, required this.request})
    : startedAt = DateTime.now();

  final String id;
  final MobileDevToolNetworkRequest request;
  final DateTime startedAt;
  MobileDevToolNetworkStatus status = MobileDevToolNetworkStatus.pending;
  dynamic response;
  Object? error;
  int? statusCode;
  Duration? duration;

  /// Builds a runnable `curl` command reproducing this call. Pass
  /// [bearerToken] (read from the host's token storage at copy time — NOT
  /// stored in the entry itself) so the curl carries a currently-valid
  /// `Authorization` header instead of failing with 401.
  String toCurl({
    required String graphQlUrl,
    required String restBaseUrl,
    String? bearerToken,
  }) {
    if (request.isExternal) {
      final contentType = request.request?["contentType"]?.toString();
      final fileName = request.request?["fileName"]?.toString() ?? "upload.bin";
      final contentTypeFlag = contentType == null
          ? ""
          : "--header ${_shellQuote('Content-Type: $contentType')} ";
      return "curl --location --request ${request.method} ${_shellQuote(request.replayUrl ?? request.endpoint)} "
              "$contentTypeFlag--upload-file ${_shellQuote('<path-to/$fileName>')}"
          .trim();
    }

    final authFlag = bearerToken == null
        ? ""
        : "--header ${_shellQuote('Authorization: Bearer $bearerToken')} ";

    if (request.kind == MobileDevToolNetworkKind.graphql) {
      final variables = (request.request?["variables"] as Map?) ?? const {};
      final body = jsonEncode({
        "operationName": request.endpoint,
        "variables": variables,
        "query": request.document ?? "# document not captured",
      });
      return "curl --location --request POST ${_shellQuote(graphQlUrl)} "
              "--header 'Content-Type: application/json' $authFlag"
              "--data-raw ${_shellQuote(body)}"
          .trim();
    }

    final headers = (request.request?["headers"] as Map?) ?? const {};
    final headerFlags = headers.entries
        .map((e) => "--header ${_shellQuote('${e.key}: ${e.value}')}")
        .join(" ");
    final query = (request.request?["query"] as Map?) ?? const {};
    final queryString = query.isEmpty
        ? ""
        : '?${query.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    final body = request.request?["body"];
    final bodyFlag = body == null
        ? ""
        : "--data-raw ${_shellQuote(jsonEncode(body))}";

    return "curl --location --request ${request.method} ${_shellQuote('$restBaseUrl${request.endpoint}$queryString')} "
            "$authFlag$headerFlags $bodyFlag"
        .trim();
  }
}

/// Quotes a value for a POSIX-compatible shell command — escaping single
/// quotes keeps a copied body containing text like `O'Brien` runnable instead
/// of being interpreted as separate shell tokens.
String _shellQuote(String value) => "'${value.replaceAll("'", "'\"'\"'")}'";

class MobileDevToolTraceEntry {
  MobileDevToolTraceEntry({required this.id, required this.message})
    : timestamp = DateTime.now();

  final String id;
  final DateTime timestamp;
  final String message;
}

class MobileDevToolController extends ChangeNotifier {
  MobileDevToolController({this.maxEntries = 200}) : _disabled = false;

  /// A controller that discards every call — use it as the host binding in
  /// production builds so business code (network/trace instrumentation) can
  /// always depend on a live controller without branching on build flavor.
  MobileDevToolController.disabled() : maxEntries = 0, _disabled = true;

  final int maxEntries;
  final bool _disabled;
  final _network = <String, MobileDevToolNetworkEntry>{};
  final _traceEntries = <MobileDevToolTraceEntry>[];
  int _sequence = 0;
  int _traceSequence = 0;

  List<MobileDevToolNetworkEntry> get networkEntries =>
      List.unmodifiable(_network.values.toList().reversed);

  List<MobileDevToolTraceEntry> get traceEntries =>
      List.unmodifiable(_traceEntries.reversed);

  /// Message-only view of [traceEntries] — kept for callers that only need
  /// the raw text (e.g. counting entries).
  List<String> get traces =>
      List.unmodifiable(_traceEntries.map((e) => e.message));

  String startNetwork(MobileDevToolNetworkRequest request) {
    if (_disabled) return "";
    final id = "network-${++_sequence}";
    _network[id] = MobileDevToolNetworkEntry(id: id, request: request);
    while (_network.length > maxEntries) {
      _network.remove(_network.keys.first);
    }
    notifyListeners();
    return id;
  }

  void completeNetwork(
    String id, {
    dynamic response,
    int? statusCode,
    Duration? duration,
  }) {
    final entry = _network[id];
    if (entry == null) return;
    entry.status = MobileDevToolNetworkStatus.success;
    entry.response = response;
    entry.statusCode = statusCode;
    entry.duration = duration;
    notifyListeners();
  }

  void failNetwork(
    String id, {
    required Object error,
    dynamic response,
    int? statusCode,
    Duration? duration,
  }) {
    final entry = _network[id];
    if (entry == null) return;
    entry.status = MobileDevToolNetworkStatus.error;
    entry.error = error;
    entry.response = response;
    entry.statusCode = statusCode;
    entry.duration = duration;
    notifyListeners();
  }

  void recordTrace(String message) {
    if (_disabled) return;
    _traceEntries.add(
      MobileDevToolTraceEntry(
        id: "trace-${++_traceSequence}",
        message: message,
      ),
    );
    while (_traceEntries.length > maxEntries) {
      _traceEntries.removeAt(0);
    }
    notifyListeners();
  }

  void clear() {
    _network.clear();
    _traceEntries.clear();
    notifyListeners();
  }

  void clearTraces() {
    _traceEntries.clear();
    notifyListeners();
  }

  void clearNetwork() {
    _network.clear();
    notifyListeners();
  }

  void clearNetworkKind(MobileDevToolNetworkKind kind) {
    _network.removeWhere((_, entry) => entry.request.kind == kind);
    notifyListeners();
  }
}
