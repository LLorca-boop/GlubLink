// ignore_for_file: public_member_api_docs

import 'package:isar/isar.dart';

part 'content_block_isar.g.dart';

/// Изменяемая модель ContentBlock для хранения в Isar
/// Используется для прямой работы с базой данных
@collection
class ContentBlockIsar {
  Id id = Isar.autoIncrement;

  /// Уникальный строковый идентификатор (UUID v4)
  @Index(unique: true)
  late String uuid;

  /// Тип контента (media, note, link, collection)
  @Enumerated(EnumType.name)
  @Index()
  late ContentType type;

  /// Дата создания блока
  @Index()
  late DateTime createdAt;

  /// Дата добавления в систему
  @Index()
  late DateTime addedAt;

  /// Дата последнего изменения
  @Index()
  late DateTime lastModifiedAt;

  /// Список ID тегов, связанных с блоком
  @Index()
  List<String>? tags;

  /// Флаг избранного блока
  @Index()
  bool isFavorite = false;

  /// Флаг архивного блока
  @Index()
  bool isArchived = false;

  /// Флаг нахождения в корзине
  @Index()
  bool isInRecycleBin = false;

  /// Хэш содержимого (SHA-256) для обнаружения дубликатов
  @Index()
  String? contentHash;

  /// Путь к исходному файлу (для медиа)
  String? sourcePath;

  /// Специфичные данные для разных типов блоков (JSON)
  Map<String, dynamic>? data;

  /// Проверка, активен ли блок
  bool get isActive => !isArchived && !isInRecycleBin;
}

/// Перечисление типов контента для Isar
enum ContentType {
  media,
  note,
  link,
  collection,
}

/// Расширения для конвертации между моделями
extension ContentBlockIsarExt on ContentBlockIsar {
  /// Конвертация в строковое представление типа
  String get typeString => type.name;
}
