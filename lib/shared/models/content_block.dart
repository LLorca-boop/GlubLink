// ignore_for_file: public_member_api_docs

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';

part 'content_block.freezed.dart';
part 'content_block.g.dart';

/// Абстрактный базовый класс для всех контент-блоков
/// Реализует общие свойства и поведение для всех типов контента
@freezed
class ContentBlock with _$ContentBlock {
  const factory ContentBlock({
    /// Уникальный идентификатор блока (UUID v4)
    @JsonKey(name: 'id') required String id,

    /// Тип контента (media, note, link, collection)
    @JsonKey(name: 'type') required ContentType type,

    /// Дата создания блока
    @JsonKey(name: 'createdAt') required DateTime createdAt,

    /// Дата добавления в систему
    @JsonKey(name: 'addedAt') required DateTime addedAt,

    /// Дата последнего изменения
    @JsonKey(name: 'lastModifiedAt') required DateTime lastModifiedAt,

    /// Список ID тегов, связанных с блоком
    @JsonKey(name: 'tags') List<String>? tags,

    /// Отношения к другим блокам
    @JsonKey(name: 'relations') List<BlockRelation>? relations,

    /// Флаг избранного блока
    @JsonKey(name: 'isFavorite', defaultValue: false) bool isFavorite,

    /// Флаг архивного блока
    @JsonKey(name: 'isArchived', defaultValue: false) bool isArchived,

    /// Флаг нахождения в корзине
    @JsonKey(name: 'isInRecycleBin', defaultValue: false) bool isInRecycleBin,

    /// Хэш содержимого (SHA-256) для обнаружения дубликатов
    @JsonKey(name: 'contentHash') String? contentHash,

    /// Путь к исходному файлу (для медиа)
    @JsonKey(name: 'sourcePath') String? sourcePath,
  }) = _ContentBlock;

  factory ContentBlock.fromJson(Map<String, dynamic> json) =>
      _$ContentBlockFromJson(json);

  /// Создание нового блока с автоматической генерацией ID и дат
  factory ContentBlock.create({
    required ContentType type,
    String? id,
    String? contentHash,
    String? sourcePath,
    List<String>? tags,
    List<BlockRelation>? relations,
  }) {
    final now = DateTime.now();
    return ContentBlock(
      id: id ?? _generateUuid(),
      type: type,
      createdAt: now,
      addedAt: now,
      lastModifiedAt: now,
      tags: tags ?? [],
      relations: relations ?? [],
      isFavorite: false,
      isArchived: false,
      isInRecycleBin: false,
      contentHash: contentHash,
      sourcePath: sourcePath,
    );
  }

  /// Генерация UUID v4
  static String _generateUuid() {
    // Простая реализация UUID v4 для примера
    // В продакшене использовать пакет uuid
    final random = DateTime.now().millisecondsSinceEpoch;
    return 'block_${random.toString().padLeft(19, '0')}';
  }

  /// Проверка валидности блока
  bool get isValid {
    if (id.isEmpty) return false;
    if (createdAt.isAfter(DateTime.now())) return false;
    if (addedAt.isAfter(DateTime.now())) return false;
    return true;
  }

  /// Проверка, активен ли блок (не в архиве и не в корзине)
  bool get isActive => !isArchived && !isInRecycleBin;

  /// Количество отношений
  int get relationsCount => relations?.length ?? 0;

  /// Количество тегов
  int get tagsCount => tags?.length ?? 0;
}

