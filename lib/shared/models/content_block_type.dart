/// Типы контент-блоков в GlubLink
enum ContentBlockType {
  /// Медиафайл (изображение, видео, аудио)
  media,

  /// Текстовая заметка
  note,

  /// Веб-ссылка
  link,

  /// Коллекция других блоков
  collection,
}

/// Расширение для получения человекочитаемого названия типа
extension ContentBlockTypeExtension on ContentBlockType {
  /// Название типа на русском языке
  String get displayName {
    switch (this) {
      case ContentBlockType.media:
        return 'Медиа';
      case ContentBlockType.note:
        return 'Заметка';
      case ContentBlockType.link:
        return 'Ссылка';
      case ContentBlockType.collection:
        return 'Коллекция';
    }
  }

  /// Иконка для типа блока (название IconData)
  String get iconName {
    switch (this) {
      case ContentBlockType.media:
        return 'image';
      case ContentBlockType.note:
        return 'note';
      case ContentBlockType.link:
        return 'link';
      case ContentBlockType.collection:
        return 'folder';
    }
  }
}
