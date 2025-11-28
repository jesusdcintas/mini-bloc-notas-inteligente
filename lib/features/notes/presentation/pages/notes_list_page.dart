import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/notes_provider.dart';
import '../widgets/note_item.dart';

/// Pantalla principal que muestra la lista de notas
class NotesListPage extends ConsumerWidget {
  const NotesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesState = ref.watch(notesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Notas'),
        actions: [
          // Botón de refrescar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(notesProvider.notifier).loadNotes();
            },
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: _buildBody(context, ref, notesState),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/note/new'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Nota'),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, NotesState notesState) {
    // Estado de carga
    if (notesState.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando notas...'),
          ],
        ),
      );
    }

    // Estado de error
    if (notesState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar las notas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              notesState.error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.read(notesProvider.notifier).loadNotes(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    // Lista vacía
    if (notesState.notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_add_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '¡No hay notas todavía!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pulsa el botón + para crear tu primera nota',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
            ),
          ],
        ),
      );
    }

    // Lista de notas
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(notesProvider.notifier).loadNotes();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: notesState.notes.length,
        itemBuilder: (context, index) {
          final note = notesState.notes[index];
          return NoteItem(
            note: note,
            onTap: () => context.push('/note/${note.id}'),
            onDelete: () {
              ref.read(notesProvider.notifier).deleteNote(note.id!);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Nota "${note.title}" eliminada'),
                  action: SnackBarAction(
                    label: 'Deshacer',
                    onPressed: () {
                      // TODO: Implementar deshacer
                      ref.read(notesProvider.notifier).createNote(
                            note.title,
                            note.content,
                          );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
