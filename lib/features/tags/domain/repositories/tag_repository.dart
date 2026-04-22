import '../entities/tag_entity.dart';

/// Интерфейс репозитория для работы с тегами
/// Определяет контракт для доступа к данным тегов
abstract class TagRepository {
  /// Получить все теги
  Future<List<TagEntity>> getAll({int? limit, int? offset});

  /// Получить тег по ID
  Future<TagEntity?> getById(String id);

  /// Получить тег по имени
  Future<TagEntity?> getByName(String name);

  /// Создать новый тег
  Future<TagEntity> create(TagEntity tag);

  /// Обновить существующий тег
  Future<TagEntity> update(TagEntity tag);

  /// Удалить тег по ID
  /// Возвращает false если тег защищен
  Future<bool> delete(String id);

  /// Поиск тегов по запросу
  Future<List<TagEntity>> search(String query, {int limit = 50});

  /// Инкремент счетчика использования тега
  Future<void> incrementUsage(String tagId);

  /// Получить теги по категории
  Future<List<TagEntity>> getByCategory(String category, {int limit = 100});

  /// Получить популярные теги
  Future<List<TagEntity>> getPopularTags({int limit = 50});

  /// Получить недавно использованные теги
  Future<List<TagEntity>> getRecentlyUsedTags({int limit = 20});

  /// Проверить существование тега по имени
  Future<bool> existsByName(String name);

  /// Слияние двух тегов
  /// Все использования sourceTag будут перенесены на targetTag
  Future<void> mergeTags(String sourceTagId, String targetTagId);

  /// Удалить тег с заменой на другой
  Future<void> deleteWithReplacement(String tagIdToDelete, String replacementTagId);

  /// Получить связанные теги
  Future<List<TagEntity>> getRelatedTags(String tagId, {int limit = 10});

  /// Массовое создание тегов
  Future<List<TagEntity>> createMany(List<TagEntity> tags);

  /// Очистка кэша и перезагрузка данных
  Future<void> refresh();
}

/// Исключения для репозитория тегов
class TagRepositoryException implements Exception {
  final String message;
  final String? code;

  const TagRepositoryException(this.message, {this.code});

  @override
  String toString() => 'TagRepositoryException: $message (code: $code)';
}

/// Исключение при попытке удалить защищенный тег
class ProtectedTagException extends TagRepositoryException {
  ProtectedTagException(String tagName)
      : super('Cannot delete protected tag: $tagName', code: 'PROTECTED_TAG');
}

/// Исключение при дублировании имени тега
class DuplicateTagException extends TagRepositoryException {
  DuplicateTagException(String tagName)
      : super('Tag with name "$tagName" already exists', code: 'DUPLICATE_TAG');
}

/// Исключение при неверном слиянии тегов
class InvalidMergeException extends TagRepositoryException {
  InvalidMergeException(String message) : super(message, code: 'INVALID_MERGE');
}
