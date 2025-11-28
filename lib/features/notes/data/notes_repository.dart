import 'package:mini_bloc_notas_inteligente/core/database/note_dao.dart';
import 'package:mini_bloc_notas_inteligente/core/models/note.dart';

class NotesRepository {
  final NoteDao _dao = NoteDao();

  Future<List<Note>> getNotes() {
    return _dao.getNotes();
  }

  Future<int> addNote(Note note) {
    return _dao.insertNote(note);
  }

  Future<int> updateNote(Note note) {
    return _dao.updateNote(note);
  }

  Future<int> deleteNote(int id) {
    return _dao.deleteNote(id);
  }
}
