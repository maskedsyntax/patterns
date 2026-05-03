import 'dart:convert';
import 'dart:io' show Platform;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as mobile_sqflite;
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;
import '../models/models.dart';

const int _backupSchemaVersion = 1;

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
      options: OpenDatabaseOptions(version: 1, onCreate: _createDB),
    );
  }

  DatabaseFactory get _databaseFactory {
    if (Platform.isAndroid || Platform.isIOS) {
      return mobile_sqflite.databaseFactory;
    }

    ffi.sqfliteFfiInit();
    return ffi.databaseFactoryFfi;
  }

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

  Future<int> deleteOcdEntry(int id) async {
    final db = await instance.database;
    return await db.delete('ocd', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete('journal');
      await txn.delete('ocd');
    });
  }

  // Export / Import
  Future<String> exportAll() async {
    final db = await instance.database;
    final journal = await db.query('journal');
    final ocd = await db.query('ocd');
    final data = {
      'schema_version': _backupSchemaVersion,
      'journal': journal,
      'ocd': ocd,
    };
    return jsonEncode(data);
  }

  Future<void> importAll(String jsonStr) async {
    final decoded = jsonDecode(jsonStr);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Backup root must be an object');
    }
    final data = decoded;
    _validateBackup(data);

    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete('journal');
      await txn.delete('ocd');
      for (final item in _backupList(data, 'journal')) {
        await txn.insert('journal', Map<String, dynamic>.from(item));
      }
      for (final item in _backupList(data, 'ocd')) {
        await txn.insert('ocd', Map<String, dynamic>.from(item));
      }
    });
  }

  void _validateBackup(Map<String, dynamic> data) {
    final schemaVersion = data['schema_version'];
    if (schemaVersion != null && schemaVersion != _backupSchemaVersion) {
      throw const FormatException('Unsupported backup version');
    }

    final journal = _backupList(data, 'journal');
    final ocd = _backupList(data, 'ocd');
    for (final item in journal) {
      _validateJournalItem(item);
    }
    for (final item in ocd) {
      _validateOcdItem(item);
    }
  }

  List<dynamic> _backupList(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return const [];
    if (value is! List) {
      throw FormatException('Expected $key to be a list');
    }
    return value;
  }

  void _validateJournalItem(dynamic item) {
    if (item is! Map) throw const FormatException('Invalid journal entry');
    _requireString(item, 'date');
    _requireString(item, 'content');
    _requireString(item, 'created_at');
    _requireString(item, 'updated_at');
    DateTime.parse(item['created_at'] as String);
    DateTime.parse(item['updated_at'] as String);
  }

  void _validateOcdItem(dynamic item) {
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

  void _requireString(Map<dynamic, dynamic> item, String key) {
    if (item[key] is! String) {
      throw FormatException('Expected $key to be a string');
    }
  }

  void _requireInt(Map<dynamic, dynamic> item, String key) {
    if (item[key] is! int) {
      throw FormatException('Expected $key to be an integer');
    }
  }
}
