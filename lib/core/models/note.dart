class Note {
	final int? id;
	final String title;
	final String content;

	Note({this.id, required this.title, required this.content});

	Map<String, Object?> toMap() {
		return {
			'id': id,
			'title': title,
			'content': content,
		};
	}

	factory Note.fromMap(Map<String, Object?> map) {
		return Note(
			id: map['id'] is int ? map['id'] as int : (map['id'] as num?)?.toInt(),
			title: (map['title'] ?? '') as String,
			content: (map['content'] ?? '') as String,
		);
	}

	Note copyWith({int? id, String? title, String? content}) {
		return Note(
			id: id ?? this.id,
			title: title ?? this.title,
			content: content ?? this.content,
		);
	}
}
