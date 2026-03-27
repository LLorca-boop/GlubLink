/// Tag Entity - модель данных для тегов
class TagEntity {
  final String id;
  final String name;
  final String? nameEn;
  final String? nameRu;
  final TagCategory category;
  final String color; // Hex цвет тега
  final int usageCount;
  final bool isNsfw;
  final bool isMeta;
  final Map<String, int> version; // Vector Clock для синхронизации

  TagEntity({
    required this.id,
    required this.name,
    this.nameEn,
    this.nameRu,
    required this.category,
    required this.color,
    this.usageCount = 0,
    this.isNsfw = false,
    this.isMeta = false,
    Map<String, int>? version,
  }) : version = version ?? {};

  TagEntity copyWith({
    String? id,
    String? name,
    String? nameEn,
    String? nameRu,
    TagCategory? category,
    String? color,
    int? usageCount,
    bool? isNsfw,
    bool? isMeta,
    Map<String, int>? version,
  }) {
    return TagEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      nameRu: nameRu ?? this.nameRu,
      category: category ?? this.category,
      color: color ?? this.color,
      usageCount: usageCount ?? this.usageCount,
      isNsfw: isNsfw ?? this.isNsfw,
      isMeta: isMeta ?? this.isMeta,
      version: version ?? this.version,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameEn': nameEn,
      'nameRu': nameRu,
      'category': category.name,
      'color': color,
      'usageCount': usageCount,
      'isNsfw': isNsfw,
      'isMeta': isMeta,
      'version': version,
    };
  }

  factory TagEntity.fromMap(Map<String, dynamic> map) {
    return TagEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      nameEn: map['nameEn'] as String?,
      nameRu: map['nameRu'] as String?,
      category: TagCategory.fromString(map['category'] as String),
      color: map['color'] as String,
      usageCount: map['usageCount'] as int? ?? 0,
      isNsfw: map['isNsfw'] as bool? ?? false,
      isMeta: map['isMeta'] as bool? ?? false,
      version: Map<String, int>.from(map['version'] ?? {}),
    );
  }
}

enum TagCategory {
  artist,
  copyrights,
  characters,
  species,
  general,
  meta,
  references;

  static TagCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'artist':
        return TagCategory.artist;
      case 'copyrights':
        return TagCategory.copyrights;
      case 'characters':
        return TagCategory.characters;
      case 'species':
        return TagCategory.species;
      case 'general':
        return TagCategory.general;
      case 'meta':
        return TagCategory.meta;
      case 'references':
        return TagCategory.references;
      default:
        return TagCategory.general;
    }
  }

  String get displayName {
    switch (this) {
      case TagCategory.artist:
        return 'Artist';
      case TagCategory.copyrights:
        return 'Copyrights';
      case TagCategory.characters:
        return 'Characters';
      case TagCategory.species:
        return 'Species';
      case TagCategory.general:
        return 'General';
      case TagCategory.meta:
        return 'Meta';
      case TagCategory.references:
        return 'References';
    }
  }
}
