/// Note Entity - модель данных для заметок
class NoteEntity {
  final String id;
  final String title;
  final Map<String, dynamic> content; // JSON структура содержимого
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> attachedMedia; // список ID прикрепленных медиа
  final String? parentNoteId; // для вложенности
  final Map<String, int> version; // Vector Clock для синхронизации

  NoteEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.attachedMedia = const [],
    this.parentNoteId,
    Map<String, int>? version,
  }) : version = version ?? {};

  NoteEntity copyWith({
    String? id,
    String? title,
    Map<String, dynamic>? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? attachedMedia,
    String? parentNoteId,
    Map<String, int>? version,
  }) {
    return NoteEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attachedMedia: attachedMedia ?? this.attachedMedia,
      parentNoteId: parentNoteId ?? this.parentNoteId,
      version: version ?? this.version,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'attachedMedia': attachedMedia,
      'parentNoteId': parentNoteId,
      'version': version,
    };
  }

  factory NoteEntity.fromMap(Map<String, dynamic> map) {
    return NoteEntity(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as Map<String, dynamic>,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      attachedMedia: List<String>.from(map['attachedMedia'] ?? []),
      parentNoteId: map['parentNoteId'] as String?,
      version: Map<String, int>.from(map['version'] ?? {}),
    );
  }
}
