import 'package:go_router/go_router.dart';
import '../features/notes/presentation/pages/notes_list_page.dart';
import '../features/notes/presentation/pages/note_edit_page.dart';

/// Configuración de las rutas de la aplicación usando GoRouter
final router = GoRouter(
  initialLocation: '/',
  routes: [
    // Ruta principal - Lista de notas
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const NotesListPage(),
    ),
    
    // Ruta para crear/editar nota
    GoRoute(
      path: '/note/:id',
      name: 'note',
      builder: (context, state) {
        final noteId = state.pathParameters['id'];
        return NoteEditPage(noteId: noteId);
      },
    ),
  ],
);
