import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as mobile_sqflite;
import 'package:sqflite_common/sqlite_api.dart';
import '../models/models.dart';
import '../services/material_file_store.dart';

const int _backupSchemaVersion = 10;

class BackupSummary {
  final int journalCount;
  final int ocdCount;
  final int delaySessionCount;
  final int erpExercisePlanCount;
  final int erpExerciseSessionCount;
  final int exposureHierarchyCount;
  final int exposureStepCount;
  final int responsePreventionCount;
  final int urgeSurfCount;
  final int programEnrollmentCount;
  final int programTaskProgressCount;
  final int behavioralExperimentCount;
  final int exposureReflectionCount;
  final int actionPlanCount;
  final int implementationIntentionCount;
  final int uncertaintyLogCount;
  final int exposureMaterialCount;
  final int ybocsAssessmentCount;

  const BackupSummary({
    required this.journalCount,
    required this.ocdCount,
    this.delaySessionCount = 0,
    this.erpExercisePlanCount = 0,
    this.erpExerciseSessionCount = 0,
    this.exposureHierarchyCount = 0,
    this.exposureStepCount = 0,
    this.responsePreventionCount = 0,
    this.urgeSurfCount = 0,
    this.programEnrollmentCount = 0,
    this.programTaskProgressCount = 0,
    this.behavioralExperimentCount = 0,
    this.exposureReflectionCount = 0,
    this.actionPlanCount = 0,
    this.implementationIntentionCount = 0,
    this.uncertaintyLogCount = 0,
    this.exposureMaterialCount = 0,
    this.ybocsAssessmentCount = 0,
  });
}

class DbHelper {
  static final DbHelper instance = DbHelper._init();
  static Database? _database;

  DbHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('patterns.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationSupportDirectory();
    final path = join(dbPath.path, filePath);

    return await _databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 10,
        onCreate: _createDB,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  DatabaseFactory get _databaseFactory => mobile_sqflite.databaseFactory;

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE journal (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT UNIQUE,
        content TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ocd (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type INTEGER,
        datetime TEXT,
        content TEXT,
        distress_level INTEGER,
        response TEXT,
        action_taken TEXT,
        created_at TEXT
      )
    ''');

    await _createDelaySessionsTable(db);
    await _createErpExercisePlansTable(db);
    await _createErpExerciseSessionsTable(db);
    await _createExposureHierarchiesTable(db);
    await _createExposureStepsTable(db);
    await _createResponsePreventionLogsTable(db);
    await _createUrgeSurfSessionsTable(db);
    await _createProgramEnrollmentsTable(db);
    await _createProgramTaskProgressTable(db);
    await _createBehavioralExperimentsTable(db);
    await _createExposureReflectionsTable(db);
    await _createActionPlansTable(db);
    await _createImplementationIntentionsTable(db);
    await _createUncertaintyLogTable(db);
    await _createExposureMaterialsTable(db);
    await _createYbocsAssessmentsTable(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // v2: Compulsion Delay Tool - added the delay_sessions table.
    if (oldVersion < 2) {
      await _createDelaySessionsTable(db);
    }
    // v3: Guided ERP Exercises - added completed exercise sessions.
    if (oldVersion < 3) {
      await _createErpExercisePlansTable(db);
      await _createErpExerciseSessionsTable(db);
    }
    // v4: Pro - Exposure Hierarchy Builder (fear ladders + their steps).
    if (oldVersion < 4) {
      await _createExposureHierarchiesTable(db);
      await _createExposureStepsTable(db);
    }
    // v5: Pro - Response Prevention + Urge Surfing trackers.
    if (oldVersion < 5) {
      await _createResponsePreventionLogsTable(db);
      await _createUrgeSurfSessionsTable(db);
    }
    // v6: Pro - Structured ERP Programs (enrollments + task progress).
    if (oldVersion < 6) {
      await _createProgramEnrollmentsTable(db);
      await _createProgramTaskProgressTable(db);
    }
    // v7: Pro - Behavioral Experiments + Exposure Reflection Journal.
    if (oldVersion < 7) {
      await _createBehavioralExperimentsTable(db);
      await _createExposureReflectionsTable(db);
    }
    // v8: Pro - Action Planner, Implementation Intentions, Uncertainty Training.
    if (oldVersion < 8) {
      await _createActionPlansTable(db);
      await _createImplementationIntentionsTable(db);
      await _createUncertaintyLogTable(db);
    }
    // v9: Pro - Exposure Materials (trigger library: scripts/loop tapes/images/links).
    if (oldVersion < 9) {
      await _createExposureMaterialsTable(db);
    }
    // v10: Y-BOCS self-check (saved symptom checklist + severity assessments).
    if (oldVersion < 10) {
      await _createYbocsAssessmentsTable(db);
    }
  }

  // Single source of truth for the delay_sessions DDL, shared by fresh
  // installs (_createDB) and upgrades (_onUpgrade) so they can't drift.
  Future<void> _createDelaySessionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS delay_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        compulsion TEXT,
        planned_seconds INTEGER,
        actual_seconds INTEGER,
        completed INTEGER,
        urge_before INTEGER,
        urge_after INTEGER,
        outcome INTEGER,
        note TEXT,
        created_at TEXT
      )
    ''');
  }

