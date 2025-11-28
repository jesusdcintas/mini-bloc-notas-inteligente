import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/note.dart';
import '../../../../core/services/ai_service.dart';
import '../../providers/notes_provider.dart';
import '../widgets/note_form.dart';

/// Pantalla para crear o editar una nota
class NoteEditPage extends ConsumerStatefulWidget {
  /// ID de la nota a editar. Si es null, se crea una nueva nota.
  final String? noteId;

  const NoteEditPage({super.key, this.noteId});

  @override
  ConsumerState<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends ConsumerState<NoteEditPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _aiService = AIService();
  
  bool _isLoading = false;
  bool _isAILoading = false;
  bool _hasChanges = false;
  Note? _existingNote;

  bool get _isEditing => widget.noteId != null && widget.noteId != 'new';

  @override
  void initState() {
    super.initState();
    _loadNoteIfEditing();
    
    // Detectar cambios
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  void _loadNoteIfEditing() {
    if (_isEditing) {
      // Cargar nota existente
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final noteId = int.tryParse(widget.noteId!);
        if (noteId != null) {
          final note = ref.read(notesProvider.notifier).getNoteById(noteId);
          if (note != null) {
            setState(() {
              _existingNote = note;
              _titleController.text = note.title;
              _contentController.text = note.content;
              _hasChanges = false;
            });
          }
        }
      });
    }
  }

  void _onTextChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final shouldPop = await _showDiscardDialog();
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Editar Nota' : 'Nueva Nota'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (_hasChanges) {
                final shouldPop = await _showDiscardDialog();
                if (shouldPop && context.mounted) {
                  context.pop();
                }
              } else {
                context.pop();
              }
            },
          ),
          actions: [
            // Botón Guardar
            TextButton.icon(
              onPressed: _isLoading ? null : _saveNote,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Guardar'),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: NoteForm(
            titleController: _titleController,
            contentController: _contentController,
            isLoading: _isLoading,
            isAILoading: _isAILoading,
            onSummarize: _summarizeText,
            onImprove: _improveText,
          ),
        ),
      ),
    );
  }

  /// Guardar la nota
  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    // Validación básica
    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La nota debe tener título o contenido'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isEditing && _existingNote != null) {
        // Actualizar nota existente
        final updatedNote = _existingNote!.copyWith(
          title: title.isEmpty ? 'Sin título' : title,
          content: content,
        );
        await ref.read(notesProvider.notifier).updateNote(updatedNote);
      } else {
        // Crear nueva nota
        await ref.read(notesProvider.notifier).createNote(
              title.isEmpty ? 'Sin título' : title,
              content,
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Nota actualizada' : 'Nota creada'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _hasChanges = false);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Resumir el texto con IA
  Future<void> _summarizeText() async {
    final content = _contentController.text.trim();
    
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe algo para resumir'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isAILoading = true);

    try {
      final summary = await _aiService.summarizeText(content);
      _contentController.text = summary;
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Texto resumido'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al resumir: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAILoading = false);
      }
    }
  }

  /// Mejorar el texto con IA
  Future<void> _improveText() async {
    final content = _contentController.text.trim();
    
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe algo para mejorar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isAILoading = true);

    try {
      final improved = await _aiService.improveText(content);
      _contentController.text = improved;
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Texto mejorado'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al mejorar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAILoading = false);
      }
    }
  }

  /// Mostrar diálogo para descartar cambios
  Future<bool> _showDiscardDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Descartar cambios?'),
        content: const Text('Tienes cambios sin guardar. ¿Quieres descartarlos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
