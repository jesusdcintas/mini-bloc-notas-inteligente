import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/note.dart';

/// Estado que contiene la lista de notas y el estado de carga
class NotesState {
  final List<Note> notes;
  final bool isLoading;
  final String? error;

  NotesState({
    this.notes = const [],
    this.isLoading = false,
    this.error,
  });

  NotesState copyWith({
    List<Note>? notes,
    bool? isLoading,
    String? error,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier que gestiona el estado de las notas
/// Este archivo será conectado con el repositorio SQLite por tu compañero
class NotesNotifier extends StateNotifier<NotesState> {
  NotesNotifier() : super(NotesState()) {
    // Cargar notas al iniciar
    loadNotes();
  }

  // Lista temporal en memoria (será reemplazada por SQLite)
  final List<Note> _tempNotes = [];
  int _nextId = 1;

  /// Cargar todas las notas desde la base de datos
  Future<void> loadNotes() async {
    state = state.copyWith(isLoading: true);
    try {
      // TODO: Aquí tu compañero conectará con el repositorio SQLite
      // Por ahora usamos la lista temporal
      await Future.delayed(const Duration(milliseconds: 300)); // Simular carga
      state = state.copyWith(notes: List.from(_tempNotes), isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Crear una nueva nota
  Future<void> createNote(String title, String content) async {
    try {
      final newNote = Note(
        id: _nextId++,
        title: title,
        content: content,
      );
      // TODO: Aquí tu compañero insertará en SQLite
      _tempNotes.add(newNote);
      state = state.copyWith(notes: List.from(_tempNotes));
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Actualizar una nota existente
  Future<void> updateNote(Note note) async {
    try {
      // TODO: Aquí tu compañero actualizará en SQLite
      final index = _tempNotes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _tempNotes[index] = note;
        state = state.copyWith(notes: List.from(_tempNotes));
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Eliminar una nota
  Future<void> deleteNote(int id) async {
    try {
      // TODO: Aquí tu compañero eliminará de SQLite
      _tempNotes.removeWhere((n) => n.id == id);
      state = state.copyWith(notes: List.from(_tempNotes));
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Obtener una nota por su ID
  Note? getNoteById(int id) {
    try {
      return state.notes.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// Provider principal para acceder a las notas
final notesProvider = StateNotifierProvider<NotesNotifier, NotesState>((ref) {
  return NotesNotifier();
});
