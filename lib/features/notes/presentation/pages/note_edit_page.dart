import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_bloc_notas_inteligente/core/models/note.dart';
import 'package:mini_bloc_notas_inteligente/features/notes/providers/notes_provider.dart';
import 'package:mini_bloc_notas_inteligente/core/services/ai_service.dart';

class NoteEditPage extends ConsumerStatefulWidget {
  final Note? note;
  final AiService? aiService;

  const NoteEditPage({super.key, this.note, this.aiService});

  @override
  ConsumerState<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends ConsumerState<NoteEditPage> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  bool _processing = false;

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

  Future<void> _applyAi(bool improve) async {
    final ai = widget.aiService;
    if (ai == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI no configurada')));
      return;
    }

    final text = contentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _processing = true);
    try {
      final result = improve ? await ai.improve(text) : await ai.summarize(text);
      contentController.text = result;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error AI: $e')));
    } finally {
      setState(() => _processing = false);
    }
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
          ),
          if (widget.aiService != null) ...[
            IconButton(
              onPressed: _processing ? null : () => _applyAi(false),
              tooltip: 'Resumir',
              icon: const Icon(Icons.summarize),
            ),
            IconButton(
              onPressed: _processing ? null : () => _applyAi(true),
              tooltip: 'Mejorar',
              icon: const Icon(Icons.edit),
            ),
          ]
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
