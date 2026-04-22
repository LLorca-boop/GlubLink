// lib/features/gallery/domain/utils/query_parser.dart
import '../models/parsed_query.dart';

/// Парсер поисковых запросов для галереи
/// Поддерживает:
/// - Позитивные теги: "fox" → includeTags
/// - Негативные теги: "-sketch" → excludeTags
/// - ИЛИ группы: "(zara || rex)" → orGroups
/// - Текстовый поиск: остальной текст → textSearch
class QueryParser {
  /// Парсит строку запроса в структурированный ParsedQuery
  /// Чистая функция без побочных эффектов
  static ParsedQuery parse(String query) {
    if (query.trim().isEmpty) {
      return ParsedQuery.empty();
    }

    final includeTags = <String>[];
    final excludeTags = <String>[];
    final orGroups = <List<String>>[];
    String? textSearch;

    // Удаляем лишние пробелы
    final normalizedQuery = query.trim();
    
    // Находим все ИЛИ группы: "(tag1 || tag2 || tag3)"
    final orGroupRegex = RegExp(r'\(([^()]+)\)');
    final orMatches = orGroupRegex.allMatches(normalizedQuery);
    
    for (final match in orMatches) {
      final groupContent = match.group(1)?.trim() ?? '';
      final tags = groupContent
          .split('||')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();
      
      if (tags.isNotEmpty) {
        orGroups.add(tags);
      }
    }

    // Удаляем ИЛИ группы из строки для дальнейшей обработки
    var remainingQuery = orGroupRegex.replaceAll(normalizedQuery, ' ');

    // Разбиваем на токены по пробелам
    final tokens = remainingQuery.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

    for (final token in tokens) {
      if (token.startsWith('-')) {
        // Негативный тег
        final tag = token.substring(1).trim();
        if (tag.isNotEmpty) {
          excludeTags.add(tag);
        }
      } else if (token.startsWith('#')) {
        // Явный тег с #
        final tag = token.substring(1).trim();
        if (tag.isNotEmpty) {
          includeTags.add(tag);
        }
      } else if (!token.startsWith('(') && !token.endsWith(')')) {
        // Обычный токен - считаем позитивным тегом или текстовым поиском
        // Если содержит спецсимволы, это скорее всего текст
        if (RegExp(r'[^\w\-]').hasMatch(token)) {
          textSearch = textSearch == null ? token : '$textSearch $token';
        } else {
          includeTags.add(token);
        }
      }
    }

    return ParsedQuery(
      includeTags: includeTags,
      excludeTags: excludeTags,
      orGroups: orGroups,
      textSearch: textSearch?.trim(),
      rawQuery: query,
    );
  }

  /// Преобразует ParsedQuery обратно в строку
  static String stringify(ParsedQuery parsed) {
    final parts = <String>[];

    // Добавляем позитивные теги
    for (final tag in parsed.includeTags) {
      parts.add('#$tag');
    }

    // Добавляем негативные теги
    for (final tag in parsed.excludeTags) {
      parts.add('-$tag');
    }

    // Добавляем ИЛИ группы
    for (final group in parsed.orGroups) {
      parts.add('(${group.join(' || ')})');
    }

    // Добавляем текстовый поиск
    if (parsed.textSearch != null && parsed.textSearch!.isNotEmpty) {
      parts.add(parsed.textSearch!);
    }

    return parts.join(' ');
  }
}
