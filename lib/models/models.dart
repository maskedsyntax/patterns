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

enum ExposureStepStatus { notStarted, inProgress, completed }

/// A Pro "Exposure Hierarchy" - a fear ladder the user builds once and climbs
/// over time. Steps live in [ExposureStep] and point back at the hierarchy id.
class ExposureHierarchy {
  final int? id;
  final String title;
  final String theme; // the fear/compulsion this ladder targets
  final bool archived;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExposureHierarchy({
    this.id,
    required this.title,
    required this.theme,
    this.archived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'title': title,
      'theme': theme,
      'archived': archived ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory ExposureHierarchy.fromMap(Map<String, dynamic> map) {
    return ExposureHierarchy(
      id: map['id'],
      title: map['title'],
      theme: map['theme'],
      archived: map['archived'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}

/// One rung of an [ExposureHierarchy]: a single exposure with its difficulty and
/// anticipated anxiety, plus the climb status the user updates over time.
class ExposureStep {
  final int? id;
  final int? hierarchyId;
  final int orderIndex;
  final String description;
  final int difficulty; // 0–10
  final int anxietyRating; // 0–10 anticipated
  final ExposureStepStatus status;
  final DateTime? completedAt;

  ExposureStep({
    this.id,
    this.hierarchyId,
    required this.orderIndex,
    required this.description,
    required this.difficulty,
    required this.anxietyRating,
    this.status = ExposureStepStatus.notStarted,
    this.completedAt,
  });

  ExposureStep copyWith({
    int? id,
    int? hierarchyId,
    int? orderIndex,
    String? description,
    int? difficulty,
    int? anxietyRating,
    ExposureStepStatus? status,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return ExposureStep(
      id: id ?? this.id,
      hierarchyId: hierarchyId ?? this.hierarchyId,
      orderIndex: orderIndex ?? this.orderIndex,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      anxietyRating: anxietyRating ?? this.anxietyRating,
      status: status ?? this.status,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'hierarchy_id': hierarchyId,
      'order_index': orderIndex,
      'description': description,
      'difficulty': difficulty,
      'anxiety_rating': anxietyRating,
      'status': status.index,
      'completed_at': completedAt?.toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory ExposureStep.fromMap(Map<String, dynamic> map) {
    return ExposureStep(
      id: map['id'],
      hierarchyId: map['hierarchy_id'],
      orderIndex: map['order_index'],
      description: map['description'],
      difficulty: map['difficulty'],
      anxietyRating: map['anxiety_rating'],
      status: ExposureStepStatus.values[map['status']],
      completedAt: map['completed_at'] == null
          ? null
          : DateTime.parse(map['completed_at']),
    );
  }
}

/// Outcome of a response-prevention attempt. Ordered best → worst so the index
/// doubles as a severity scale for colouring.
enum ResponseOutcome { resisted, delayed, partial, performed }

/// A Pro "Response Prevention" log: after a trigger, how the user responded to
/// the compulsion urge.
class ResponsePreventionLog {
  final int? id;
  final DateTime datetime;
  final String situation;
  final ResponseOutcome outcome;
  final int anxietyLevel; // 0–10
  final String? note;
  final int? linkedStepId; // optional link to an exposure step
  final DateTime createdAt;

  ResponsePreventionLog({
    this.id,
    required this.datetime,
    required this.situation,
    required this.outcome,
    required this.anxietyLevel,
    this.note,
    this.linkedStepId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'datetime': datetime.toIso8601String(),
      'situation': situation,
      'outcome': outcome.index,
      'anxiety_level': anxietyLevel,
      'note': note,
      'linked_step_id': linkedStepId,
      'created_at': createdAt.toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory ResponsePreventionLog.fromMap(Map<String, dynamic> map) {
    return ResponsePreventionLog(
      id: map['id'],
      datetime: DateTime.parse(map['datetime']),
      situation: map['situation'],
      outcome: ResponseOutcome.values[map['outcome']],
      anxietyLevel: map['anxiety_level'],
      note: map['note'],
      linkedStepId: map['linked_step_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

/// A Pro "Urge Surfing" session: the user rode an urge without acting, tracking
/// how it rose and fell from start to peak to finish.
class UrgeSurfSession {
  final int? id;
  final DateTime datetime;
  final String trigger;
  final int initialUrge; // 0–10
  final int peakUrge; // 0–10
  final int finalUrge; // 0–10
  final int durationSeconds;
  final String? note;
  final DateTime createdAt;

  UrgeSurfSession({
    this.id,
    required this.datetime,
    required this.trigger,
    required this.initialUrge,
    required this.peakUrge,
    required this.finalUrge,
    required this.durationSeconds,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'datetime': datetime.toIso8601String(),
      'trigger': trigger,
      'initial_urge': initialUrge,
      'peak_urge': peakUrge,
      'final_urge': finalUrge,
      'duration_seconds': durationSeconds,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory UrgeSurfSession.fromMap(Map<String, dynamic> map) {
    return UrgeSurfSession(
      id: map['id'],
      datetime: DateTime.parse(map['datetime']),
      trigger: map['trigger'],
      initialUrge: map['initial_urge'],
      peakUrge: map['peak_urge'],
      finalUrge: map['final_urge'],
      durationSeconds: map['duration_seconds'],
      note: map['note'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

/// A Pro "Structured Program" enrollment - the user has started a multi-week
/// guided program (identified by a code-defined template id).
class ProgramEnrollment {
  final int? id;
  final String programId;
  final DateTime createdAt;

  ProgramEnrollment({
    this.id,
    required this.programId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'program_id': programId,
      'created_at': createdAt.toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory ProgramEnrollment.fromMap(Map<String, dynamic> map) {
    return ProgramEnrollment(
      id: map['id'],
      programId: map['program_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

/// A completed task within a program enrollment. A row's presence means the
/// task is done; toggling off deletes the row.
class ProgramTaskProgress {
  final int? id;
  final int enrollmentId;
  final int weekIndex;
  final String taskId;
  final DateTime completedAt;

  ProgramTaskProgress({
    this.id,
    required this.enrollmentId,
    required this.weekIndex,
    required this.taskId,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'enrollment_id': enrollmentId,
      'week_index': weekIndex,
      'task_id': taskId,
      'completed_at': completedAt.toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory ProgramTaskProgress.fromMap(Map<String, dynamic> map) {
    return ProgramTaskProgress(
      id: map['id'],
      enrollmentId: map['enrollment_id'],
      weekIndex: map['week_index'],
      taskId: map['task_id'],
      completedAt: DateTime.parse(map['completed_at']),
    );
  }
}

enum ExperimentStatus { planned, completed }

/// A Pro "Behavioral Experiment": test an OCD prediction against what actually
/// happens. Outcome + learning are filled in later, flipping status to completed.
class BehavioralExperiment {
  final int? id;
  final DateTime datetime;
  final String fearPrediction;
  final int confidence; // 0–100 %
  final String experiment;
  final String outcome; // empty until recorded
  final String learning; // empty until recorded
  final ExperimentStatus status;
  final DateTime createdAt;

  BehavioralExperiment({
    this.id,
    required this.datetime,
    required this.fearPrediction,
    required this.confidence,
    required this.experiment,
    this.outcome = '',
    this.learning = '',
    this.status = ExperimentStatus.planned,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'datetime': datetime.toIso8601String(),
      'fear_prediction': fearPrediction,
      'confidence': confidence,
      'experiment': experiment,
      'outcome': outcome,
      'learning': learning,
      'status': status.index,
      'created_at': createdAt.toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory BehavioralExperiment.fromMap(Map<String, dynamic> map) {
    return BehavioralExperiment(
      id: map['id'],
      datetime: DateTime.parse(map['datetime']),
      fearPrediction: map['fear_prediction'],
      confidence: map['confidence'],
      experiment: map['experiment'],
      outcome: map['outcome'] ?? '',
      learning: map['learning'] ?? '',
      status: ExperimentStatus.values[map['status']],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

/// A Pro "Exposure Reflection": structured insight capture after an exposure.
class ExposureReflection {
  final int? id;
  final DateTime datetime;
  final String whatHappened;
  final String ocdPredicted;
  final String actuallyHappened;
  final String whatILearned;
  final String doDifferently;
  final DateTime createdAt;

  ExposureReflection({
    this.id,
    required this.datetime,
    required this.whatHappened,
    required this.ocdPredicted,
    required this.actuallyHappened,
    required this.whatILearned,
    required this.doDifferently,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'datetime': datetime.toIso8601String(),
      'what_happened': whatHappened,
      'ocd_predicted': ocdPredicted,
      'actually_happened': actuallyHappened,
      'what_i_learned': whatILearned,
      'do_differently': doDifferently,
      'created_at': createdAt.toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory ExposureReflection.fromMap(Map<String, dynamic> map) {
    return ExposureReflection(
      id: map['id'],
      datetime: DateTime.parse(map['datetime']),
      whatHappened: map['what_happened'],
      ocdPredicted: map['ocd_predicted'],
      actuallyHappened: map['actually_happened'],
      whatILearned: map['what_i_learned'],
      doDifferently: map['do_differently'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

/// A Pro "Action Plan": a planned response to a trigger, optionally dated, that
/// the user can tick off once done.
class ActionPlan {
  final int? id;
  final String situation;
  final String plannedAction;
  final String? date; // optional 'yyyy-MM-dd' the plan is for
  final String? notes;
  final bool completed;
  final DateTime createdAt;

  ActionPlan({
    this.id,
    required this.situation,
    required this.plannedAction,
    this.date,
    this.notes,
    this.completed = false,
    required this.createdAt,
  });

  ActionPlan copyWith({bool? completed}) => ActionPlan(
    id: id,
    situation: situation,
    plannedAction: plannedAction,
    date: date,
    notes: notes,
    completed: completed ?? this.completed,
    createdAt: createdAt,
  );

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'situation': situation,
      'planned_action': plannedAction,
      'date': date,
      'notes': notes,
      'completed': completed ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory ActionPlan.fromMap(Map<String, dynamic> map) {
    return ActionPlan(
      id: map['id'],
      situation: map['situation'],
      plannedAction: map['planned_action'],
      date: map['date'],
      notes: map['notes'],
      completed: map['completed'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

/// A Pro "Implementation Intention": an if-then plan that pairs a trigger with
/// a pre-decided response.
class ImplementationIntention {
  final int? id;
  final String trigger;
  final String response;
  final DateTime createdAt;

  ImplementationIntention({
    this.id,
    required this.trigger,
    required this.response,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'trigger': trigger,
      'response': response,
      'created_at': createdAt.toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory ImplementationIntention.fromMap(Map<String, dynamic> map) {
    return ImplementationIntention(
      id: map['id'],
      trigger: map['trigger'],
      response: map['response'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

/// A Pro "Uncertainty Training" log: a completed willingness-to-not-know
/// exercise (identified by a code-defined template id).
class UncertaintyLog {
  final int? id;
  final DateTime datetime;
  final String exerciseId;
  final int willingness; // 0–10
  final String? note;
  final DateTime createdAt;

  UncertaintyLog({
    this.id,
    required this.datetime,
    required this.exerciseId,
    required this.willingness,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'datetime': datetime.toIso8601String(),
      'exercise_id': exerciseId,
      'willingness': willingness,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory UncertaintyLog.fromMap(Map<String, dynamic> map) {
    return UncertaintyLog(
      id: map['id'],
      datetime: DateTime.parse(map['datetime']),
      exerciseId: map['exercise_id'],
      willingness: map['willingness'],
      note: map['note'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

enum MaterialType { script, loopTape, image, link }

/// A Pro "Exposure Material" - a stimulus the user saves for use during an
/// exposure: a script (text), a recorded loop tape or image (stored file), or a
/// link. Files are referenced by [fileName] only (relative to the app's
/// `materials/` dir) and resolved at runtime - never an absolute path, since the
/// iOS app-container path changes between installs.
class ExposureMaterial {
  final int? id;
  final MaterialType type;
  final String title;
  final String? text; // script body
  final String? url; // link
  final String? fileName; // relative filename for loopTape / image
  final int? linkedHierarchyId;
  final int? linkedStepId;
  final DateTime createdAt;

  ExposureMaterial({
    this.id,
    required this.type,
    required this.title,
    this.text,
    this.url,
    this.fileName,
    this.linkedHierarchyId,
    this.linkedStepId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'type': type.index,
      'title': title,
      'text': text,
      'url': url,
      'file_name': fileName,
      'linked_hierarchy_id': linkedHierarchyId,
      'linked_step_id': linkedStepId,
      'created_at': createdAt.toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory ExposureMaterial.fromMap(Map<String, dynamic> map) {
    return ExposureMaterial(
      id: map['id'],
      type: MaterialType.values[map['type']],
      title: map['title'],
      text: map['text'],
      url: map['url'],
      fileName: map['file_name'],
      linkedHierarchyId: map['linked_hierarchy_id'],
      linkedStepId: map['linked_step_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
