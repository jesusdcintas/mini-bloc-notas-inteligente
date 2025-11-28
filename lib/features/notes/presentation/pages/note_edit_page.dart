import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme.dart';
import '../../../../core/models/note.dart';
import '../../../../core/services/ai_service.dart';
import '../../providers/notes_provider.dart';
import '../widgets/note_form.dart';

/// Pantalla para crear o editar una nota
class NoteEditPage extends ConsumerStatefulWidget {
  /// ID de la nota a editar. Si es null o 'new', se crea una nueva nota.
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
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _isEditing ? Icons.edit_rounded : Icons.add_circle_rounded,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(_isEditing ? 'Editar Nota' : 'Nueva Nota'),
            ],
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
          ),
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
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
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: _isLoading 
                    ? Colors.white.withAlpha(30) 
                    : AppTheme.tertiaryColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: _isLoading ? null : [
                  BoxShadow(
                    color: AppTheme.tertiaryColor.withAlpha(100),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextButton.icon(
                onPressed: _isLoading ? null : _saveNote,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white70),
                        ),
                      )
                    : const Icon(Icons.save_rounded, color: Colors.white),
                label: Text(
                  'Guardar',
                  style: TextStyle(
                    color: _isLoading ? Colors.white70 : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.backgroundColor,
                Colors.white,
              ],
            ),
          ),
          child: Padding(
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
      ),
    );
  }

  /// Guardar la nota
  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.white),
              const SizedBox(width: 10),
              const Text('La nota debe tener título o contenido'),
            ],
          ),
          backgroundColor: AppTheme.tertiaryColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(notesProvider.notifier);
      
      if (_isEditing && _existingNote != null) {
        // Actualizar nota existente
        await notifier.updateNote(
          Note(
            id: _existingNote!.id,
            title: title.isEmpty ? 'Sin título' : title,
            content: content,
          ),
        );
      } else {
        // Crear nueva nota
        await notifier.addNote(
          Note(
            title: title.isEmpty ? 'Sin título' : title,
            content: content,
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Text(_isEditing ? '¡Nota actualizada!' : '¡Nota creada!'),
              ],
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
        setState(() => _hasChanges = false);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Text('Error: $e'),
              ],
            ),
            backgroundColor: AppTheme.errorColor,
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
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_rounded, color: Colors.white),
              const SizedBox(width: 10),
              const Text('Escribe algo para resumir'),
            ],
          ),
          backgroundColor: AppTheme.tertiaryColor,
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
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                const SizedBox(width: 10),
                const Text('✨ Texto resumido con IA'),
              ],
            ),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Text('Error al resumir: $e'),
              ],
            ),
            backgroundColor: AppTheme.errorColor,
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
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_rounded, color: Colors.white),
              const SizedBox(width: 10),
              const Text('Escribe algo para mejorar'),
            ],
          ),
          backgroundColor: AppTheme.tertiaryColor,
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
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                const SizedBox(width: 10),
                const Text('✨ Texto mejorado con IA'),
              ],
            ),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Text('Error al mejorar: $e'),
              ],
            ),
            backgroundColor: AppTheme.errorColor,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.tertiaryColor.withAlpha(40),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.warning_rounded, color: AppTheme.tertiaryColor),
            ),
            const SizedBox(width: 12),
            const Text('¿Descartar cambios?'),
          ],
        ),
        content: const Text(
          'Tienes cambios sin guardar. ¿Quieres descartarlos?',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
