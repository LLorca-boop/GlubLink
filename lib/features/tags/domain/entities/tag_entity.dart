import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag_entity.freezed.dart';
part 'tag_entity.g.dart';

/// Сущность тега в доменном слое
/// Представляет собой неизменяемую модель тега
@freezed
class TagEntity with _$TagEntity {
  const factory TagEntity({
    /// Уникальный идентификатор тега (UUID v4)
    required String id,
    
    /// Имя тега (уникальное, lowercase)
    required String name,
    
    /// Категория тега
    required String category,
    
    /// Описание тега (опционально)
    String? description,
    
    /// Количество использований тега
    @Default(0) int usageCount,
    
    /// Флаг защиты тега (мета-теги нельзя удалять)
    @Default(false) bool isProtected,
    
    /// Дата создания тега
    required DateTime createdAt,
    
    /// Дата последнего использования
    required DateTime lastUsedAt,
  }) = _TagEntity;

  /// Создание нового тега
  factory TagEntity.create({
    required String id,
    required String name,
    required String category,
    String? description,
    bool isProtected = false,
  }) {
    final now = DateTime.now();
    return TagEntity(
      id: id,
      name: name.toLowerCase().trim(),
      category: category,
      description: description,
      usageCount: 0,
      isProtected: isProtected,
      createdAt: now,
      lastUsedAt: now,
    );
  }

  factory TagEntity.fromJson(Map<String, dynamic> json) => 
      _$TagEntityFromJson(json);
}

/// Расширения для работы с тегами
extension TagEntityValidation on TagEntity {
  /// Проверка валидности имени тега
  bool get isValidName {
    final trimmed = name.trim();
    return trimmed.isNotEmpty && 
           trimmed.length <= 50 && 
           RegExp(r'^[a-z0-9_\-\s]+$').hasMatch(trimmed);
  }

  /// Проверка, является ли тег мета-тегом
  bool get isMetaTag => category == 'meta' || isProtected;

  /// Список защищенных имен мета-тегов
  static const List<String> protectedNames = [
    'image',
    'gif',
    'video',
    'audio',
    'note',
    'link',
    'collection',
    'favorite',
    'archived',
    'deleted',
  ];

  /// Проверка, является ли имя защищенным
  static bool isProtectedName(String name) {
    return protectedNames.contains(name.toLowerCase());
  }
}
