import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'media_entity.dart';
import 'tag_entity_db.dart';
import 'note_entity_db.dart';
import 'user_settings_db.dart';
import 'change_log_entity.dart';
import 'ai_cache_entity.dart';

class DatabaseService {
  static late Isar _db;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    final dir = await getApplicationDocumentsDirectory();
    
    _db = await Isar.open([
      MediaEntitySchema,
      TagEntityDbSchema,
      NoteEntityDbSchema,
      UserSettingsDbSchema,
      ChangeLogEntitySchema,
      AiCacheEntitySchema,
    ], directory: dir.path);

    // Initialize default settings if not exists
    if (await _db.userSettingsDbs.isEmpty()) {
      final defaultSettings = UserSettingsDb()
        ..id = 0
        ..fileOrganizationMode = 'Virtual'
        ..theme = 'Dark'
        ..language = 'en'
        ..tagSortMode = 'ByCount'
        ..layoutMode = 'Justified'
        ..fontSize = 14
        ..showTagCount = true
        ..showNsfwContent = false;
      
      await _db.writeTxn(() => _db.userSettingsDbs.put(defaultSettings));
    }

    _isInitialized = true;
  }

  static Isar get db {
    if (!_isInitialized) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _db;
  }

  // Media operations
  static Future<List<MediaEntity>> getAllMedia({
    int offset = 0,
    int limit = 50,
    String? type,
    List<String>? tagIds,
    bool? isNsfw,
  }) async {
    var query = _db.mediaEntities.where();

    if (type != null) {
      query = query.filter((m) => m.type == type);
    }

    if (isNsfw != null) {
      query = query.filter((m) => m.isNsfw == isNsfw);
    }

    if (tagIds != null && tagIds.isNotEmpty) {
      query = query.anyTags((q) => q.anyOf(tagIds));
    }

    return query
        .sortByDateAdded(descending: true)
        .offset(offset)
        .limit(limit)
        .findAll();
  }

  static Future<MediaEntity?> getMediaById(int id) async {
    return _db.mediaEntities.get(id);
  }

  static Future<MediaEntity?> getMediaByPath(String path) async {
    return _db.mediaEntities.filter().pathEqualTo(path).findFirst();
  }

  static Future<void> addMedia(MediaEntity media) async {
    await _db.writeTxn(() => _db.mediaEntities.put(media));
    await _logChange('media', media.id!, 'create', {});
  }

  static Future<void> updateMedia(MediaEntity media) async {
    await _db.writeTxn(() => _db.mediaEntities.put(media));
    await _logChange('media', media.id!, 'update', {});
  }

  static Future<void> deleteMedia(int id) async {
    await _db.writeTxn(() => _db.mediaEntities.delete(id));
    await _logChange('media', id, 'delete', {});
  }

  static Future<int> getTotalMediaCount() async {
    return _db.mediaEntities.count();
  }

  // Tag operations
  static Future<List<TagEntityDb>> getAllTags({
    String? sortBy, // 'usageCount', 'name', 'frequency'
    bool descending = true,
  }) async {
    var query = _db.tagEntityDbs.where();

    switch (sortBy) {
      case 'usageCount':
        return query.sortByUsageCount(descending: descending).findAll();
      case 'name':
        return query.sortByName().findAll();
      default:
        return query.sortByUsageCount(descending: true).findAll();
    }
  }

  static Future<TagEntityDb?> getTagByName(String name) async {
    return _db.tagEntityDbs.filter().nameEqualTo(name).findFirst();
  }

  static Future<void> addTag(TagEntityDb tag) async {
    await _db.writeTxn(() => _db.tagEntityDbs.put(tag));
    await _logChange('tag', tag.id!, 'create', {});
  }

  static Future<void> updateTag(TagEntityDb tag) async {
    await _db.writeTxn(() => _db.tagEntityDbs.put(tag));
    await _logChange('tag', tag.id!, 'update', {});
  }

  static Future<void> deleteTag(int id) async {
    await _db.writeTxn(() => _db.tagEntityDbs.delete(id));
    await _logChange('tag', id, 'delete', {});
  }

  static Future<void> incrementTagUsage(List<int> tagIds) async {
    await _db.writeTxn(() async {
      for (final id in tagIds) {
        final tag = await _db.tagEntityDbs.get(id);
        if (tag != null) {
          tag.usageCount++;
          await _db.tagEntityDbs.put(tag);
        }
      }
    });
  }

  // Settings operations
  static Future<UserSettingsDb> getSettings() async {
    final settings = await _db.userSettingsDbs.get(0);
    if (settings == null) {
      throw Exception('Settings not found');
    }
    return settings;
  }

  static Future<void> updateSettings(UserSettingsDb settings) async {
    settings.id = 0;
    await _db.writeTxn(() => _db.userSettingsDbs.put(settings));
  }

  // Change log operations
  static Future<void> _logChange(
    String entityType,
    int entityId,
    String operation,
    Map<String, dynamic> changes,
  ) async {
    final changeLog = ChangeLogEntity()
      ..entityType = entityType
      ..entityId = entityId
      ..operation = operation
      ..timestamp = DateTime.now()
      ..changes = changes
      ..deviceId = 'local_device';

    await _db.changeLogEntities.put(changeLog);

    // Keep only last 30 days
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    await _db.writeTxn(() async {
      final oldLogs = await _db.changeLogEntities
          .filter()
          .timestampLessThan(thirtyDaysAgo)
          .findAll();
      await _db.changeLogEntities.deleteAll(oldLogs.map((e) => e.id!).toList());
    });
  }

  static Future<List<ChangeLogEntity>> getChangesSince(DateTime since) async {
    return _db.changeLogEntities
        .filter()
        .timestampGreaterThan(since)
        .sortByTimestamp(descending: true)
        .findAll();
  }

  // AI Cache operations
  static Future<List<String>?> getCachedTags(String imageHash) async {
    final cache = await _db.aiCacheEntities
        .filter()
        .imageHashEqualTo(imageHash)
        .findFirst();
    
    if (cache == null) return null;
    
    final ninetyDaysAgo = DateTime.now().subtract(const Duration(days: 90));
    if (cache.cachedAt.isBefore(ninetyDaysAgo)) {
      await _db.aiCacheEntities.delete(cache.id!);
      return null;
    }

    return [];
  }

  static Future<void> cacheTags(String imageHash, List<String> tags) async {
    final cache = AiCacheEntity()
      ..imageHash = imageHash
      ..tagsJson = '[]'
      ..cachedAt = DateTime.now();

    await _db.writeTxn(() => _db.aiCacheEntities.put(cache));
  }

  // Search operations
  static Future<List<MediaEntity>> searchMedia({
    List<String> includeTags = const [],
    List<String> excludeTags = const [],
    List<String> orTags = const [],
    String? type,
    int offset = 0,
    int limit = 50,
  }) async {
    var query = _db.mediaEntities.where();

    if (type != null) {
      query = query.filter((m) => m.type == type);
    }

    if (includeTags.isNotEmpty) {
      query = query.anyTags((q) => q.allOf(includeTags));
    }

    if (excludeTags.isNotEmpty) {
      query = query.not().anyTags((q) => q.anyOf(excludeTags));
    }

    if (orTags.isNotEmpty) {
      query = query.anyTags((q) => q.anyOf(orTags));
    }

    return query
        .sortByDateAdded(descending: true)
        .offset(offset)
        .limit(limit)
        .findAll();
  }

  static Future<void> close() async {
    await _db.close();
    _isInitialized = false;
  }
}
