import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/models.dart';

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
    sqfliteFfiInit();
    final databaseFactory = databaseFactoryFfi;
    
    final dbPath = await getApplicationSupportDirectory();
    final path = join(dbPath.path, filePath);

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _createDB,
      ),
    );
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
    final result = await db.query('journal', orderBy: 'date DESC');
    return result.map((json) => JournalEntry.fromMap(json)).toList();
  }

  Future<JournalEntry?> getJournalEntryByDate(String date) async {
    final db = await instance.database;
    final result = await db.query('journal', where: 'date = ?', whereArgs: [date]);
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
      return await db.update('journal', map, where: 'id = ?', whereArgs: [existing.id]);
    } else {
      return await db.insert('journal', entry.toMap());
    }
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
}
