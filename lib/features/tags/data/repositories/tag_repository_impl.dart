import 'package:isar/isar.dart';
import '../../data/models/tag.dart' as isar_models;
import '../../../domain/entities/tag_entity.dart';
import '../../../domain/repositories/tag_repository.dart';

/// Реализация репозитория тегов с использованием Isar
/// Реализует трёхуровневую систему кэширования:
/// 1. User Cache - недавно использованные теги пользователя
/// 2. Core Tags - базовые популярные теги (~5000)
/// 3. Dynamic Tags - динамически создаваемые теги
class TagRepositoryImpl implements TagRepository {
  final Isar _isar;
  
  // Кэш пользовательских тегов (LRU)
  final Map<String, TagEntity> _userCache = {};
  static const int _maxCacheSize = 500;

  // Кэш core-тегов (популярные)
  final Map<String, TagEntity> _coreTagsCache = {};
  bool _coreTagsLoaded = false;

  TagRepositoryImpl({required Isar isar}) : _isar = isar;

  /// Инициализация репозитория
  Future<void> initialize() async {
    await _loadCoreTags();
  }

  /// Загрузка core-тегов (базовый набор популярных тегов)
  Future<void> _loadCoreTags() async {
    if (_coreTagsLoaded) return;

    final collection = _isar.tags;
    final popularTags = await collection
        .where()
        .isProtectedEqualTo(false)
        .usageCountGreaterOrEqual(10)
        .usageCountSorted()
        .limit(5000)
        .findAll();

    for (final tag in popularTags) {
      _coreTagsCache[tag.id] = _mapToEntity(tag);
    }

    _coreTagsLoaded = true;
  }

  @override
  Future<List<TagEntity>> getAll({int? limit, int? offset}) async {
    final collection = _isar.tags;
    
    var query = collection.where();
    
    if (offset != null && offset > 0) {
      query = query.offset(offset);
    }
    
    if (limit != null) {
      query = query.limit(limit);
    } else {
      query = query.limit(100);
    }

    final tags = await query.findAll();
    return tags.map(_mapToEntity).toList();
  }

  @override
  Future<TagEntity?> getById(String id) async {
    // Проверка user cache
    if (_userCache.containsKey(id)) {
      return _userCache[id];
    }

    // Проверка core cache
    if (_coreTagsCache.containsKey(id)) {
      return _coreTagsCache[id];
    }

    // Поиск в базе данных
    final collection = _isar.tags;
    final tag = await collection.get(id.hashCode);
    
    if (tag == null) return null;

    final entity = _mapToEntity(tag);
    _addToUserCache(entity);
    return entity;
  }

  @override
  Future<TagEntity?> getByName(String name) async {
    final normalizedName = name.toLowerCase().trim();
    
    // Поиск в кэшах по имени
    for (final cache in [_userCache, _coreTagsCache]) {
      for (final entity in cache.values) {
        if (entity.name == normalizedName) {
          return entity;
        }
      }
    }

    // Поиск в базе данных
    final collection = _isar.tags;
    final tag = await collection.filter()
        .nameEqualTo(normalizedName)
        .findFirst();
    
    if (tag == null) return null;

    final entity = _mapToEntity(tag);
    _addToUserCache(entity);
    return entity;
  }

  @override
  Future<TagEntity> create(TagEntity tag) async {
    // Проверка на дубликат
    final exists = await existsByName(tag.name);
    if (exists) {
      throw DuplicateTagException(tag.name);
    }

    final collection = _isar.tags;
    final isarTag = _mapFromEntity(tag);
    
    await _isar.writeTxn(() async {
      await collection.put(isarTag);
    });

    final createdEntity = _mapToEntity(isarTag);
    _addToUserCache(createdEntity);
    return createdEntity;
  }

  @override
  Future<TagEntity> update(TagEntity tag) async {
    final collection = _isar.tags;
    final existingTag = await collection.get(tag.id.hashCode);
    
    if (existingTag == null) {
      throw TagRepositoryException('Tag not found: ${tag.id}', code: 'NOT_FOUND');
    }

    // Проверка на дубликат при изменении имени
    if (existingTag.name != tag.name) {
      final exists = await existsByName(tag.name);
      if (exists) {
        throw DuplicateTagException(tag.name);
      }
    }

    final isarTag = _mapFromEntity(tag);
    
    await _isar.writeTxn(() async {
      await collection.put(isarTag);
    });

    final updatedEntity = _mapToEntity(isarTag);
    _addToUserCache(updatedEntity);
    return updatedEntity;
  }

