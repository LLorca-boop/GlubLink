import 'package:isar/isar.dart';
import '../models/tag_category.dart';

/// Isar модель тега для хранения в базе данных
/// Содержит индексы для оптимизации поиска
@collection
class Tag {
  /// Внутренний ID Isar (автоинкремент)
  Id get isarId => id.hashCode;

  /// Уникальный идентификатор тега (UUID v4)
  @Index(unique: true, replace: true)
  late String id;

  /// Имя тега (lowercase, trim)
  @Index(caseSensitive: false)
  late String name;

  /// Категория тега
  @Enumerated(EnumType.name)
  @Index()
  late String category;

  /// Описание тега
  String? description;

  /// Количество использований тега
  @Index()
  late int usageCount;

  /// Флаг защиты тега (мета-теги нельзя удалять)
  @Index()
  @Default(false)
  late bool isProtected;

  /// Дата создания тега
  @Index()
  late DateTime createdAt;

  /// Дата последнего использования
  @Index()
  late DateTime lastUsedAt;

  /// Теги, с которыми этот тег часто используется вместе
  @Ignore()
  List<String> relatedTagIds = [];

  /// Серилизованное поле для связанных тегов
  @Index()
  late String relatedTagIdsJson;

  Tag({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    this.usageCount = 0,
    this.isProtected = false,
    required this.createdAt,
    required this.lastUsedAt,
    List<String>? relatedTagIds,
  }) : relatedTagIdsJson = _serializeRelatedTags(relatedTagIds ?? []);

  /// Создание нового тега
  factory Tag.create({
    required String id,
    required String name,
    required String category,
    String? description,
    bool isProtected = false,
  }) {
    final now = DateTime.now();
    return Tag(
      id: id,
      name: name.toLowerCase().trim(),
      category: category,
      description: description,
      usageCount: 0,
      isProtected: isProtected || _isProtectedName(name),
      createdAt: now,
      lastUsedAt: now,
    );
  }

  /// Проверка, является ли имя защищенным
  static bool _isProtectedName(String name) {
    const protectedNames = [
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
    return protectedNames.contains(name.toLowerCase());
  }

  /// Сериализация связанных тегов
  static String _serializeRelatedTags(List<String> tags) {
    return tags.join(',');
  }

  /// Десериализация связанных тегов
  List<String> _deserializeRelatedTags() {
    if (relatedTagIdsJson.isEmpty) return [];
    return relatedTagIdsJson.split(',').where((s) => s.isNotEmpty).toList();
  }

  /// Обновление связанных тегов
  void updateRelatedTags(List<String> tags) {
    relatedTagIds = tags;
    relatedTagIdsJson = _serializeRelatedTags(tags);
  }

  /// Инкремент счетчика использования
  void incrementUsage() {
    usageCount++;
    lastUsedAt = DateTime.now();
  }

  /// Получить связанные теги
  List<String> getRelatedTags() {
    return _deserializeRelatedTags();
  }

  /// Добавить связанный тег
  void addRelatedTag(String tagId) {
    final tags = getRelatedTags();
    if (!tags.contains(tagId)) {
      tags.add(tagId);
      // Ограничиваем количество связанных тегов
      if (tags.length > 20) {
        tags.removeAt(0);
      }
      updateRelatedTags(tags);
    }
  }

  /// Конвертация в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'usageCount': usageCount,
      'isProtected': isProtected,
      'createdAt': createdAt.toIso8601String(),
      'lastUsedAt': lastUsedAt.toIso8601String(),
      'relatedTagIds': getRelatedTags(),
    };
  }

  /// Создание из JSON
  factory Tag.fromJson(Map<String, dynamic> json) {
    final tag = Tag(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      usageCount: json['usageCount'] as int? ?? 0,
      isProtected: json['isProtected'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsedAt: DateTime.parse(json['lastUsedAt'] as String),
      relatedTagIds: (json['relatedTagIds'] as List?)?.cast<String>() ?? [],
    );
    return tag;
  }
}

/// Расширения для работы с тегами в Isar
extension TagQuery on IsarCollection<Tag> {
  /// Поиск тегов по имени (частичное совпадение)
  Future<List<Tag>> searchByName(String query, {int limit = 50}) async {
    if (query.trim().isEmpty) {
      return where().usageCountSorted().limit(limit).findAll();
    }

    final normalizedQuery = query.toLowerCase().trim();
    return filter()
        .nameContains(normalizedQuery, caseSensitive: false)
        .or()
        .nameBeginsWith(normalizedQuery, caseSensitive: false)
        .findAll()
        .then((tags) => tags.take(limit).toList());
  }

  /// Получение тегов по категории
  Future<List<Tag>> getByCategory(String category, {int limit = 100}) async {
    return filter()
        .categoryEqualTo(category)
        .usageCountSorted()
        .limit(limit)
        .findAll();
  }

  /// Получение популярных тегов
  Future<List<Tag>> getPopularTags({int limit = 50}) async {
    return where()
        .isProtectedEqualTo(false)
        .usageCountSorted()
        .limit(limit)
        .findAll();
  }

  /// Получение недавно использованных тегов
  Future<List<Tag>> getRecentlyUsedTags({int limit = 20}) async {
    return where()
        .lastUsedAtNotNull()
        .lastUsedAtSorted()
        .limit(limit)
        .findAll();
  }

  /// Проверка существования тега по имени
  Future<bool> existsByName(String name) async {
    return filter()
        .nameEqualTo(name.toLowerCase().trim())
        .count()
        .then((count) => count > 0);
  }

  /// Получение тега по имени
  Future<Tag?> getByName(String name) async {
    return filter()
        .nameEqualTo(name.toLowerCase().trim())
        .findFirst();
  }
}

/// Расширение для сортировки по usageCount
extension TagSort on TagFilterBuilder {
  TagSortBy usageCountSorted() {
    return TagSortBy(this, true);
  }

  TagSortBy lastUsedAtSorted() {
    return TagSortBy(this, false);
  }
}

class TagSortBy {
  final TagFilterBuilder builder;
  final bool byUsageCount;

  TagSortBy(this.builder, this.byUsageCount);

  Future<List<Tag>> findAll() async {
    // Реализация сортировки будет в репозитории
    return builder.findAll();
  }

  TagLimitBuilder limit(int limit) {
    return TagLimitBuilder(builder, limit, byUsageCount);
  }
}

class TagLimitBuilder {
  final TagFilterBuilder builder;
  final int limit;
  final bool byUsageCount;

  TagLimitBuilder(this.builder, this.limit, this.byUsageCount);

  Future<List<Tag>> findAll() async {
    final tags = await builder.findAll();
    if (byUsageCount) {
      tags.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    } else {
      tags.sort((a, b) => b.lastUsedAt.compareTo(a.lastUsedAt));
    }
    return tags.take(limit).toList();
  }
}
