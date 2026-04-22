import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag_category.freezed.dart';
part 'tag_category.g.dart';

/// Категория тега с соответствующим цветом
/// Используется для визуальной классификации контента
@freezed
class TagCategory with _$TagCategory {
  const factory TagCategory({
    required String name,
    required String hexColor,
    required int priority,
  }) = _TagCategory;

  /// Artist - художники, авторы контента
  static const artist = TagCategory(name: 'artist', hexColor: '#FF6B9D', priority: 0);
  
  /// Copyright - франшизы, серии, вселенные
  static const copyright = TagCategory(name: 'copyright', hexColor: '#9D6BFF', priority: 1);
  
  /// Character - персонажи
  static const character = TagCategory(name: 'character', hexColor: '#6B9DFF', priority: 2);
  
  /// Species - виды, расы
  static const species = TagCategory(name: 'species', hexColor: '#6BFF9D', priority: 3);
  
  /// General - общие теги
  static const general = TagCategory(name: 'general', hexColor: '#FFD96B', priority: 4);
  
  /// Meta - мета-информация (оценка, тип файла)
  static const meta = TagCategory(name: 'meta', hexColor: '#9D9D9D', priority: 5);
  
  /// References - ссылки на источники
  static const references = TagCategory(name: 'references', hexColor: '#FF9D6B', priority: 6);

  /// Все доступные категории
  static const List<TagCategory> values = [
    artist,
    copyright,
    character,
    species,
    general,
    meta,
    references,
  ];

  /// Получить категорию по имени
  static TagCategory fromName(String name) {
    return values.firstWhere(
      (category) => category.name == name.toLowerCase(),
      orElse: () => general,
    );
  }

  /// Получить категорию из JSON
  factory TagCategory.fromJson(String json) => fromName(json);

  /// Сериализация в JSON
  String toJson() => name;
}

/// Расширение для получения цвета из категории
extension TagCategoryColor on TagCategory {
  /// Цвет категории в формате RGB
  int get colorValue {
    final hex = hexColor.replaceFirst('#', '');
    return int.parse(hex, radix: 16);
  }

  /// Цвет категории как Flutter Color
  // ignore: depend_on_referenced_packages
  int get argbValue => 0xFF000000 | colorValue;
}
