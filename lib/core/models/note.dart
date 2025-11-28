/// Modelo que representa una nota en la aplicación
class Note {
  final int? id;
  final String title;
  final String content;

  Note({
    this.id,
    required this.title,
    required this.content,
  });

  /// Crear una Note desde un Map (útil para SQLite)
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
    );
  }

  /// Convertir Note a Map (útil para SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
    };
  }

  /// Crear una copia de la nota con campos modificados
  Note copyWith({
    int? id,
    String? title,
    String? content,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }

  @override
  String toString() => 'Note(id: $id, title: $title, content: $content)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Note &&
        other.id == id &&
        other.title == title &&
        other.content == content;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ content.hashCode;
}
