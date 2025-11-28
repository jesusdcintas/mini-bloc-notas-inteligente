import 'package:flutter/material.dart';

/// Widget del formulario para crear/editar notas
class NoteForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController contentController;
  final bool isLoading;
  final VoidCallback? onSummarize;
  final VoidCallback? onImprove;
  final bool isAILoading;

  const NoteForm({
    super.key,
    required this.titleController,
    required this.contentController,
    this.isLoading = false,
    this.onSummarize,
    this.onImprove,
    this.isAILoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Campo de título
        TextFormField(
          controller: titleController,
          enabled: !isLoading,
          decoration: const InputDecoration(
            labelText: 'Título',
            hintText: 'Escribe el título de tu nota',
            prefixIcon: Icon(Icons.title),
          ),
          textCapitalization: TextCapitalization.sentences,
          maxLines: 1,
        ),
        const SizedBox(height: 16),

        // Campo de contenido
        Expanded(
          child: TextFormField(
            controller: contentController,
            enabled: !isLoading,
            decoration: const InputDecoration(
              labelText: 'Contenido',
              hintText: 'Escribe el contenido de tu nota...',
              alignLabelWithHint: true,
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 100),
                child: Icon(Icons.notes),
              ),
            ),
            textCapitalization: TextCapitalization.sentences,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
          ),
        ),
        const SizedBox(height: 16),

        // Botones de IA
        _buildAIButtons(context),
      ],
    );
  }

  /// Construir los botones de funcionalidad IA
  Widget _buildAIButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withAlpha(51),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la sección
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Funciones de IA',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Botones
          Row(
            children: [
              // Botón Resumir
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isAILoading || isLoading ? null : onSummarize,
                  icon: isAILoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.summarize, size: 18),
                  label: const Text('Resumir'),
                ),
              ),
              const SizedBox(width: 12),
              // Botón Mejorar
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isAILoading || isLoading ? null : onImprove,
                  icon: isAILoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_fix_high, size: 18),
                  label: const Text('Mejorar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
