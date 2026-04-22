// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'content_type.freezed.dart';
part 'content_type.g.dart';

/// Типы контент-блоков в системе GlubLink
@freezed
enum ContentType with _$ContentType {
  const ContentType._();

  /// Медиафайл (изображение, видео, аудио)
  @JsonValue('media')
  const ContentType.media(),

  /// Текстовая заметка с поддержкой Markdown
  @JsonValue('note')
  const ContentType.note(),

  /// Веб-ссылка с метаданными
  @JsonValue('link')
  const ContentType.link(),

  /// Коллекция блоков с правилами фильтрации
  @JsonValue('collection')
  const ContentType.collection();

  /// Человеко-читаемое название типа
  String get displayName {
    return switch (this) {
      ContentType.media() => 'Медиа',
      ContentType.note() => 'Заметка',
      ContentType.link() => 'Ссылка',
      ContentType.collection() => 'Коллекция',
    };
  }

  /// Иконка для типа контента
  String get iconCode {
    return switch (this) {
      ContentType.media() => '📷',
      ContentType.note() => '📝',
      ContentType.link() => '🔗',
      ContentType.collection() => '📁',
    };
  }
}

/// Типы отношений между блоками
@freezed
enum RelationType with _$RelationType {
  const RelationType._();

  /// Прямая ссылка на другой блок
  @JsonValue('reference')
  const RelationType.reference(),

  /// Вариация исходного блока
  @JsonValue('variation')
  const RelationType.variation(),

  /// Блок является частью другого
  @JsonValue('partOf')
  const RelationType.partOf(),

  /// Вдохновлено другим блоком
  @JsonValue('inspiredBy')
  const RelationType.inspiredBy(),

  /// Противоречит другому блоку
  @JsonValue('contradicts')
  const RelationType.contradicts(),

  /// Пользовательский тип отношения
  @JsonValue('custom')
  const RelationType.custom();

  /// Отображаемое имя типа отношения
  String get displayName {
    return switch (this) {
      RelationType.reference() => 'Ссылка',
      RelationType.variation() => 'Вариация',
      RelationType.partOf() => 'Часть',
      RelationType.inspiredBy() => 'Вдохновлено',
      RelationType.contradicts() => 'Противоречит',
      RelationType.custom() => 'Пользовательский',
    };
  }
}

/// Ориентация медиа-контента
@freezed
enum Orientation with _$Orientation {
  const Orientation._();

  @JsonValue('landscape')
  const Orientation.landscape(),

  @JsonValue('portrait')
  const Orientation.portrait(),

  @JsonValue('square')
  const Orientation.square();

  /// Вычисление ориентации на основе размеров
  factory Orientation.fromDimensions(int width, int height) {
    if (width > height) {
      return const Orientation.landscape();
    } else if (height > width) {
      return const Orientation.portrait();
    } else {
      return const Orientation.square();
    }
  }
}

/// Режим отображения коллекций
@freezed
enum ViewMode with _$ViewMode {
  const ViewMode._();

  @JsonValue('masonry')
  const ViewMode.masonry(),

  @JsonValue('justified')
  const ViewMode.justified(),

  @JsonValue('list')
  const ViewMode.list(),

  @JsonValue('timeline')
  const ViewMode.timeline();

  /// Отображаемое имя режима
  String get displayName {
    return switch (this) {
      ViewMode.masonry() => 'Masonry',
      ViewMode.justified() => 'Выровненный',
      ViewMode.list() => 'Список',
      ViewMode.timeline() => 'Временная шкала',
    };
  }
}

/// Порядок сортировки
@freezed
enum SortOrder with _$SortOrder {
  const SortOrder._();

  @JsonValue('createdAtAsc')
  const SortOrder.createdAtAsc(),

  @JsonValue('createdAtDesc')
  const SortOrder.createdAtDesc(),

  @JsonValue('modifiedAtAsc')
  const SortOrder.modifiedAtAsc(),

  @JsonValue('modifiedAtDesc')
  const SortOrder.modifiedAtDesc(),

  @JsonValue('nameAsc')
  const SortOrder.nameAsc(),

  @JsonValue('nameDesc')
  const SortOrder.nameDesc();

  /// Отображаемое имя порядка сортировки
  String get displayName {
    return switch (this) {
      SortOrder.createdAtAsc() => 'По дате создания (возрастание)',
      SortOrder.createdAtDesc() => 'По дате создания (убывание)',
      SortOrder.modifiedAtAsc() => 'По дате изменения (возрастание)',
      SortOrder.modifiedAtDesc() => 'По дате изменения (убывание)',
      SortOrder.nameAsc() => 'По имени (А-Я)',
      SortOrder.nameDesc() => 'По имени (Я-А)',
    };
  }
}
