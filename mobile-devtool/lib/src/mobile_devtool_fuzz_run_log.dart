import "package:flutter/foundation.dart";

enum MobileDevToolFuzzRunStatus {
  running,
  paused,
  stoppedByUser,
  stoppedStuck,
  stoppedNetworkError,
  stoppedTimeLimit,
}

class MobileDevToolFuzzRunStep {
  const MobileDevToolFuzzRunStep({
    required this.timestamp,
    required this.message,
  });

  final DateTime timestamp;
  final String message;
}

/// One Fuzz Tap run, from `start()` to stop — [MobileDevToolFuzzRunLog] keeps
/// the most recent sessions in memory only (no persistence across restarts).
class MobileDevToolFuzzRunSession {
  const MobileDevToolFuzzRunSession({
    required this.id,
    required this.configLabel,
    required this.startedAt,
    required this.status,
    this.endedAt,
    this.steps = const [],
    this.tapCount = 0,
    this.errorCount = 0,
    this.elapsedOffset = Duration.zero,
  });

  final int id;
  final String configLabel;
  final DateTime startedAt;
  final DateTime? endedAt;
  final MobileDevToolFuzzRunStatus status;
  final List<MobileDevToolFuzzRunStep> steps;
  final int tapCount;
  final int errorCount;
  final Duration elapsedOffset;

  bool get isRunning => endedAt == null;
  bool get isPaused => isRunning && status == MobileDevToolFuzzRunStatus.paused;

  Duration get elapsed {
    final value =
        (endedAt ?? DateTime.now()).difference(startedAt) + elapsedOffset;
    return value.isNegative ? Duration.zero : value;
  }

  String get stopReasonLabel => switch (status) {
    MobileDevToolFuzzRunStatus.running => "Đang chạy",
    MobileDevToolFuzzRunStatus.paused => "Đã tạm dừng",
    MobileDevToolFuzzRunStatus.stoppedByUser => "Dừng theo yêu cầu người dùng",
    MobileDevToolFuzzRunStatus.stoppedStuck =>
      "Dừng — không còn widget bấm được",
    MobileDevToolFuzzRunStatus.stoppedNetworkError => "Dừng — gặp lỗi network",
    MobileDevToolFuzzRunStatus.stoppedTimeLimit =>
      "Dừng — hết thời lượng phiên",
  };

  MobileDevToolFuzzRunSession _copyWith({
    DateTime? endedAt,
    MobileDevToolFuzzRunStatus? status,
    List<MobileDevToolFuzzRunStep>? steps,
    int? tapCount,
    int? errorCount,
    Duration? elapsedOffset,
  }) => MobileDevToolFuzzRunSession(
    id: id,
    configLabel: configLabel,
    startedAt: startedAt,
    endedAt: endedAt ?? this.endedAt,
    status: status ?? this.status,
    steps: steps ?? this.steps,
    tapCount: tapCount ?? this.tapCount,
    errorCount: errorCount ?? this.errorCount,
    elapsedOffset: elapsedOffset ?? this.elapsedOffset,
  );
}

/// In-memory history of Fuzz Tap runs, grouped by session.
class MobileDevToolFuzzRunLog extends ChangeNotifier {
  static const _maxSteps = 50;
  static const _maxSessions = 10;

  int _nextId = 0;
  List<MobileDevToolFuzzRunSession> _sessions = const [];
  int? _currentSessionId;

  List<MobileDevToolFuzzRunSession> get sessions =>
      List.unmodifiable(_sessions);

  bool get isRunning => currentSession?.isRunning ?? false;

  MobileDevToolFuzzRunSession? get currentSession {
    final currentId = _currentSessionId;
    if (currentId == null) return null;
    for (final session in _sessions) {
      if (session.id == currentId) return session;
    }
    return null;
  }

  void start(String configLabel, String startMessage) {
    if (isRunning) return;
    final session = MobileDevToolFuzzRunSession(
      id: _nextId++,
      configLabel: configLabel,
      startedAt: DateTime.now(),
      status: MobileDevToolFuzzRunStatus.running,
      steps: [
        MobileDevToolFuzzRunStep(
          timestamp: DateTime.now(),
          message: startMessage,
        ),
      ],
    );
    _currentSessionId = session.id;
    final next = [session, ..._sessions];
    _sessions =
        next.length > _maxSessions ? next.sublist(0, _maxSessions) : next;
    notifyListeners();
  }

  void log(String message) =>
      _updateCurrent((s) => s._copyWith(steps: _pushStep(s.steps, message)));

  void logTap(String message) => _updateCurrent(
    (s) => s._copyWith(
      steps: _pushStep(s.steps, message),
      tapCount: s.tapCount + 1,
    ),
  );

  void logError(String message) => _updateCurrent(
    (s) => s._copyWith(
      steps: _pushStep(s.steps, message),
      errorCount: s.errorCount + 1,
    ),
  );

  void pause() => _updateCurrent(
    (s) =>
        s.isRunning
            ? s._copyWith(status: MobileDevToolFuzzRunStatus.paused)
            : s,
  );

  void resume() => _updateCurrent(
    (s) =>
        s.isRunning
            ? s._copyWith(status: MobileDevToolFuzzRunStatus.running)
            : s,
  );

  void adjustElapsed(Duration adjustment) => _updateCurrent((s) {
    final next = s.elapsedOffset + adjustment;
    return s._copyWith(elapsedOffset: next.isNegative ? Duration.zero : next);
  });

  void stopByUser() => _stop(
    MobileDevToolFuzzRunStatus.stoppedByUser,
    "Đã dừng theo yêu cầu người dùng",
  );

  void stopStuck(String reason) =>
      _stop(MobileDevToolFuzzRunStatus.stoppedStuck, "Dừng: $reason");

  void stopNetworkError(String reason) => _stop(
    MobileDevToolFuzzRunStatus.stoppedNetworkError,
    "Dừng: lỗi network — $reason",
  );

  void stopTimeLimit(String reason) =>
      _stop(MobileDevToolFuzzRunStatus.stoppedTimeLimit, "Dừng: $reason");

  void clearHistory() {
    _sessions = const [];
    _currentSessionId = null;
    notifyListeners();
  }

  /// Drops only the session currently shown by the live Fuzz Tap overlay.
  /// Older completed sessions remain available in the Fuzz Tap Log panel.
  void resetCurrentSession() {
    if (_currentSessionId == null) return;
    _currentSessionId = null;
    notifyListeners();
  }

  void _stop(MobileDevToolFuzzRunStatus status, String message) {
    if (!isRunning) return;
    _updateCurrent(
      (s) => s._copyWith(
        steps: _pushStep(s.steps, message),
        status: status,
        endedAt: DateTime.now(),
      ),
    );
  }

  void _updateCurrent(
    MobileDevToolFuzzRunSession Function(MobileDevToolFuzzRunSession session)
    update,
  ) {
    if (_sessions.isEmpty) return;
    _sessions = [update(_sessions.first), ..._sessions.skip(1)];
    notifyListeners();
  }

  List<MobileDevToolFuzzRunStep> _pushStep(
    List<MobileDevToolFuzzRunStep> steps,
    String message,
  ) {
    final next = [
      MobileDevToolFuzzRunStep(timestamp: DateTime.now(), message: message),
      ...steps,
    ];
    return next.length > _maxSteps ? next.sublist(0, _maxSteps) : next;
  }
}
