import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_bloc_notas_inteligente/core/models/note.dart';
import 'package:mini_bloc_notas_inteligente/features/notes/data/notes_repository.dart';

// Provider del repositorio
final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository();
});

// Provider que gestiona la lista de notas
final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  late final NotesRepository _repo;

  @override
  Future<List<Note>> build() async {
    _repo = ref.read(notesRepositoryProvider);
    return _repo.getNotes();
  }

  Future<void> addNote(Note note) async {
    await _repo.addNote(note);
    state = AsyncValue.data(await _repo.getNotes());
  }

  Future<void> updateNote(Note note) async {
    await _repo.updateNote(note);
    state = AsyncValue.data(await _repo.getNotes());
  }

  Future<void> deleteNote(int id) async {
    await _repo.deleteNote(id);
    state = AsyncValue.data(await _repo.getNotes());
  }

  Future<void> reloadNotes() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _repo.getNotes());
  }
}
