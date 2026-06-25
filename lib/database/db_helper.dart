import 'dart:convert';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as mobile_sqflite;
import 'package:sqflite_common/sqlite_api.dart';
import '../models/models.dart';

const int _backupSchemaVersion = 3;

class BackupSummary {
  final int journalCount;
  final int ocdCount;
  final int delaySessionCount;
  final int erpExercisePlanCount;
  final int erpExerciseSessionCount;

  const BackupSummary({
    required this.journalCount,
    required this.ocdCount,
    this.delaySessionCount = 0,
    this.erpExercisePlanCount = 0,
    this.erpExerciseSessionCount = 0,
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
        version: 3,
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
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // v2: Compulsion Delay Tool — added the delay_sessions table.
    if (oldVersion < 2) {
      await _createDelaySessionsTable(db);
    }
    // v3: Guided ERP Exercises — added completed exercise sessions.
    if (oldVersion < 3) {
      await _createErpExercisePlansTable(db);
      await _createErpExerciseSessionsTable(db);
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

  Future<void> clearAll() async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete('journal');
      await txn.delete('ocd');
      await txn.delete('delay_sessions');
      await txn.delete('erp_exercise_plans');
      await txn.delete('erp_exercise_sessions');
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
    final data = {
      'schema_version': _backupSchemaVersion,
      'journal': journal,
      'ocd': ocd,
      'delay_sessions': delaySessions,
      'erp_exercise_plans': erpExercisePlans,
      'erp_exercise_sessions': erpExerciseSessions,
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
    });
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
