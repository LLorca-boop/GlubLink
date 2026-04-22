// ignore_for_file: public_member_api_docs

import 'package:freezed_annotation/freezed_annotation.dart';

part 'block_relation.freezed.dart';
part 'block_relation.g.dart';

/// Отношение между двумя контент-блоками
@freezed
class BlockRelation with _$BlockRelation {
  const factory BlockRelation({
    /// ID целевого блока
    @JsonKey(name: 'targetId') required String targetId,

    /// Тип отношения
    @JsonKey(name: 'type') required RelationType type,

    /// Дополнительные метаданные отношения
    @JsonKey(name: 'metadata') Map<String, dynamic>? metadata,
  }) = _BlockRelation;

  factory BlockRelation.fromJson(Map<String, dynamic> json) =>
      _$BlockRelationFromJson(json);

  /// Создание отношения с пустыми метаданными
  factory BlockRelation.simple({
    required String targetId,
    required RelationType type,
  }) {
    return BlockRelation(
      targetId: targetId,
      type: type,
      metadata: null,
    );
  }

  /// Валидация отношения
  bool get isValid {
    if (targetId.isEmpty) {
      return false;
    }
    // Проверка на циклические ссылки должна выполняться на уровне сервиса
    return true;
  }
}

/// Правила фильтрации для коллекций
@freezed
class FilterRules with _$FilterRules {
  const factory FilterRules({
    /// Фильтр по типам контента
    @JsonKey(name: 'contentTypes') List<ContentType>? contentTypes,

    /// Фильтр по тегам (любой из списка)
    @JsonKey(name: 'tags') List<String>? tags,

    /// Фильтр по дате создания (от)
    @JsonKey(name: 'dateFrom') DateTime? dateFrom,

    /// Фильтр по дате создания (до)
    @JsonKey(name: 'dateTo') DateTime? dateTo,

    /// Фильтр по избранному
    @JsonKey(name: 'favoriteOnly') bool? favoriteOnly,

    /// Фильтр по архивным
    @JsonKey(name: 'archivedOnly') bool? archivedOnly,

    /// Поиск по названию/содержимому
    @JsonKey(name: 'searchQuery') String? searchQuery,

    /// Исключить блоки из корзины
    @JsonKey(name: 'excludeRecycleBin', defaultValue: true)
    bool excludeRecycleBin,
  }) = _FilterRules;

  factory FilterRules.fromJson(Map<String, dynamic> json) =>
      _$FilterRulesFromJson(json);

  /// Пустые правила (без фильтрации)
  factory FilterRules.empty() {
    return const FilterRules(
      contentTypes: null,
      tags: null,
      dateFrom: null,
      dateTo: null,
      favoriteOnly: null,
      archivedOnly: null,
      searchQuery: null,
      excludeRecycleBin: true,
    );
  }

  /// Проверка, есть ли активные правила фильтрации
  bool get hasActiveFilters {
    return contentTypes != null ||
        tags != null ||
        dateFrom != null ||
        dateTo != null ||
        favoriteOnly != null ||
        archivedOnly != null ||
        searchQuery != null && searchQuery!.isNotEmpty;
  }
}
