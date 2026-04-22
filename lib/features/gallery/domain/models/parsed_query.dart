// lib/features/gallery/domain/models/parsed_query.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'parsed_query.freezed.dart';

/// Результат парсинга поискового запроса
/// Используется для фильтрации контента в галерее
@freezed
class ParsedQuery with _$ParsedQuery {
  const factory ParsedQuery({
    /// Позитивные теги (AND логика между группами)
    @Default([]) List<String> includeTags,
    
    /// Негативные теги (исключения)
    @Default([]) List<String> excludeTags,
    
    /// Группы ИЛИ (например, "(cat || dog)")
    @Default([]) List<List<String>> orGroups,
    
    /// Текстовый поиск по названию/описанию
    String? textSearch,
    
    /// Исходная строка запроса
    String? rawQuery,
  }) = _ParsedQuery;

  factory ParsedQuery.empty() => const ParsedQuery();
}
