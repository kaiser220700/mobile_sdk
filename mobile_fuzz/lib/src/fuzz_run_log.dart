import "package:flutter/foundation.dart";

enum SessionStatus {
  running,
  paused,
  stoppedByUser,
  stoppedStuck,
  stoppedNetworkError,
  stoppedTimeLimit,
}

class Step {
  const Step({required this.timestamp, required this.message});

  final DateTime timestamp;
  final String message;
}

/// One Fuzz Tap run, from `start()` to stop — [SessionLog] keeps
/// the most recent sessions in memory only (no persistence across restarts).
class Session {
  const Session({
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
  final SessionStatus status;
  final List<Step> steps;
  final int tapCount;
  final int errorCount;
  final Duration elapsedOffset;

  bool get isRunning => endedAt == null;
  bool get isPaused => isRunning && status == SessionStatus.paused;

  Duration get elapsed {
    final value =
        (endedAt ?? DateTime.now()).difference(startedAt) + elapsedOffset;
    return value.isNegative ? Duration.zero : value;
  }

  String get stopReasonLabel => switch (status) {
    SessionStatus.running => "Đang chạy",
    SessionStatus.paused => "Đã tạm dừng",
    SessionStatus.stoppedByUser => "Dừng theo yêu cầu người dùng",
    SessionStatus.stoppedStuck => "Dừng — không còn widget bấm được",
    SessionStatus.stoppedNetworkError => "Dừng — gặp lỗi network",
    SessionStatus.stoppedTimeLimit => "Dừng — hết thời lượng phiên",
  };

  Session _copyWith({
    DateTime? endedAt,
    SessionStatus? status,
    List<Step>? steps,
    int? tapCount,
    int? errorCount,
    Duration? elapsedOffset,
  }) => Session(
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
class SessionLog extends ChangeNotifier {
  static const _maxSteps = 50;
  static const _maxSessions = 10;

  int _nextId = 0;
  List<Session> _sessions = const [];
  int? _currentSessionId;

  List<Session> get sessions => List.unmodifiable(_sessions);

  bool get isRunning => currentSession?.isRunning ?? false;

  Session? get currentSession {
    final currentId = _currentSessionId;
    if (currentId == null) return null;
    for (final session in _sessions) {
      if (session.id == currentId) return session;
    }
    return null;
  }

  void start(String configLabel, String startMessage) {
    if (isRunning) return;
    final session = Session(
      id: _nextId++,
      configLabel: configLabel,
      startedAt: DateTime.now(),
      status: SessionStatus.running,
      steps: [Step(timestamp: DateTime.now(), message: startMessage)],
    );
    _currentSessionId = session.id;
    final next = [session, ..._sessions];
    _sessions = next.length > _maxSessions
        ? next.sublist(0, _maxSessions)
        : next;
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
    (s) => s.isRunning ? s._copyWith(status: SessionStatus.paused) : s,
  );

  void resume() => _updateCurrent(
    (s) => s.isRunning ? s._copyWith(status: SessionStatus.running) : s,
  );

  void adjustElapsed(Duration adjustment) => _updateCurrent((s) {
    final next = s.elapsedOffset + adjustment;
    return s._copyWith(elapsedOffset: next.isNegative ? Duration.zero : next);
  });

  void stopByUser() =>
      _stop(SessionStatus.stoppedByUser, "Đã dừng theo yêu cầu người dùng");

  void stopStuck(String reason) =>
      _stop(SessionStatus.stoppedStuck, "Dừng: $reason");

  void stopNetworkError(String reason) =>
      _stop(SessionStatus.stoppedNetworkError, "Dừng: lỗi network — $reason");

  void stopTimeLimit(String reason) =>
      _stop(SessionStatus.stoppedTimeLimit, "Dừng: $reason");

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

  void _stop(SessionStatus status, String message) {
    if (!isRunning) return;
    _updateCurrent(
      (s) => s._copyWith(
        steps: _pushStep(s.steps, message),
        status: status,
        endedAt: DateTime.now(),
      ),
    );
  }

  void _updateCurrent(Session Function(Session session) update) {
    if (_sessions.isEmpty) return;
    _sessions = [update(_sessions.first), ..._sessions.skip(1)];
    notifyListeners();
  }

  List<Step> _pushStep(List<Step> steps, String message) {
    final next = [Step(timestamp: DateTime.now(), message: message), ...steps];
    return next.length > _maxSteps ? next.sublist(0, _maxSteps) : next;
  }
}
