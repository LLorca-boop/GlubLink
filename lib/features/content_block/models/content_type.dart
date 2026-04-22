// lib/features/content_block/models/content_type.dart
import 'package:flutter/material.dart';

/// Типы контента в системе
enum ContentType {
  /// Медиафайлы (изображения, видео, аудио)
  media('media', Icons.image, 'Медиа'),
  
  /// Текстовые заметки
  note('note', Icons.note, 'Заметка'),
  
  /// Веб-ссылки
  link('link', Icons.link, 'Ссылка'),
  
  /// Коллекции блоков
  collection('collection', Icons.collections, 'Коллекция');

  const ContentType(this.value, this.icon, this.displayName);

  final String value;
  final IconData icon;
  final String displayName;

  /// Получение типа из строки
  static ContentType fromValue(String value) {
    return ContentType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ContentType.media,
    );
  }
}
