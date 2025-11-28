import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class AppDatabase {
  static Database? _database;
  static bool _initialized = false;

  /// Inicializar SQLite para Windows/Linux/macOS
  static void _initializeFfi() {
    if (_initialized) return;
    
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _initialized = true;
  }

  static Future<Database> get database async {
    _initializeFfi();
    
    if (_database != null) return _database!;

    _database = await _initDB('notes.db');
    return _database!;
  }

  static Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  static Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT
      )
    ''');
  }

  // Utilities for testing: allow injecting an in-memory database
  static Future<void> setDatabaseForTest(Database db) async {
    if (_database != null) {
      await _database!.close();
    }
    _database = db;
  }

  static Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