/// Блок с медиа-контентом (изображения, видео, аудио)
@freezed
class MediaBlock with _$MediaBlock {
  const factory MediaBlock({
    /// Базовые свойства контент-блока
    @JsonKey(name: 'base') required ContentBlock base,

    /// Ширина медиа в пикселях
    @JsonKey(name: 'width') required int width,

    /// Высота медиа в пикселях
    @JsonKey(name: 'height') required int height,

    /// Длительность в миллисекундах (для видео/аудио)
    @JsonKey(name: 'duration') int? duration,

    /// Размер файла в байтах
    @JsonKey(name: 'fileSize') required int fileSize,

    /// Формат файла (jpg, png, mp4, etc.)
    @JsonKey(name: 'format') required String format,

    /// Путь к миниатюре
    @JsonKey(name: 'thumbnailPath') String? thumbnailPath,

    /// Ориентация медиа
    @JsonKey(name: 'orientation') required Orientation orientation,

    /// EXIF данные (для изображений)
    @JsonKey(name: 'exifData') Map<String, dynamic>? exifData,

    /// Цветовая палитра (hex цвета)
    @JsonKey(name: 'colorPalette') List<String>? colorPalette,
  }) = _MediaBlock;

  factory MediaBlock.fromJson(Map<String, dynamic> json) =>
      _$MediaBlockFromJson(json);

  /// Создание нового медиа-блока
  factory MediaBlock.create({
    required ContentBlock base,
    required int width,
    required int height,
    required int fileSize,
    required String format,
    int? duration,
    String? thumbnailPath,
    Orientation? orientation,
    Map<String, dynamic>? exifData,
    List<String>? colorPalette,
  }) {
    final orient = orientation ?? Orientation.fromDimensions(width, height);
    return MediaBlock(
      base: base,
      width: width,
      height: height,
      duration: duration,
      fileSize: fileSize,
      format: format,
      thumbnailPath: thumbnailPath,
      orientation: orient,
      exifData: exifData,
      colorPalette: colorPalette,
    );
  }

  /// Проверка, является ли медиа изображением
  bool get isImage {
    const imageFormats = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'];
    return imageFormats.contains(format.toLowerCase());
  }

  /// Проверка, является ли медиа видео
  bool get isVideo {
    const videoFormats = ['mp4', 'webm', 'avi', 'mov', 'mkv'];
    return videoFormats.contains(format.toLowerCase());
  }

  /// Проверка, является ли медиа аудио
  bool get isAudio {
    const audioFormats = ['mp3', 'wav', 'flac', 'aac', 'ogg'];
    return audioFormats.contains(format.toLowerCase());
  }

  /// Соотношение сторон
  double get aspectRatio {
    if (height == 0) return 1.0;
    return width / height;
  }

  /// Форматированный размер файла
  String get formattedFileSize {
    const units = ['Б', 'КБ', 'МБ', 'ГБ'];
    var size = fileSize.toDouble();
    var unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }
}

/// Блок с текстовой заметкой (Markdown)
@freezed
class NoteBlock with _$NoteBlock {
  const factory NoteBlock({
    /// Базовые свойства контент-блока
    @JsonKey(name: 'base') required ContentBlock base,

    /// Содержимое заметки в формате Markdown
    @JsonKey(name: 'content') required String content,

    /// Количество слов
    @JsonKey(name: 'wordCount') required int wordCount,

    /// ID встроенных блоков
    @JsonKey(name: 'embeddedBlocks') List<String>? embeddedBlocks,

    /// Заголовки в заметке
    @JsonKey(name: 'headings') List<String>? headings,
  }) = _NoteBlock;

  factory NoteBlock.fromJson(Map<String, dynamic> json) =>
      _$NoteBlockFromJson(json);

  /// Создание новой заметки
  factory NoteBlock.create({
    required ContentBlock base,
    required String content,
    List<String>? embeddedBlocks,
    List<String>? headings,
  }) {
    final words = content.trim().isEmpty
        ? 0
        : content.trim().split(RegExp(r'\s+')).length;
    return NoteBlock(
      base: base,
      content: content,
      wordCount: words,
      embeddedBlocks: embeddedBlocks ?? [],
      headings: headings ?? [],
    );
  }

  /// Предпросмотр содержимого (первые N символов)
  String preview({int maxLength = 100}) {
    if (content.length <= maxLength) return content;
    return '${content.substring(0, maxLength).trim()}...';
  }

  /// Проверка, пуста ли заметка
  bool get isEmpty => content.trim().isEmpty;

