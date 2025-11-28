import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mini_bloc_notas_inteligente/core/database/app_database.dart';
import 'package:mini_bloc_notas_inteligente/core/models/note.dart';
import 'package:mini_bloc_notas_inteligente/features/notes/providers/notes_provider.dart';

void main() {
  // Initialize ffi for sqflite when running on the Dart VM (tests)
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;

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
  });

  tearDown(() async {
    await AppDatabase.close();
  });

  test('NotesNotifier lifecycle and operations', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Ensure initial load completes
    final notifier = container.read(notesProvider.notifier);
    await Future.delayed(const Duration(milliseconds: 50));

    // Add note
    await notifier.addNote(Note(title: 'T1', content: 'C1'));
    var state = container.read(notesProvider);
    expect(state, isA<AsyncValue<List<Note>>>());
    expect(state.asData?.value.length, 1);

    final note = state.asData!.value.first;

    // Update
    await notifier.updateNote(Note(id: note.id, title: 'T2', content: 'C2'));
    state = container.read(notesProvider);
    expect(state.asData!.value.first.title, 'T2');

    // Delete
    await notifier.deleteNote(note.id!);
    state = container.read(notesProvider);
    expect(state.asData!.value, isEmpty);
  });
}
