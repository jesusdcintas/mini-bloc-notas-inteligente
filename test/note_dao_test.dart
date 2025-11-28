import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mini_bloc_notas_inteligente/core/database/app_database.dart';
import 'package:mini_bloc_notas_inteligente/core/database/note_dao.dart';
import 'package:mini_bloc_notas_inteligente/core/models/note.dart';

void main() {
  // Initialize ffi for sqflite when running on the Dart VM (tests)
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late NoteDao dao;

  setUp(() async {
    db = await openDatabase(inMemoryDatabasePath, version: 1,
        onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE notes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          content TEXT
        )
      ''');
    });

    await AppDatabase.setDatabaseForTest(db);
    dao = NoteDao();
  });

  tearDown(() async {
    await AppDatabase.close();
  });

  test('insert and get notes', () async {
    final note = Note(title: 'Test', content: 'Content');
    final id = await dao.insertNote(note);
    expect(id, greaterThan(0));

    final notes = await dao.getNotes();
    expect(notes.length, 1);
    expect(notes.first.title, 'Test');
  });

  test('update note', () async {
    await dao.insertNote(Note(title: 'A', content: 'B'));
    final notes = await dao.getNotes();
    final note = notes.first;

    final updated = Note(id: note.id, title: 'Updated', content: 'New');
    final count = await dao.updateNote(updated);
    expect(count, 1);

    final all = await dao.getNotes();
    expect(all.first.title, 'Updated');
  });

  test('delete note', () async {
    await dao.insertNote(Note(title: 'X', content: 'Y'));
    var notes = await dao.getNotes();
    expect(notes, isNotEmpty);

    final deleted = await dao.deleteNote(notes.first.id!);
    expect(deleted, 1);

    final remaining = await dao.getNotes();
    expect(remaining, isEmpty);
  });
}