  @override
  Future<bool> delete(String id) async {
    final entity = await getById(id);
    if (entity == null) {
      return false;
    }

    if (entity.isProtected) {
      throw ProtectedTagException(entity.name);
    }

    final collection = _isar.tags;
    
    await _isar.writeTxn(() async {
      await collection.delete(id.hashCode);
    });

    // Удаление из кэшей
    _userCache.remove(id);
    _coreTagsCache.remove(id);
    
    return true;
  }

  @override
  Future<List<TagEntity>> search(String query, {int limit = 50}) async {
    if (query.trim().isEmpty) {
      return getPopularTags(limit: limit);
    }

    final normalizedQuery = query.toLowerCase().trim();
    final collection = _isar.tags;
    
    // Поиск с частичным совпадением
    final tags = await collection.filter()
        .nameContains(normalizedQuery, caseSensitive: false)
        .or()
        .nameBeginsWith(normalizedQuery, caseSensitive: false)
        .usageCountSorted()
        .limit(limit)
        .findAll();

    final entities = tags.map(_mapToEntity).toList();
    
    // Добавление в user cache
    for (final entity in entities) {
      _addToUserCache(entity);
    }
    
    return entities;
  }

  @override
  Future<void> incrementUsage(String tagId) async {
    final entity = await getById(tagId);
    if (entity == null) {
      throw TagRepositoryException('Tag not found: $tagId', code: 'NOT_FOUND');
    }

    final updatedEntity = entity.copyWith(
      usageCount: entity.usageCount + 1,
      lastUsedAt: DateTime.now(),
    );

    await update(updatedEntity);
  }

  @override
  Future<List<TagEntity>> getByCategory(String category, {int limit = 100}) async {
    final collection = _isar.tags;
    
    final tags = await collection.filter()
        .categoryEqualTo(category)
        .usageCountSorted()
        .limit(limit)
        .findAll();

    return tags.map(_mapToEntity).toList();
  }

  @override
  Future<List<TagEntity>> getPopularTags({int limit = 50}) async {
    final collection = _isar.tags;
    
    final tags = await collection.where()
        .isProtectedEqualTo(false)
        .usageCountSorted()
        .limit(limit)
        .findAll();

    return tags.map(_mapToEntity).toList();
  }

  @override
  Future<List<TagEntity>> getRecentlyUsedTags({int limit = 20}) async {
    final collection = _isar.tags;
    
    final tags = await collection.where()
        .lastUsedAtNotNull()
        .sortByLastUsedAtDesc()
        .limit(limit)
        .findAll();

    return tags.map(_mapToEntity).toList();
  }

  @override
  Future<bool> existsByName(String name) async {
    final normalizedName = name.toLowerCase().trim();
    
    // Проверка в кэшах
    for (final cache in [_userCache, _coreTagsCache]) {
      for (final entity in cache.values) {
        if (entity.name == normalizedName) {
          return true;
        }
      }
    }

    final collection = _isar.tags;
    final count = await collection.filter()
        .nameEqualTo(normalizedName)
        .count();
    
    return count > 0;
  }

  @override
  Future<void> mergeTags(String sourceTagId, String targetTagId) async {
    if (sourceTagId == targetTagId) {
      throw InvalidMergeException('Cannot merge tag with itself');
    }

    final sourceTag = await getById(sourceTagId);
    final targetTag = await getById(targetTagId);

    if (sourceTag == null) {
      throw TagRepositoryException('Source tag not found: $sourceTagId', code: 'NOT_FOUND');
    }

    if (targetTag == null) {
      throw TagRepositoryException('Target tag not found: $targetTagId', code: 'NOT_FOUND');
    }

    if (sourceTag.isProtected) {
      throw ProtectedTagException(sourceTag.name);
    }

    await _isar.writeTxn(() async {
      // Обновление счетчика использования целевого тега
      final updatedTarget = targetTag.copyWith(
        usageCount: targetTag.usageCount + sourceTag.usageCount,
        lastUsedAt: sourceTag.lastUsedAt.isAfter(targetTag.lastUsedAt)
            ? sourceTag.lastUsedAt
            : targetTag.lastUsedAt,
      );

      await _isar.tags.put(_mapFromEntity(updatedTarget));
      
      // Удаление исходного тега
      await _isar.tags.delete(sourceTagId.hashCode);
    });

    // Очистка кэшей
    _userCache.remove(sourceTagId);
    _coreTagsCache.remove(sourceTagId);
  }

