// lib/features/gallery/domain/repositories/gallery_repository.dart
import '../../../workspaces/data/models/filter_rules.dart';
import '../models/parsed_query.dart';

/// Интерфейс репозитория для работы с галереей контента
abstract class GalleryRepository {
  /// Получает все блоки контента с применёнными фильтрами
  Future<List<String>> getFilteredBlockIds({
    required ParsedQuery query,
    FilterRules? workspaceRules,
    int limit = 1000,
    int offset = 0,
  });

  /// Получает общее количество блоков, соответствующих фильтру
  Future<int> getCount({
    required ParsedQuery query,
    FilterRules? workspaceRules,
  });

  /// Получает блоки для предпросмотра (быстрая выборка)
  Future<List<String>> getPreviewBlocks({
    required List<String> blockIds,
    int maxCount = 50,
  });

  /// Подписывается на изменения блоков (для реактивного обновления)
  Stream<List<String>> watchFilteredBlocks({
    required ParsedQuery query,
    FilterRules? workspaceRules,
  });

  /// Получает контекстные теги для текущей выборки
  Future<Map<String, int>> getContextTags({
    required List<String> blockIds,
    int maxTags = 20,
  });

  /// Очищает кэш галереи
  Future<void> clearCache();
}

/// Исключение при ошибке фильтрации
class GalleryFilterException implements Exception {
  final String message;
  final dynamic originalError;

  const GalleryFilterException(this.message, [this.originalError]);

  @override
  String toString() => 'GalleryFilterException: $message';
}
