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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(notesProvider.notifier).reloadNotes();
            },
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: notesState.when(
        data: (notes) {
          if (notes.isEmpty) {
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

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(notesProvider.notifier).reloadNotes();
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return NoteItem(
                  note: note,
                  onTap: () => context.push('/note/${note.id}'),
                  onDelete: () {
                    ref.read(notesProvider.notifier).deleteNote(note.id!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Nota "${note.title}" eliminada'),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando notas...'),
            ],
          ),
        ),
        error: (err, st) => Center(
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
              Text('$err'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.read(notesProvider.notifier).reloadNotes(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/note/new'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Nota'),
      ),
    );
  }
}
