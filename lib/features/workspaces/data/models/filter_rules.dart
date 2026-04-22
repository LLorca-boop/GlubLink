// lib/features/workspaces/data/models/filter_rules.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../content_block/models/content_type.dart';

part 'filter_rules.freezed.dart';
part 'filter_rules.g.dart';

/// Диапазон дат для фильтрации
@freezed
class DateRange with _$DateRange {
  const factory DateRange({
    DateTime? from,
    DateTime? to,
  }) = _DateRange;

  factory DateRange.fromJson(Map<String, dynamic> json) => 
      _$DateRangeFromJson(json);
}

/// Разрешение (ширина x высота)
@freezed
class Resolution with _$Resolution {
  const factory Resolution({
    required int width,
    required int height,
  }) = _Resolution;

  factory Resolution.fromJson(Map<String, dynamic> json) => 
      _$ResolutionFromJson(json);
}

/// Правила фильтрации для Workspace и Gallery
@freezed
class FilterRules with _$FilterRules {
  const factory FilterRules({
    /// Теги для включения (позитивные)
    @Default([]) List<String> tags,
    
    /// Теги для исключения (негативные)
    @Default([]) List<String> negativeTags,
    
    /// Типы контента для фильтрации
    @Default([]) List<ContentType> contentTypes,
    
    /// Диапазон дат
    DateRange? dateRange,
    
    /// Минимальное разрешение
    Resolution? minResolution,
    
    /// Максимальное разрешение
    Resolution? maxResolution,
    
    /// Фильтр по наличию заметок
    bool? hasNotes,
    
    /// Только избранные
    bool? isFavorite,
  }) = _FilterRules;

  factory FilterRules.fromJson(Map<String, dynamic> json) => 
      _$FilterRulesFromJson(json);

  /// Пустые правила (без фильтрации)
  factory FilterRules.empty() => const FilterRules();

  /// Проверка: являются ли правила пустыми (нет активной фильтрации)
  bool get isEmpty {
    return tags.isEmpty &&
        negativeTags.isEmpty &&
        contentTypes.isEmpty &&
        dateRange == null &&
        minResolution == null &&
        maxResolution == null &&
        hasNotes == null &&
        isFavorite == null;
  }

  /// Проверка: есть ли активная фильтрация
  bool get isNotEmpty => !isEmpty;

  /// Объединение правил (текущие + другие)
  FilterRules merge(FilterRules other) {
    return FilterRules(
      tags: [...tags, ...other.tags].toSet().toList(),
      negativeTags: [...negativeTags, ...other.negativeTags].toSet().toList(),
      contentTypes: [...contentTypes, ...other.contentTypes].toSet().toList(),
      dateRange: dateRange ?? other.dateRange,
      minResolution: minResolution ?? other.minResolution,
      maxResolution: maxResolution ?? other.maxResolution,
      hasNotes: hasNotes ?? other.hasNotes,
      isFavorite: isFavorite ?? other.isFavorite,
    );
  }
}
