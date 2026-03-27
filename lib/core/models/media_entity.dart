/// Media Entity - основная модель данных для медиафайлов
class MediaEntity {
  final String id;
  final String path;
  final MediaType type;
  final List<TagEntity> tags;
  final DateTime dateAdded;
  final DateTime? dateModified;
  final int size; // размер в байтах
  final MediaDimensions dimensions;
  final bool isNsfw;
  final bool isFavorite;
  final String? noteAttached;
  final Map<String, int> version; // Vector Clock для синхронизации
  final String? lastSyncDevice;

  MediaEntity({
    required this.id,
    required this.path,
    required this.type,
    this.tags = const [],
    required this.dateAdded,
    this.dateModified,
    required this.size,
    required this.dimensions,
    this.isNsfw = false,
    this.isFavorite = false,
    this.noteAttached,
    Map<String, int>? version,
    this.lastSyncDevice,
  }) : version = version ?? {};

  MediaEntity copyWith({
    String? id,
    String? path,
    MediaType? type,
    List<TagEntity>? tags,
    DateTime? dateAdded,
    DateTime? dateModified,
    int? size,
    MediaDimensions? dimensions,
    bool? isNsfw,
    bool? isFavorite,
    String? noteAttached,
    Map<String, int>? version,
    String? lastSyncDevice,
  }) {
    return MediaEntity(
      id: id ?? this.id,
      path: path ?? this.path,
      type: type ?? this.type,
      tags: tags ?? this.tags,
      dateAdded: dateAdded ?? this.dateAdded,
      dateModified: dateModified ?? this.dateModified,
      size: size ?? this.size,
      dimensions: dimensions ?? this.dimensions,
      isNsfw: isNsfw ?? this.isNsfw,
      isFavorite: isFavorite ?? this.isFavorite,
      noteAttached: noteAttached ?? this.noteAttached,
      version: version ?? this.version,
      lastSyncDevice: lastSyncDevice ?? this.lastSyncDevice,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'type': type.name,
      'tags': tags.map((t) => t.toMap()).toList(),
      'dateAdded': dateAdded.toIso8601String(),
      'dateModified': dateModified?.toIso8601String(),
      'size': size,
      'dimensions': dimensions.toMap(),
      'isNsfw': isNsfw,
      'isFavorite': isFavorite,
      'noteAttached': noteAttached,
      'version': version,
      'lastSyncDevice': lastSyncDevice,
    };
  }

  factory MediaEntity.fromMap(Map<String, dynamic> map) {
    return MediaEntity(
      id: map['id'] as String,
      path: map['path'] as String,
      type: MediaType.fromString(map['type'] as String),
      tags: (map['tags'] as List<dynamic>?)
              ?.map((t) => TagEntity.fromMap(t as Map<String, dynamic>))
              .toList() ??
          [],
      dateAdded: DateTime.parse(map['dateAdded'] as String),
      dateModified: map['dateModified'] != null
          ? DateTime.parse(map['dateModified'] as String)
          : null,
      size: map['size'] as int,
      dimensions: MediaDimensions.fromMap(map['dimensions'] as Map<String, dynamic>),
      isNsfw: map['isNsfw'] as bool? ?? false,
      isFavorite: map['isFavorite'] as bool? ?? false,
      noteAttached: map['noteAttached'] as String?,
      version: Map<String, int>.from(map['version'] ?? {}),
      lastSyncDevice: map['lastSyncDevice'] as String?,
    );
  }
}

enum MediaType {
  image,
  gif,
  video;

  static MediaType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'gif':
        return MediaType.gif;
      case 'video':
        return MediaType.video;
      default:
        return MediaType.image;
    }
  }
}

class MediaDimensions {
  final int width;
  final int height;

  const MediaDimensions({required this.width, required this.height});

  Map<String, dynamic> toMap() {
    return {'width': width, 'height': height};
  }

  factory MediaDimensions.fromMap(Map<String, dynamic> map) {
    return MediaDimensions(
      width: map['width'] as int,
      height: map['height'] as int,
    );
  }
}
