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
  final int
  actualSeconds; // time actually sat with the urge (< planned if stopped early)
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

/// A reusable guided ERP exercise plan. The user creates this once, then logs
/// repeated practice sessions against it.
class ErpExercisePlan {
  final int? id;
  final String exerciseId;
  final String exerciseTitle;
  final String triggerOrExposure;
  final String fearPrediction;
  final String preventionCommitment;
  final int defaultSeconds;
  final bool archived;
  final DateTime createdAt;
  final DateTime updatedAt;

  ErpExercisePlan({
    this.id,
    required this.exerciseId,
    required this.exerciseTitle,
    required this.triggerOrExposure,
    required this.fearPrediction,
    required this.preventionCommitment,
    required this.defaultSeconds,
    this.archived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'exercise_id': exerciseId,
      'exercise_title': exerciseTitle,
      'trigger_or_exposure': triggerOrExposure,
      'fear_prediction': fearPrediction,
      'prevention_commitment': preventionCommitment,
      'default_seconds': defaultSeconds,
      'archived': archived ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory ErpExercisePlan.fromMap(Map<String, dynamic> map) {
    return ErpExercisePlan(
      id: map['id'],
      exerciseId: map['exercise_id'],
      exerciseTitle: map['exercise_title'],
      triggerOrExposure: map['trigger_or_exposure'],
      fearPrediction: map['fear_prediction'],
      preventionCommitment: map['prevention_commitment'],
      defaultSeconds: map['default_seconds'],
      archived: map['archived'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}

/// A completed guided ERP exercise session. Sessions point at a reusable plan
/// and also store snapshots so history stays readable if a plan is edited or
/// archived later.
class ErpExerciseSession {
  final int? id;
  final int? planId;
  final String exerciseId;
  final String exerciseTitle;
  final String triggerOrExposure;
  final String fearPrediction;
  final String preventionCommitment;
  final int plannedSeconds;
  final int actualSeconds;
  final bool completed;
  final int anxietyBefore; // 0-10
  final int anxietyAfter; // 0-10
  final DelayOutcome outcome;
  final String whatHappened;
  final String learning;
  final String? note;
  final DateTime createdAt;

  ErpExerciseSession({
    this.id,
    this.planId,
    required this.exerciseId,
    required this.exerciseTitle,
    required this.triggerOrExposure,
    required this.fearPrediction,
    required this.preventionCommitment,
    required this.plannedSeconds,
    required this.actualSeconds,
    required this.completed,
    required this.anxietyBefore,
    required this.anxietyAfter,
    required this.outcome,
    required this.whatHappened,
    required this.learning,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'plan_id': planId,
      'exercise_id': exerciseId,
      'exercise_title': exerciseTitle,
      'trigger_or_exposure': triggerOrExposure,
      'fear_prediction': fearPrediction,
      'prevention_commitment': preventionCommitment,
      'planned_seconds': plannedSeconds,
      'actual_seconds': actualSeconds,
      'completed': completed ? 1 : 0,
      'anxiety_before': anxietyBefore,
      'anxiety_after': anxietyAfter,
      'outcome': outcome.index,
      'what_happened': whatHappened,
      'learning': learning,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory ErpExerciseSession.fromMap(Map<String, dynamic> map) {
    return ErpExerciseSession(
      id: map['id'],
      planId: map['plan_id'],
      exerciseId: map['exercise_id'],
      exerciseTitle: map['exercise_title'],
      triggerOrExposure: map['trigger_or_exposure'],
      fearPrediction: map['fear_prediction'],
      preventionCommitment: map['prevention_commitment'],
      plannedSeconds: map['planned_seconds'],
      actualSeconds: map['actual_seconds'],
      completed: map['completed'] == 1,
      anxietyBefore: map['anxiety_before'],
      anxietyAfter: map['anxiety_after'],
      outcome: DelayOutcome.values[map['outcome']],
      whatHappened: map['what_happened'],
      learning: map['learning'],
      note: map['note'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