  @override
  Future<void> deleteWithReplacement(String tagIdToDelete, String replacementTagId) async {
    final tagToDelete = await getById(tagIdToDelete);
    final replacementTag = await getById(replacementTagId);

    if (tagToDelete == null) {
      throw TagRepositoryException('Tag to delete not found: $tagIdToDelete', code: 'NOT_FOUND');
    }

    if (replacementTag == null) {
      throw TagRepositoryException('Replacement tag not found: $replacementTagId', code: 'NOT_FOUND');
    }

    if (tagToDelete.isProtected) {
      throw ProtectedTagException(tagToDelete.name);
    }

    // Слияние вместо простого удаления
    await mergeTags(tagIdToDelete, replacementTagId);
  }

  @override
  Future<List<TagEntity>> getRelatedTags(String tagId, {int limit = 10}) async {
    final tag = await getById(tagId);
    if (tag == null) {
      return [];
    }

    final collection = _isar.tags;
    final isarTag = await collection.get(tagId.hashCode);
    
    if (isarTag == null) return [];

    final relatedIds = isarTag.getRelatedTags();
    if (relatedIds.isEmpty) {
      // Если нет связанных тегов, вернуть теги из той же категории
      return getByCategory(tag.category, limit: limit);
    }

    final relatedTags = <isar_models.Tag>[];
    for (final id in relatedIds.take(limit)) {
      final relatedTag = await collection.get(id.hashCode);
      if (relatedTag != null) {
        relatedTags.add(relatedTag);
      }
    }

    return relatedTags.map(_mapToEntity).toList();
  }

  @override
  Future<List<TagEntity>> createMany(List<TagEntity> tags) async {
    final createdTags = <TagEntity>[];

    await _isar.writeTxn(() async {
      for (final tag in tags) {
        try {
          final created = await create(tag);
          createdTags.add(created);
        } on DuplicateTagException {
          // Пропуск дубликатов
          continue;
        }
      }
    });

    return createdTags;
  }

  @override
  Future<void> refresh() async {
    _userCache.clear();
    _coreTagsLoaded = false;
    _coreTagsCache.clear();
    await _loadCoreTags();
  }

  /// Добавление тега в user cache с LRU eviction
  void _addToUserCache(TagEntity entity) {
    if (_userCache.length >= _maxCacheSize) {
      // Удаление самого старого элемента
      final oldestKey = _userCache.entries
          .reduce((a, b) => a.value.lastUsedAt.isBefore(b.value.lastUsedAt) ? a : b)
          .key;
      _userCache.remove(oldestKey);
    }
    _userCache[entity.id] = entity;
  }

  /// Маппинг Isar модели в доменную сущность
  TagEntity _mapToEntity(isar_models.Tag tag) {
    return TagEntity(
      id: tag.id,
      name: tag.name,
      category: tag.category,
      description: tag.description,
      usageCount: tag.usageCount,
      isProtected: tag.isProtected,
      createdAt: tag.createdAt,
      lastUsedAt: tag.lastUsedAt,
    );
  }

  /// Маппинг доменной сущности в Isar модель
  isar_models.Tag _mapFromEntity(TagEntity entity) {
    return isar_models.Tag(
      id: entity.id,
      name: entity.name,
      category: entity.category,
      description: entity.description,
      usageCount: entity.usageCount,
      isProtected: entity.isProtected,
      createdAt: entity.createdAt,
      lastUsedAt: entity.lastUsedAt,
    );
  }
}

/// Расширение для сортировки по lastUsedAt
extension on isar_models.IsarCollection<isar_models.Tag> {
  Future<List<isar_models.Tag>> sortByLastUsedAtDesc() async {
    final tags = await where().lastUsedAtNotNull().findAll();
    tags.sort((a, b) => b.lastUsedAt.compareTo(a.lastUsedAt));
    return tags;
  }
}
