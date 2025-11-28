import 'package:sqflite/sqflite.dart';
import '../models/note.dart';
import 'app_database.dart';

class NoteDao {
  final table = 'notes';

  Future<int> insertNote(Note note) async {
    final db = await AppDatabase.database;
    return await db.insert(table, note.toMap());
  }

  Future<List<Note>> getNotes() async {
    final db = await AppDatabase.database;
    final result = await db.query(table);

    return result.map((map) => Note.fromMap(map)).toList();
  }

  Future<int> updateNote(Note note) async {
    final db = await AppDatabase.database;

    return await db.update(
      table,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await AppDatabase.database;

    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
