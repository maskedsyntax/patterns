class JournalEntry {
  final int? id;
  final String date;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  JournalEntry({
    this.id,
    required this.date,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'date': date,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      date: map['date'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}

enum OcdType { obsession, compulsion }

class OcdEntry {
  final int? id;
  final OcdType type;
  final DateTime datetime;
  final String content; // Thought or Urge
  final int distressLevel;
  final String response;
  final String? actionTaken; // Only for compulsion
  final DateTime createdAt;

  OcdEntry({
    this.id,
    required this.type,
    required this.datetime,
    required this.content,
    required this.distressLevel,
    required this.response,
    this.actionTaken,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'type': type.index,
      'datetime': datetime.toIso8601String(),
      'content': content,
      'distress_level': distressLevel,
      'response': response,
      'action_taken': actionTaken,
      'created_at': createdAt.toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory OcdEntry.fromMap(Map<String, dynamic> map) {
    return OcdEntry(
      id: map['id'],
      type: OcdType.values[map['type']],
      datetime: DateTime.parse(map['datetime']),
      content: map['content'],
      distressLevel: map['distress_level'],
      response: map['response'],
      actionTaken: map['action_taken'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

enum DelayOutcome { resisted, delayed, performed }

/// A single Compulsion Delay practice session: the user sat with an urge
/// instead of acting on it immediately. Captures the urge before/after and
/// what they ended up doing, so progress can be reflected back over time.
class DelaySession {
  final int? id;
  final String compulsion; // picked from a tracked compulsion, or free text
  final int plannedSeconds; // delay duration chosen up front
  final int actualSeconds; // time actually sat with the urge (< planned if stopped early)
  final bool completed; // true if the full timer elapsed
  final int urgeBefore; // 0–10
  final int urgeAfter; // 0–10
  final DelayOutcome outcome;
  final String? note; // optional reflection
  final DateTime createdAt;

  DelaySession({
    this.id,
    required this.compulsion,
    required this.plannedSeconds,
    required this.actualSeconds,
    required this.completed,
    required this.urgeBefore,
    required this.urgeAfter,
    required this.outcome,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'compulsion': compulsion,
      'planned_seconds': plannedSeconds,
      'actual_seconds': actualSeconds,
      'completed': completed ? 1 : 0,
      'urge_before': urgeBefore,
      'urge_after': urgeAfter,
      'outcome': outcome.index,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory DelaySession.fromMap(Map<String, dynamic> map) {
    return DelaySession(
      id: map['id'],
      compulsion: map['compulsion'],
      plannedSeconds: map['planned_seconds'],
      actualSeconds: map['actual_seconds'],
      completed: map['completed'] == 1,
      urgeBefore: map['urge_before'],
      urgeAfter: map['urge_after'],
      outcome: DelayOutcome.values[map['outcome']],
      note: map['note'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