  /// Примерное время чтения (в минутах)
  int get readingTimeMinutes {
    const wordsPerMinute = 200;
    return (wordCount / wordsPerMinute).ceil();
  }
}

/// Блок с веб-ссылкой
@freezed
class LinkBlock with _$LinkBlock {
  const factory LinkBlock({
    /// Базовые свойства контент-блока
    @JsonKey(name: 'base') required ContentBlock base,

    /// URL ссылки
    @JsonKey(name: 'url') required String url,

    /// Заголовок страницы
    @JsonKey(name: 'title') required String title,

    /// Описание страницы
    @JsonKey(name: 'description') String? description,

    /// Путь к favicon
    @JsonKey(name: 'faviconPath') String? faviconPath,

    /// Дата последней проверки доступности
    @JsonKey(name: 'lastChecked') DateTime? lastChecked,

    /// Флаг доступности ссылки
    @JsonKey(name: 'isAccessible', defaultValue: true) bool isAccessible,
  }) = _LinkBlock;

  factory LinkBlock.fromJson(Map<String, dynamic> json) =>
      _$LinkBlockFromJson(json);

  /// Создание новой ссылки
  factory LinkBlock.create({
    required ContentBlock base,
    required String url,
    required String title,
    String? description,
    String? faviconPath,
  }) {
    return LinkBlock(
      base: base,
      url: url,
      title: title,
      description: description,
      faviconPath: faviconPath,
      lastChecked: DateTime.now(),
      isAccessible: true,
    );
  }

  /// Домен из URL
  String get domain {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (_) {
      return '';
    }
  }

  /// Проверка валидности URL
  bool get isValidUrl {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && uri.hasAuthority;
    } catch (_) {
      return false;
    }
  }

  /// Проверка, требует ли ссылка повторной проверки
  bool get needsRecheck {
    if (lastChecked == null) return true;
    final daysSinceCheck = DateTime.now().difference(lastChecked!).inDays;
    return daysSinceCheck > 7;
  }
}

/// Блок-коллекция (динамическая группировка блоков)
@freezed
class CollectionBlock with _$CollectionBlock {
  const factory CollectionBlock({
    /// Базовые свойства контент-блока
    @JsonKey(name: 'base') required ContentBlock base,

    /// Правила фильтрации
    @JsonKey(name: 'filterRules') required FilterRules filterRules,

    /// Режим отображения
    @JsonKey(name: 'viewMode') required ViewMode viewMode,

    /// Порядок сортировки
    @JsonKey(name: 'sortOrder') required SortOrder sortOrder,

    /// Закреплённые блоки (ID)
    @JsonKey(name: 'pinnedBlocks') List<String>? pinnedBlocks,
  }) = _CollectionBlock;

  factory CollectionBlock.fromJson(Map<String, dynamic> json) =>
      _$CollectionBlockFromJson(json);

  /// Создание новой коллекции
  factory CollectionBlock.create({
    required ContentBlock base,
    FilterRules? filterRules,
    ViewMode? viewMode,
    SortOrder? sortOrder,
    List<String>? pinnedBlocks,
  }) {
    return CollectionBlock(
      base: base,
      filterRules: filterRules ?? FilterRules.empty(),
      viewMode: viewMode ?? const ViewMode.masonry(),
      sortOrder: sortOrder ?? const SortOrder.createdAtDesc(),
      pinnedBlocks: pinnedBlocks ?? [],
    );
  }

  /// Количество закреплённых блоков
  int get pinnedCount => pinnedBlocks?.length ?? 0;

  /// Проверка, закреплён ли блок
  bool isPinned(String blockId) {
    return pinnedBlocks?.contains(blockId) ?? false;
  }

  /// Добавление блока в закреплённые
  CollectionBlock copyWithPinnedBlock(String blockId, bool pinned) {
    final currentPinned = List<String>.from(pinnedBlocks ?? []);
    if (pinned) {
      if (!currentPinned.contains(blockId)) {
        currentPinned.add(blockId);
      }
    } else {
      currentPinned.remove(blockId);
    }
    return copyWith(pinnedBlocks: currentPinned);
  }
}
