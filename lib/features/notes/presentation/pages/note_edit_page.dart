import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_bloc_notas_inteligente/core/models/note.dart';
import 'package:mini_bloc_notas_inteligente/features/notes/providers/notes_provider.dart';

class NoteEditPage extends ConsumerStatefulWidget {
  final Note? note;

  const NoteEditPage({super.key, this.note});

  @override
  ConsumerState<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends ConsumerState<NoteEditPage> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note?.title ?? '');
    contentController = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  void saveNote() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty || content.isEmpty) return;

    final notifier = ref.read(notesProvider.notifier);

    if (widget.note == null) {
      // Crear nueva nota
      await notifier.addNote(
        Note(title: title, content: content),
      );
    } else {
      // Actualizar nota existente
      await notifier.updateNote(
        Note(
          id: widget.note!.id,
          title: title,
          content: content,
        ),
      );
    }

    Navigator.pop(context); // Volver atrás
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? "Nueva nota" : "Editar nota"),
        actions: [
          IconButton(
            onPressed: saveNote,
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Título",
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: "Contenido",
                ),
                maxLines: null,
                expands: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