  Future<void> _createErpExercisePlansTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS erp_exercise_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id TEXT,
        exercise_title TEXT,
        trigger_or_exposure TEXT,
        fear_prediction TEXT,
        prevention_commitment TEXT,
        default_seconds INTEGER,
        archived INTEGER,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  Future<void> _createErpExerciseSessionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS erp_exercise_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plan_id INTEGER,
        exercise_id TEXT,
        exercise_title TEXT,
        trigger_or_exposure TEXT,
        fear_prediction TEXT,
        prevention_commitment TEXT,
        planned_seconds INTEGER,
        actual_seconds INTEGER,
        completed INTEGER,
        anxiety_before INTEGER,
        anxiety_after INTEGER,
        outcome INTEGER,
        what_happened TEXT,
        learning TEXT,
        note TEXT,
        created_at TEXT
      )
    ''');
  }

  Future<void> _createExposureHierarchiesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS exposure_hierarchies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        theme TEXT,
        archived INTEGER,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  Future<void> _createExposureStepsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS exposure_steps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hierarchy_id INTEGER,
        order_index INTEGER,
        description TEXT,
        difficulty INTEGER,
        anxiety_rating INTEGER,
        status INTEGER,
        completed_at TEXT
      )
    ''');
  }

  Future<void> _createResponsePreventionLogsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS response_prevention_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        datetime TEXT,
        situation TEXT,
        outcome INTEGER,
        anxiety_level INTEGER,
        note TEXT,
        linked_step_id INTEGER,
        created_at TEXT
      )
    ''');
  }

  Future<void> _createUrgeSurfSessionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS urge_surf_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        datetime TEXT,
        trigger TEXT,
        initial_urge INTEGER,
        peak_urge INTEGER,
        final_urge INTEGER,
        duration_seconds INTEGER,
        note TEXT,
        created_at TEXT
      )
    ''');
  }

  Future<void> _createProgramEnrollmentsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS program_enrollments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        program_id TEXT,
        created_at TEXT
      )
    ''');
  }

  Future<void> _createProgramTaskProgressTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS program_task_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        enrollment_id INTEGER,
        week_index INTEGER,
        task_id TEXT,
        completed_at TEXT
      )
    ''');
  }

  Future<void> _createBehavioralExperimentsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS behavioral_experiments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        datetime TEXT,
        fear_prediction TEXT,
        confidence INTEGER,
        experiment TEXT,
        outcome TEXT,
        learning TEXT,
        status INTEGER,
        created_at TEXT
      )
    ''');
  }

  Future<void> _createExposureReflectionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS exposure_reflections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        datetime TEXT,
        what_happened TEXT,
        ocd_predicted TEXT,
        actually_happened TEXT,
        what_i_learned TEXT,
        do_differently TEXT,
        created_at TEXT
      )
    ''');
  }

  Future<void> _createActionPlansTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS action_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        situation TEXT,
        planned_action TEXT,
        date TEXT,
        notes TEXT,
        completed INTEGER,
        created_at TEXT
      )
    ''');
  }

  Future<void> _createImplementationIntentionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS implementation_intentions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        trigger TEXT,
        response TEXT,
        created_at TEXT
      )
    ''');
  }

  Future<void> _createUncertaintyLogTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS uncertainty_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        datetime TEXT,
        exercise_id TEXT,
        willingness INTEGER,
        note TEXT,
        created_at TEXT
      )
    ''');
  }

  Future<void> _createExposureMaterialsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS exposure_materials (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type INTEGER,
        title TEXT,
        text TEXT,
        url TEXT,
        file_name TEXT,
        linked_hierarchy_id INTEGER,
        linked_step_id INTEGER,
        created_at TEXT
      )
    ''');
  }

  Future<void> _createYbocsAssessmentsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ybocs_assessments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        datetime TEXT,
        obsession_score INTEGER,
        compulsion_score INTEGER,
        total_score INTEGER,
        severity INTEGER,
        item_scores TEXT,
        themes TEXT,
        symptoms TEXT,
        created_at TEXT
      )
    ''');
  }

  // Journal Methods
  Future<List<JournalEntry>> getJournalEntries() async {
    final db = await instance.database;
    final result = await db.query('journal', orderBy: 'date ASC');
    return result.map((json) => JournalEntry.fromMap(json)).toList();
  }

  Future<JournalEntry?> getJournalEntryByDate(String date) async {
    final db = await instance.database;
    final result = await db.query(
      'journal',
      where: 'date = ?',
      whereArgs: [date],
    );
    if (result.isNotEmpty) return JournalEntry.fromMap(result.first);
    return null;
  }

  Future<int> upsertJournalEntry(JournalEntry entry) async {
    final db = await instance.database;
    final existing = await getJournalEntryByDate(entry.date);
    if (existing != null) {
      final map = entry.toMap();
      map.remove('id');
      map.remove('created_at'); // Keep original creation date
      return await db.update(
        'journal',
        map,
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    } else {
      return await db.insert('journal', entry.toMap());
    }
  }

  Future<int> deleteJournalEntry(String date) async {
    final db = await instance.database;
    return await db.delete('journal', where: 'date = ?', whereArgs: [date]);
  }

  // OCD Methods
  Future<List<OcdEntry>> getOcdEntries() async {
    final db = await instance.database;
    final result = await db.query('ocd', orderBy: 'datetime DESC');
    return result.map((json) => OcdEntry.fromMap(json)).toList();
  }

  Future<int> insertOcdEntry(OcdEntry entry) async {
    final db = await instance.database;
    return await db.insert('ocd', entry.toMap());
  }

  Future<int> updateOcdEntry(OcdEntry entry) async {
    final id = entry.id;
    if (id == null) {
      throw ArgumentError('Cannot update an OCD entry without an id');
    }
    final db = await instance.database;
    final map = entry.toMap()..remove('id');
    return await db.update('ocd', map, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteOcdEntry(int id) async {
    final db = await instance.database;
    return await db.delete('ocd', where: 'id = ?', whereArgs: [id]);
  }

  // Delay Session Methods
  Future<List<DelaySession>> getDelaySessions() async {
    final db = await instance.database;
    final result = await db.query('delay_sessions', orderBy: 'created_at DESC');
    return result.map((json) => DelaySession.fromMap(json)).toList();
  }

  Future<int> insertDelaySession(DelaySession session) async {
    final db = await instance.database;
    return await db.insert('delay_sessions', session.toMap());
  }

  // Guided ERP Exercise Methods
  Future<List<ErpExercisePlan>> getActiveErpExercisePlans() async {
    final db = await instance.database;
    final result = await db.query(
      'erp_exercise_plans',
      where: 'archived = ?',
      whereArgs: [0],
      orderBy: 'updated_at DESC',
    );
    return result.map((json) => ErpExercisePlan.fromMap(json)).toList();
  }

  Future<int> insertErpExercisePlan(ErpExercisePlan plan) async {
    final db = await instance.database;
    return await db.insert('erp_exercise_plans', plan.toMap());
  }

  Future<int> updateErpExercisePlan(ErpExercisePlan plan) async {
    final id = plan.id;
    if (id == null) {
      throw ArgumentError('Cannot update an ERP exercise plan without an id');
    }
    final db = await instance.database;
    final map = plan.toMap()..remove('id');
    return await db.update(
      'erp_exercise_plans',
      map,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> archiveErpExercisePlan(int id) async {
    final db = await instance.database;
    return await db.update(
      'erp_exercise_plans',
      {'archived': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ErpExerciseSession>> getErpExerciseSessions() async {
    final db = await instance.database;
    final result = await db.query(
      'erp_exercise_sessions',
      orderBy: 'created_at DESC',
    );
    return result.map((json) => ErpExerciseSession.fromMap(json)).toList();
  }

  Future<int> insertErpExerciseSession(ErpExerciseSession session) async {
    final db = await instance.database;
    return await db.insert('erp_exercise_sessions', session.toMap());
  }

  // Exposure Hierarchy Methods (Pro)
  Future<List<ExposureHierarchy>> getActiveExposureHierarchies() async {
    final db = await instance.database;
    final result = await db.query(
      'exposure_hierarchies',
      where: 'archived = ?',
      whereArgs: [0],
      orderBy: 'updated_at DESC',
    );
    return result.map((json) => ExposureHierarchy.fromMap(json)).toList();
  }

  /// Inserts a hierarchy and its ordered steps atomically, stamping each step
  /// with the new hierarchy id and its list position. Returns the hierarchy id.
  Future<int> insertExposureHierarchyWithSteps(
    ExposureHierarchy hierarchy,
    List<ExposureStep> steps,
  ) async {
    final db = await instance.database;
    return await db.transaction((txn) async {
      final hierarchyId = await txn.insert(
        'exposure_hierarchies',
        hierarchy.toMap(),
      );
      for (var i = 0; i < steps.length; i++) {
        final map = steps[i]
            .copyWith(hierarchyId: hierarchyId, orderIndex: i)
            .toMap();
        map.remove('id');
        await txn.insert('exposure_steps', map);
      }
      return hierarchyId;
    });
  }

  Future<int> archiveExposureHierarchy(int id) async {
    final db = await instance.database;
    return await db.update(
      'exposure_hierarchies',
      {'archived': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ExposureStep>> getExposureSteps() async {
    final db = await instance.database;
    final result = await db.query(
      'exposure_steps',
      orderBy: 'hierarchy_id ASC, order_index ASC',
    );
    return result.map((json) => ExposureStep.fromMap(json)).toList();
  }

  Future<int> updateExposureStep(ExposureStep step) async {
    final id = step.id;
    if (id == null) {
      throw ArgumentError('Cannot update an exposure step without an id');
    }
    final db = await instance.database;
    final map = step.toMap()..remove('id');
    return await db.update(
      'exposure_steps',
      map,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Response Prevention Methods (Pro)
  Future<List<ResponsePreventionLog>> getResponsePreventionLogs() async {
    final db = await instance.database;
    final result = await db.query(
      'response_prevention_logs',
      orderBy: 'datetime DESC',
    );
    return result.map((json) => ResponsePreventionLog.fromMap(json)).toList();
  }

  Future<int> insertResponsePreventionLog(ResponsePreventionLog log) async {
    final db = await instance.database;
    return await db.insert('response_prevention_logs', log.toMap());
  }

  Future<int> deleteResponsePreventionLog(int id) async {
    final db = await instance.database;
    return await db.delete(
      'response_prevention_logs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Urge Surfing Methods (Pro)
  Future<List<UrgeSurfSession>> getUrgeSurfSessions() async {
    final db = await instance.database;
    final result = await db.query(
      'urge_surf_sessions',
      orderBy: 'datetime DESC',
    );
    return result.map((json) => UrgeSurfSession.fromMap(json)).toList();
  }

  Future<int> insertUrgeSurfSession(UrgeSurfSession session) async {
    final db = await instance.database;
    return await db.insert('urge_surf_sessions', session.toMap());
  }

  // Structured Programs Methods (Pro)
  Future<List<ProgramEnrollment>> getProgramEnrollments() async {
    final db = await instance.database;
    final result = await db.query(
      'program_enrollments',
      orderBy: 'created_at DESC',
    );
    return result.map((json) => ProgramEnrollment.fromMap(json)).toList();
  }

  Future<int> insertProgramEnrollment(ProgramEnrollment enrollment) async {
    final db = await instance.database;
    return await db.insert('program_enrollments', enrollment.toMap());
  }

  Future<List<ProgramTaskProgress>> getProgramTaskProgress() async {
    final db = await instance.database;
    final result = await db.query('program_task_progress');
    return result.map((json) => ProgramTaskProgress.fromMap(json)).toList();
  }

  Future<int> insertProgramTaskProgress(ProgramTaskProgress progress) async {
    final db = await instance.database;
    return await db.insert('program_task_progress', progress.toMap());
  }

  Future<int> deleteProgramTaskProgress({
    required int enrollmentId,
    required int weekIndex,
    required String taskId,
  }) async {
    final db = await instance.database;
    return await db.delete(
      'program_task_progress',
      where: 'enrollment_id = ? AND week_index = ? AND task_id = ?',
      whereArgs: [enrollmentId, weekIndex, taskId],
    );
  }

  // Behavioral Experiments Methods (Pro)
  Future<List<BehavioralExperiment>> getBehavioralExperiments() async {
    final db = await instance.database;
    final result = await db.query(
      'behavioral_experiments',
      orderBy: 'datetime DESC',
    );
    return result.map((json) => BehavioralExperiment.fromMap(json)).toList();
  }

  Future<int> insertBehavioralExperiment(BehavioralExperiment exp) async {
    final db = await instance.database;
    return await db.insert('behavioral_experiments', exp.toMap());
  }

  Future<int> updateBehavioralExperiment(BehavioralExperiment exp) async {
    final id = exp.id;
    if (id == null) {
      throw ArgumentError(
        'Cannot update a behavioral experiment without an id',
      );
    }
    final db = await instance.database;
    final map = exp.toMap()..remove('id');
    return await db.update(
      'behavioral_experiments',
      map,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteBehavioralExperiment(int id) async {
    final db = await instance.database;
    return await db.delete(
      'behavioral_experiments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Exposure Reflection Methods (Pro)
  Future<List<ExposureReflection>> getExposureReflections() async {
    final db = await instance.database;
    final result = await db.query(
      'exposure_reflections',
      orderBy: 'datetime DESC',
    );
    return result.map((json) => ExposureReflection.fromMap(json)).toList();
  }

  Future<int> insertExposureReflection(ExposureReflection reflection) async {
    final db = await instance.database;
    return await db.insert('exposure_reflections', reflection.toMap());
  }

  Future<int> deleteExposureReflection(int id) async {
    final db = await instance.database;
    return await db.delete(
      'exposure_reflections',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Action Planner Methods (Pro)
  Future<List<ActionPlan>> getActionPlans() async {
    final db = await instance.database;
    final result = await db.query('action_plans', orderBy: 'created_at DESC');
    return result.map((json) => ActionPlan.fromMap(json)).toList();
  }

  Future<int> insertActionPlan(ActionPlan plan) async {
    final db = await instance.database;
    return await db.insert('action_plans', plan.toMap());
  }

  Future<int> updateActionPlan(ActionPlan plan) async {
    final id = plan.id;
    if (id == null) {
      throw ArgumentError('Cannot update an action plan without an id');
    }
    final db = await instance.database;
    final map = plan.toMap()..remove('id');
    return await db.update(
      'action_plans',
      map,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteActionPlan(int id) async {
    final db = await instance.database;
    return await db.delete('action_plans', where: 'id = ?', whereArgs: [id]);
  }

  // Implementation Intentions Methods (Pro)
  Future<List<ImplementationIntention>> getImplementationIntentions() async {
    final db = await instance.database;
    final result = await db.query(
      'implementation_intentions',
      orderBy: 'created_at DESC',
    );
    return result.map((json) => ImplementationIntention.fromMap(json)).toList();
  }

  Future<int> insertImplementationIntention(
    ImplementationIntention intention,
  ) async {
    final db = await instance.database;
    return await db.insert('implementation_intentions', intention.toMap());
  }

  Future<int> deleteImplementationIntention(int id) async {
    final db = await instance.database;
    return await db.delete(
      'implementation_intentions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Uncertainty Training Methods (Pro)
  Future<List<UncertaintyLog>> getUncertaintyLogs() async {
    final db = await instance.database;
    final result = await db.query('uncertainty_log', orderBy: 'datetime DESC');
    return result.map((json) => UncertaintyLog.fromMap(json)).toList();
  }

  Future<int> insertUncertaintyLog(UncertaintyLog log) async {
    final db = await instance.database;
    return await db.insert('uncertainty_log', log.toMap());
  }

  // Exposure Materials Methods (Pro)
  Future<List<ExposureMaterial>> getExposureMaterials() async {
    final db = await instance.database;
    final result = await db.query(
      'exposure_materials',
      orderBy: 'created_at DESC',
    );
    return result.map((json) => ExposureMaterial.fromMap(json)).toList();
  }

  Future<int> insertExposureMaterial(ExposureMaterial material) async {
    final db = await instance.database;
    return await db.insert('exposure_materials', material.toMap());
  }

  Future<int> deleteExposureMaterial(int id) async {
    final db = await instance.database;
    return await db.delete(
      'exposure_materials',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Y-BOCS Self-Check Methods
  Future<List<YbocsAssessment>> getYbocsAssessments() async {
    final db = await instance.database;
    final result = await db.query(
      'ybocs_assessments',
      orderBy: 'datetime DESC',
    );
    return result.map((json) => YbocsAssessment.fromMap(json)).toList();
  }

  Future<int> insertYbocsAssessment(YbocsAssessment assessment) async {
    final db = await instance.database;
    return await db.insert('ybocs_assessments', assessment.toMap());
  }

  Future<int> deleteYbocsAssessment(int id) async {
    final db = await instance.database;
    return await db.delete(
      'ybocs_assessments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAll() async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete('journal');
      await txn.delete('ocd');
      await txn.delete('delay_sessions');
      await txn.delete('erp_exercise_plans');
      await txn.delete('erp_exercise_sessions');
      await txn.delete('exposure_hierarchies');
      await txn.delete('exposure_steps');
      await txn.delete('response_prevention_logs');
      await txn.delete('urge_surf_sessions');
      await txn.delete('program_enrollments');
      await txn.delete('program_task_progress');
      await txn.delete('behavioral_experiments');
      await txn.delete('exposure_reflections');
      await txn.delete('action_plans');
      await txn.delete('implementation_intentions');
      await txn.delete('uncertainty_log');
      await txn.delete('exposure_materials');
      await txn.delete('ybocs_assessments');
    });
  }

  // Export / Import
  Future<String> exportAll() async {
    final db = await instance.database;
    final journal = await db.query('journal');
    final ocd = await db.query('ocd');
    final delaySessions = await db.query('delay_sessions');
    final erpExercisePlans = await db.query('erp_exercise_plans');
    final erpExerciseSessions = await db.query('erp_exercise_sessions');
    final exposureHierarchies = await db.query('exposure_hierarchies');
    final exposureSteps = await db.query('exposure_steps');
    final responsePrevention = await db.query('response_prevention_logs');
    final urgeSurf = await db.query('urge_surf_sessions');
    final programEnrollments = await db.query('program_enrollments');
    final programTaskProgress = await db.query('program_task_progress');
    final behavioralExperiments = await db.query('behavioral_experiments');
    final exposureReflections = await db.query('exposure_reflections');
    final actionPlans = await db.query('action_plans');
    final implementationIntentions = await db.query(
      'implementation_intentions',
    );
    final uncertaintyLog = await db.query('uncertainty_log');
    final exposureMaterials = await db.query('exposure_materials');
    final ybocsAssessments = await db.query('ybocs_assessments');
    final data = {
      'schema_version': _backupSchemaVersion,
      'journal': journal,
      'ocd': ocd,
      'delay_sessions': delaySessions,
      'erp_exercise_plans': erpExercisePlans,
      'erp_exercise_sessions': erpExerciseSessions,
      'exposure_hierarchies': exposureHierarchies,
      'exposure_steps': exposureSteps,
      'response_prevention_logs': responsePrevention,
      'urge_surf_sessions': urgeSurf,
      'program_enrollments': programEnrollments,
      'program_task_progress': programTaskProgress,
      'behavioral_experiments': behavioralExperiments,
      'exposure_reflections': exposureReflections,
      'action_plans': actionPlans,
      'implementation_intentions': implementationIntentions,
      'uncertainty_log': uncertaintyLog,
      'exposure_materials': exposureMaterials,
      'ybocs_assessments': ybocsAssessments,
    };
    return jsonEncode(data);
  }

  Future<void> importAll(String jsonStr) async {
    final data = _decodeBackup(jsonStr);
    _validateBackup(data);

    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete('journal');
      await txn.delete('ocd');
      await txn.delete('delay_sessions');
      await txn.delete('erp_exercise_plans');
      await txn.delete('erp_exercise_sessions');
      for (final item in _backupList(data, 'journal')) {
        await txn.insert('journal', Map<String, dynamic>.from(item));
      }
      for (final item in _backupList(data, 'ocd')) {
        await txn.insert('ocd', Map<String, dynamic>.from(item));
      }
      for (final item in _backupList(data, 'delay_sessions')) {
        await txn.insert('delay_sessions', Map<String, dynamic>.from(item));
      }
      for (final item in _backupList(data, 'erp_exercise_plans')) {
        await txn.insert('erp_exercise_plans', Map<String, dynamic>.from(item));
      }
      for (final item in _backupList(data, 'erp_exercise_sessions')) {
        await txn.insert(
          'erp_exercise_sessions',
          Map<String, dynamic>.from(item),
        );
      }
      for (final item in _backupList(data, 'exposure_hierarchies')) {
        await txn.insert(
          'exposure_hierarchies',
          Map<String, dynamic>.from(item),
        );
      }
      for (final item in _backupList(data, 'exposure_steps')) {
        await txn.insert('exposure_steps', Map<String, dynamic>.from(item));
      }
      for (final item in _backupList(data, 'response_prevention_logs')) {
        await txn.insert(
          'response_prevention_logs',
          Map<String, dynamic>.from(item),
        );
      }
      for (final item in _backupList(data, 'urge_surf_sessions')) {
        await txn.insert('urge_surf_sessions', Map<String, dynamic>.from(item));
      }
      for (final item in _backupList(data, 'program_enrollments')) {
        await txn.insert(
          'program_enrollments',
          Map<String, dynamic>.from(item),
        );
      }
      for (final item in _backupList(data, 'program_task_progress')) {
        await txn.insert(
          'program_task_progress',
          Map<String, dynamic>.from(item),
        );
      }
      for (final item in _backupList(data, 'behavioral_experiments')) {
        await txn.insert(
          'behavioral_experiments',
          Map<String, dynamic>.from(item),
        );
      }
      for (final item in _backupList(data, 'exposure_reflections')) {
        await txn.insert(
          'exposure_reflections',
          Map<String, dynamic>.from(item),
        );
      }
      for (final item in _backupList(data, 'action_plans')) {
        await txn.insert('action_plans', Map<String, dynamic>.from(item));
      }
      for (final item in _backupList(data, 'implementation_intentions')) {
        await txn.insert(
          'implementation_intentions',
          Map<String, dynamic>.from(item),
        );
      }
      for (final item in _backupList(data, 'uncertainty_log')) {
        await txn.insert('uncertainty_log', Map<String, dynamic>.from(item));
      }
      for (final item in _backupList(data, 'exposure_materials')) {
        await txn.insert('exposure_materials', Map<String, dynamic>.from(item));
      }
      for (final item in _backupList(data, 'ybocs_assessments')) {
        await txn.insert('ybocs_assessments', Map<String, dynamic>.from(item));
      }
    });
  }

  /// Full backup as a zip bundle: `data.json` (all rows) plus every stored
  /// exposure-material file under `materials/`. Lets binary media (loop tapes,
  /// images) survive a cross-device restore.
  Future<Uint8List> exportBundle() async {
    final jsonStr = await exportAll();
    final archive = Archive();
    final jsonBytes = utf8.encode(jsonStr);
    archive.addFile(ArchiveFile('data.json', jsonBytes.length, jsonBytes));
    for (final file in await MaterialFileStore.allFiles()) {
      final bytes = await file.readAsBytes();
      archive.addFile(
        ArchiveFile('materials/${basename(file.path)}', bytes.length, bytes),
      );
    }
    final zipped = ZipEncoder().encode(archive);
    return Uint8List.fromList(zipped!);
  }

  /// Restores a zip bundle produced by [exportBundle]: imports the rows from
  /// `data.json`, then extracts the media files back into the `materials/` dir.
  Future<void> importBundle(Uint8List zipBytes) async {
    final archive = ZipDecoder().decodeBytes(zipBytes);
    final dataFile = archive.files.firstWhere(
      (f) => f.name == 'data.json',
      orElse: () => throw const FormatException('Backup is missing data.json'),
    );
    await importAll(utf8.decode(dataFile.content as List<int>));
    for (final f in archive.files) {
      if (f.isFile && f.name.startsWith('materials/')) {
        final base = f.name.substring('materials/'.length);
        if (base.isEmpty) continue;
        await MaterialFileStore.writeBytes(base, f.content as List<int>);
      }
    }
  }

  /// Preview a zip bundle without writing anything.
  static BackupSummary previewBundle(Uint8List zipBytes) {
    final archive = ZipDecoder().decodeBytes(zipBytes);
    final dataFile = archive.files.firstWhere(
      (f) => f.name == 'data.json',
      orElse: () => throw const FormatException('Backup is missing data.json'),
    );
    return previewBackup(utf8.decode(dataFile.content as List<int>));
  }

  static BackupSummary previewBackup(String jsonStr) {
    final data = _decodeBackup(jsonStr);
    _validateBackup(data);
    return BackupSummary(
      journalCount: _backupList(data, 'journal').length,
      ocdCount: _backupList(data, 'ocd').length,
      delaySessionCount: _backupList(data, 'delay_sessions').length,
      erpExercisePlanCount: _backupList(data, 'erp_exercise_plans').length,
      erpExerciseSessionCount: _backupList(
        data,
        'erp_exercise_sessions',
      ).length,
      exposureHierarchyCount: _backupList(data, 'exposure_hierarchies').length,
      exposureStepCount: _backupList(data, 'exposure_steps').length,
      responsePreventionCount: _backupList(
        data,
        'response_prevention_logs',
      ).length,
      urgeSurfCount: _backupList(data, 'urge_surf_sessions').length,
      programEnrollmentCount: _backupList(data, 'program_enrollments').length,
      programTaskProgressCount: _backupList(
        data,
        'program_task_progress',
      ).length,
      behavioralExperimentCount: _backupList(
        data,
        'behavioral_experiments',
      ).length,
      exposureReflectionCount: _backupList(data, 'exposure_reflections').length,
      actionPlanCount: _backupList(data, 'action_plans').length,
      implementationIntentionCount: _backupList(
        data,
        'implementation_intentions',
      ).length,
      uncertaintyLogCount: _backupList(data, 'uncertainty_log').length,
      exposureMaterialCount: _backupList(data, 'exposure_materials').length,
      ybocsAssessmentCount: _backupList(data, 'ybocs_assessments').length,
    );
  }

  static Map<String, dynamic> _decodeBackup(String jsonStr) {
    final decoded = jsonDecode(jsonStr);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Backup root must be an object');
    }
    return decoded;
  }

  static void _validateBackup(Map<String, dynamic> data) {
    final schemaVersion = data['schema_version'];
    // Reject only backups *newer* than we understand; older versions (e.g. a
    // v1 export with no delay_sessions) still restore. The `is! int` guard
    // keeps a malformed value a FormatException rather than a raw TypeError.
    if (schemaVersion != null &&
        (schemaVersion is! int || schemaVersion > _backupSchemaVersion)) {
      throw const FormatException('Unsupported backup version');
    }

    final journal = _backupList(data, 'journal');
    final ocd = _backupList(data, 'ocd');
    final delaySessions = _backupList(data, 'delay_sessions');
    final erpExercisePlans = _backupList(data, 'erp_exercise_plans');
    final erpExerciseSessions = _backupList(data, 'erp_exercise_sessions');
    final exposureHierarchies = _backupList(data, 'exposure_hierarchies');
    final exposureSteps = _backupList(data, 'exposure_steps');
    final responsePrevention = _backupList(data, 'response_prevention_logs');
    final urgeSurf = _backupList(data, 'urge_surf_sessions');
    final programEnrollments = _backupList(data, 'program_enrollments');
    final programTaskProgress = _backupList(data, 'program_task_progress');
    final behavioralExperiments = _backupList(data, 'behavioral_experiments');
    final exposureReflections = _backupList(data, 'exposure_reflections');
    final actionPlans = _backupList(data, 'action_plans');
    final implementationIntentions = _backupList(
      data,
      'implementation_intentions',
    );
    final uncertaintyLog = _backupList(data, 'uncertainty_log');
    final exposureMaterials = _backupList(data, 'exposure_materials');
    final ybocsAssessments = _backupList(data, 'ybocs_assessments');
    for (final item in journal) {
      _validateJournalItem(item);
    }
    for (final item in ocd) {
      _validateOcdItem(item);
    }
    for (final item in delaySessions) {
      _validateDelaySessionItem(item);
    }
    for (final item in erpExercisePlans) {
      _validateErpExercisePlanItem(item);
    }
    for (final item in erpExerciseSessions) {
      _validateErpExerciseSessionItem(item);
    }
    for (final item in exposureHierarchies) {
      _validateExposureHierarchyItem(item);
    }
    for (final item in exposureSteps) {
      _validateExposureStepItem(item);
    }
    for (final item in responsePrevention) {
      _validateResponsePreventionItem(item);
    }
    for (final item in urgeSurf) {
      _validateUrgeSurfItem(item);
    }
    for (final item in programEnrollments) {
      _validateProgramEnrollmentItem(item);
    }
    for (final item in programTaskProgress) {
      _validateProgramTaskProgressItem(item);
    }
    for (final item in behavioralExperiments) {
      _validateBehavioralExperimentItem(item);
    }
    for (final item in exposureReflections) {
      _validateExposureReflectionItem(item);
    }
    for (final item in actionPlans) {
      _validateActionPlanItem(item);
    }
    for (final item in implementationIntentions) {
      _validateImplementationIntentionItem(item);
    }
    for (final item in uncertaintyLog) {
      _validateUncertaintyLogItem(item);
    }
    for (final item in exposureMaterials) {
      _validateExposureMaterialItem(item);
    }
    for (final item in ybocsAssessments) {
      _validateYbocsAssessmentItem(item);
    }
  }

  static List<dynamic> _backupList(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return const [];
    if (value is! List) {
      throw FormatException('Expected $key to be a list');
    }
    return value;
  }

  static void _validateJournalItem(dynamic item) {
    if (item is! Map) throw const FormatException('Invalid journal entry');
    _requireString(item, 'date');
    _requireString(item, 'content');
    _requireString(item, 'created_at');
    _requireString(item, 'updated_at');
    DateTime.parse(item['created_at'] as String);
    DateTime.parse(item['updated_at'] as String);
  }

  static void _validateOcdItem(dynamic item) {
    if (item is! Map) throw const FormatException('Invalid OCD entry');
    _requireInt(item, 'type');
    _requireString(item, 'datetime');
    _requireString(item, 'content');
    _requireInt(item, 'distress_level');
    _requireString(item, 'response');
    _requireString(item, 'created_at');
    if (item['action_taken'] != null && item['action_taken'] is! String) {
      throw const FormatException('Invalid action taken');
    }
    final type = item['type'] as int;
    final distress = item['distress_level'] as int;
    if (type < 0 || type >= OcdType.values.length) {
      throw const FormatException('Invalid OCD entry type');
    }
    if (distress < 0 || distress > 10) {
      throw const FormatException('Invalid distress level');
    }
    DateTime.parse(item['datetime'] as String);
    DateTime.parse(item['created_at'] as String);
  }

  static void _validateErpExercisePlanItem(dynamic item) {
    if (item is! Map) {
      throw const FormatException('Invalid ERP exercise plan');
    }
    _requireString(item, 'exercise_id');
    _requireString(item, 'exercise_title');
    _requireString(item, 'trigger_or_exposure');
    _requireString(item, 'fear_prediction');
    _requireString(item, 'prevention_commitment');
    _requireInt(item, 'default_seconds');
    _requireInt(item, 'archived');
    _requireString(item, 'created_at');
    _requireString(item, 'updated_at');
    final archived = item['archived'] as int;
    if (archived != 0 && archived != 1) {
      throw const FormatException('Invalid ERP exercise plan archive state');
    }
    DateTime.parse(item['created_at'] as String);
    DateTime.parse(item['updated_at'] as String);
  }

  static void _validateErpExerciseSessionItem(dynamic item) {
    if (item is! Map) {
      throw const FormatException('Invalid ERP exercise session');
    }
    if (item['plan_id'] != null && item['plan_id'] is! int) {
      throw const FormatException('Invalid ERP exercise plan id');
    }
    _requireString(item, 'exercise_id');
    _requireString(item, 'exercise_title');
    _requireString(item, 'trigger_or_exposure');
    _requireString(item, 'fear_prediction');
    _requireString(item, 'prevention_commitment');
    _requireInt(item, 'planned_seconds');
    _requireInt(item, 'actual_seconds');
    _requireInt(item, 'completed');
    _requireInt(item, 'anxiety_before');
    _requireInt(item, 'anxiety_after');
    _requireInt(item, 'outcome');
    _requireString(item, 'what_happened');
    _requireString(item, 'learning');
    _requireString(item, 'created_at');
    if (item['note'] != null && item['note'] is! String) {
      throw const FormatException('Invalid ERP exercise session note');
    }
    final anxietyBefore = item['anxiety_before'] as int;
    final anxietyAfter = item['anxiety_after'] as int;
    final outcome = item['outcome'] as int;
    if (anxietyBefore < 0 ||
        anxietyBefore > 10 ||
        anxietyAfter < 0 ||
        anxietyAfter > 10) {
      throw const FormatException('Invalid anxiety level');
    }
    if (outcome < 0 || outcome >= DelayOutcome.values.length) {
      throw const FormatException('Invalid ERP exercise outcome');
    }
    DateTime.parse(item['created_at'] as String);
  }

  static void _validateDelaySessionItem(dynamic item) {
    if (item is! Map) throw const FormatException('Invalid delay session');
    _requireString(item, 'compulsion');
    _requireInt(item, 'planned_seconds');
    _requireInt(item, 'actual_seconds');
    _requireInt(item, 'completed');
    _requireInt(item, 'urge_before');
    _requireInt(item, 'urge_after');
    _requireInt(item, 'outcome');
    _requireString(item, 'created_at');
    if (item['note'] != null && item['note'] is! String) {
      throw const FormatException('Invalid delay session note');
    }
    final urgeBefore = item['urge_before'] as int;
    final urgeAfter = item['urge_after'] as int;
    final outcome = item['outcome'] as int;
    if (urgeBefore < 0 || urgeBefore > 10 || urgeAfter < 0 || urgeAfter > 10) {
      throw const FormatException('Invalid urge level');
    }
    if (outcome < 0 || outcome >= DelayOutcome.values.length) {
      throw const FormatException('Invalid delay outcome');
    }
    DateTime.parse(item['created_at'] as String);
  }

  static void _validateExposureHierarchyItem(dynamic item) {
    if (item is! Map) {
      throw const FormatException('Invalid exposure hierarchy');
    }
    _requireString(item, 'title');
    _requireString(item, 'theme');
    _requireInt(item, 'archived');
    _requireString(item, 'created_at');
    _requireString(item, 'updated_at');
    final archived = item['archived'] as int;
    if (archived != 0 && archived != 1) {
      throw const FormatException('Invalid exposure hierarchy archive state');
    }
    DateTime.parse(item['created_at'] as String);
    DateTime.parse(item['updated_at'] as String);
  }

  static void _validateExposureStepItem(dynamic item) {
    if (item is! Map) {
      throw const FormatException('Invalid exposure step');
    }
    if (item['hierarchy_id'] != null && item['hierarchy_id'] is! int) {
      throw const FormatException('Invalid exposure step hierarchy id');
    }
    _requireInt(item, 'order_index');
    _requireString(item, 'description');
    _requireInt(item, 'difficulty');
    _requireInt(item, 'anxiety_rating');
    _requireInt(item, 'status');
    if (item['completed_at'] != null && item['completed_at'] is! String) {
      throw const FormatException('Invalid exposure step completed_at');
    }
    final difficulty = item['difficulty'] as int;
    final anxiety = item['anxiety_rating'] as int;
    final status = item['status'] as int;
    if (difficulty < 0 || difficulty > 10 || anxiety < 0 || anxiety > 10) {
      throw const FormatException('Invalid exposure step rating');
    }
    if (status < 0 || status >= ExposureStepStatus.values.length) {
      throw const FormatException('Invalid exposure step status');
    }
    if (item['completed_at'] != null) {
      DateTime.parse(item['completed_at'] as String);
    }
  }

  static void _validateResponsePreventionItem(dynamic item) {
    if (item is! Map) {
      throw const FormatException('Invalid response prevention log');
    }
    _requireString(item, 'datetime');
    _requireString(item, 'situation');
    _requireInt(item, 'outcome');
    _requireInt(item, 'anxiety_level');
    _requireString(item, 'created_at');
    if (item['note'] != null && item['note'] is! String) {
      throw const FormatException('Invalid response prevention note');
    }
    if (item['linked_step_id'] != null && item['linked_step_id'] is! int) {
      throw const FormatException('Invalid response prevention step id');
    }
    final outcome = item['outcome'] as int;
    final anxiety = item['anxiety_level'] as int;
    if (outcome < 0 || outcome >= ResponseOutcome.values.length) {
      throw const FormatException('Invalid response prevention outcome');
    }
    if (anxiety < 0 || anxiety > 10) {
      throw const FormatException('Invalid response prevention anxiety');
    }
    DateTime.parse(item['datetime'] as String);
    DateTime.parse(item['created_at'] as String);
  }

  static void _validateUrgeSurfItem(dynamic item) {
    if (item is! Map) {
      throw const FormatException('Invalid urge surf session');
    }
    _requireString(item, 'datetime');
    _requireString(item, 'trigger');
    _requireInt(item, 'initial_urge');
    _requireInt(item, 'peak_urge');
    _requireInt(item, 'final_urge');
    _requireInt(item, 'duration_seconds');
    _requireString(item, 'created_at');
    if (item['note'] != null && item['note'] is! String) {
      throw const FormatException('Invalid urge surf note');
    }
    for (final key in ['initial_urge', 'peak_urge', 'final_urge']) {
      final value = item[key] as int;
      if (value < 0 || value > 10) {
        throw const FormatException('Invalid urge level');
      }
    }
    DateTime.parse(item['datetime'] as String);
    DateTime.parse(item['created_at'] as String);
  }

  static void _validateProgramEnrollmentItem(dynamic item) {
    if (item is! Map) {
      throw const FormatException('Invalid program enrollment');
    }
    _requireString(item, 'program_id');
    _requireString(item, 'created_at');
    DateTime.parse(item['created_at'] as String);
  }

  static void _validateProgramTaskProgressItem(dynamic item) {
    if (item is! Map) {
      throw const FormatException('Invalid program task progress');
    }
    _requireInt(item, 'enrollment_id');
    _requireInt(item, 'week_index');
    _requireString(item, 'task_id');
    _requireString(item, 'completed_at');
    DateTime.parse(item['completed_at'] as String);
  }

  static void _validateBehavioralExperimentItem(dynamic item) {
    if (item is! Map) {
      throw const FormatException('Invalid behavioral experiment');
    }
    _requireString(item, 'datetime');
    _requireString(item, 'fear_prediction');
    _requireInt(item, 'confidence');
    _requireString(item, 'experiment');
    _requireString(item, 'outcome');
    _requireString(item, 'learning');
    _requireInt(item, 'status');
    _requireString(item, 'created_at');
    final confidence = item['confidence'] as int;
    final status = item['status'] as int;
    if (confidence < 0 || confidence > 100) {
      throw const FormatException('Invalid experiment confidence');
    }
    if (status < 0 || status >= ExperimentStatus.values.length) {
      throw const FormatException('Invalid experiment status');
    }
    DateTime.parse(item['datetime'] as String);
    DateTime.parse(item['created_at'] as String);
  }

  static void _validateExposureReflectionItem(dynamic item) {
    if (item is! Map) {
      throw const FormatException('Invalid exposure reflection');
    }
    _requireString(item, 'datetime');
    _requireString(item, 'what_happened');
    _requireString(item, 'ocd_predicted');
    _requireString(item, 'actually_happened');
    _requireString(item, 'what_i_learned');
    _requireString(item, 'do_differently');
    _requireString(item, 'created_at');
    DateTime.parse(item['datetime'] as String);
    DateTime.parse(item['created_at'] as String);
  }

  static void _validateActionPlanItem(dynamic item) {
    if (item is! Map) throw const FormatException('Invalid action plan');
    _requireString(item, 'situation');
    _requireString(item, 'planned_action');
    _requireInt(item, 'completed');
    _requireString(item, 'created_at');
    if (item['date'] != null && item['date'] is! String) {
      throw const FormatException('Invalid action plan date');
    }
    if (item['notes'] != null && item['notes'] is! String) {
      throw const FormatException('Invalid action plan notes');
    }
    final completed = item['completed'] as int;
    if (completed != 0 && completed != 1) {
      throw const FormatException('Invalid action plan completed state');
    }
    DateTime.parse(item['created_at'] as String);
  }

  static void _validateImplementationIntentionItem(dynamic item) {
    if (item is! Map) {
      throw const FormatException('Invalid implementation intention');
    }
    _requireString(item, 'trigger');
    _requireString(item, 'response');
    _requireString(item, 'created_at');
    DateTime.parse(item['created_at'] as String);
  }

  static void _validateUncertaintyLogItem(dynamic item) {
    if (item is! Map) throw const FormatException('Invalid uncertainty log');
    _requireString(item, 'datetime');
    _requireString(item, 'exercise_id');
    _requireInt(item, 'willingness');
    _requireString(item, 'created_at');
    if (item['note'] != null && item['note'] is! String) {
      throw const FormatException('Invalid uncertainty log note');
    }
    final willingness = item['willingness'] as int;
    if (willingness < 0 || willingness > 10) {
      throw const FormatException('Invalid uncertainty willingness');
    }
    DateTime.parse(item['datetime'] as String);
    DateTime.parse(item['created_at'] as String);
  }

  static void _validateExposureMaterialItem(dynamic item) {
    if (item is! Map) {
      throw const FormatException('Invalid exposure material');
    }
    _requireInt(item, 'type');
    _requireString(item, 'title');
    _requireString(item, 'created_at');
    for (final key in ['text', 'url', 'file_name']) {
      if (item[key] != null && item[key] is! String) {
        throw FormatException('Invalid exposure material $key');
      }
    }
    if (item['linked_hierarchy_id'] != null &&
        item['linked_hierarchy_id'] is! int) {
      throw const FormatException('Invalid exposure material hierarchy id');
    }
    if (item['linked_step_id'] != null && item['linked_step_id'] is! int) {
      throw const FormatException('Invalid exposure material step id');
    }
    final type = item['type'] as int;
    if (type < 0 || type >= MaterialType.values.length) {
      throw const FormatException('Invalid exposure material type');
    }
    DateTime.parse(item['created_at'] as String);
  }

  static void _validateYbocsAssessmentItem(dynamic item) {
    if (item is! Map) throw const FormatException('Invalid Y-BOCS assessment');
    _requireString(item, 'datetime');
    _requireInt(item, 'obsession_score');
    _requireInt(item, 'compulsion_score');
    _requireInt(item, 'total_score');
    _requireInt(item, 'severity');
    _requireString(item, 'item_scores');
    _requireString(item, 'created_at');
    for (final key in ['themes', 'symptoms']) {
      if (item[key] != null && item[key] is! String) {
        throw FormatException('Invalid Y-BOCS assessment $key');
      }
    }
    final obsession = item['obsession_score'] as int;
    final compulsion = item['compulsion_score'] as int;
    final total = item['total_score'] as int;
    final severity = item['severity'] as int;
    if (obsession < 0 || obsession > 20 || compulsion < 0 || compulsion > 20) {
      throw const FormatException('Invalid Y-BOCS subscore');
    }
    if (total < 0 || total > 40) {
      throw const FormatException('Invalid Y-BOCS total score');
    }
    if (severity < 0 || severity >= YbocsSeverity.values.length) {
      throw const FormatException('Invalid Y-BOCS severity');
    }
    final itemScores = item['item_scores'] as String;
    if (itemScores.trim().isNotEmpty) {
      for (final part in itemScores.split(',')) {
        final score = int.tryParse(part.trim());
        if (score == null || score < 0 || score > 4) {
          throw const FormatException('Invalid Y-BOCS item score');
        }
      }
    }
    DateTime.parse(item['datetime'] as String);
    DateTime.parse(item['created_at'] as String);
  }

  static void _requireString(Map<dynamic, dynamic> item, String key) {
    if (item[key] is! String) {
      throw FormatException('Expected $key to be a string');
    }
  }

  static void _requireInt(Map<dynamic, dynamic> item, String key) {
    if (item[key] is! int) {
      throw FormatException('Expected $key to be an integer');
    }
  }
}
