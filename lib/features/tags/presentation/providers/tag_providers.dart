import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/tag_entity.dart';
import '../domain/repositories/tag_repository.dart';

/// Статус загрузки данных тегов
enum TagLoadStatus {
  /// Начальное состояние
  initial,
  
  /// Загрузка данных
  loading,
  
  /// Данные загружены успешно
  success,
  
  /// Произошла ошибка при загрузке
  error,
}

/// Состояние менеджера тегов
class TagState {
  /// Статус загрузки
  final TagLoadStatus status;
  
  /// Список всех тегов
  final List<TagEntity> tags;
  
  /// Список выбранных тегов (ID)
  final Set<String> selectedTagIds;
  
  /// Текущий поисковый запрос
  final String searchQuery;
  
  /// Выбранная категория для фильтрации
  final String? selectedCategory;
  
  /// Тип сортировки
  final TagSortType sortType;
  
  /// Сообщение об ошибке
  final String? errorMessage;

  const TagState({
    this.status = TagLoadStatus.initial,
    this.tags = const [],
    this.selectedTagIds = const {},
    this.searchQuery = '',
    this.selectedCategory,
    this.sortType = TagSortType.popularity,
    this.errorMessage,
  });

  /// Получить отфильтрованные и отсортированные теги
  List<TagEntity> get filteredTags {
    var result = tags;

    // Фильтрация по поисковому запросу
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((tag) => tag.name.contains(query)).toList();
    }

    // Фильтрация по категории
    if (selectedCategory != null) {
      result = result.where((tag) => tag.category == selectedCategory).toList();
    }

    // Сортировка
    switch (sortType) {
      case TagSortType.popularity:
        result.sort((a, b) => b.usageCount.compareTo(a.usageCount));
        break;
      case TagSortType.alphabetical:
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
      case TagSortType.recentlyUsed:
        result.sort((a, b) => b.lastUsedAt.compareTo(a.lastUsedAt));
        break;
      case TagSortType.newest:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return result;
  }

  /// Проверка, выбран ли тег
  bool isTagSelected(String tagId) => selectedTagIds.contains(tagId);

  /// Копирование состояния с изменениями
  TagState copyWith({
    TagLoadStatus? status,
    List<TagEntity>? tags,
    Set<String>? selectedTagIds,
    String? searchQuery,
    String? selectedCategory,
    TagSortType? sortType,
    String? errorMessage,
  }) {
    return TagState(
      status: status ?? this.status,
      tags: tags ?? this.tags,
      selectedTagIds: selectedTagIds ?? this.selectedTagIds,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      sortType: sortType ?? this.sortType,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Типы сортировки тегов
enum TagSortType {
  /// По популярности (usageCount)
  popularity,
  
  /// По алфавиту
  alphabetical,
  
  /// По недавнему использованию
  recentlyUsed,
  
  /// По дате создания
  newest,
}

/// Provider для управления состоянием тегов
final tagStateProvider = StateNotifierProvider<TagStateNotifier, TagState>((ref) {
  return TagStateNotifier(ref.watch(tagRepositoryProvider));
});

/// Notifier для управления состоянием тегов
class TagStateNotifier extends StateNotifier<TagState> {
  final TagRepository _repository;

  TagStateNotifier(this._repository) : super(const TagState());

  /// Инициализация и загрузка тегов
  Future<void> initialize() async {
    state = state.copyWith(status: TagLoadStatus.loading);
    
    try {
      await _repository.initialize();
      final tags = await _repository.getAll(limit: 100);
      state = state.copyWith(
        status: TagLoadStatus.success,
        tags: tags,
      );
    } catch (e) {
      state = state.copyWith(
        status: TagLoadStatus.error,
        errorMessage: 'Failed to load tags: $e',
      );
    }
  }

  /// Обновление поискового запроса
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Выбор категории для фильтрации
  void selectCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  /// Изменение типа сортировки
  void changeSortType(TagSortType type) {
    state = state.copyWith(sortType: type);
  }

  /// Выбор/снятие выбора тега
  void toggleTagSelection(String tagId) {
    final selectedIds = Set<String>.from(state.selectedTagIds);
    if (selectedIds.contains(tagId)) {
      selectedIds.remove(tagId);
    } else {
      selectedIds.add(tagId);
    }
    state = state.copyWith(selectedTagIds: selectedIds);
  }

  /// Очистить выбор тегов
  void clearSelection() {
    state = state.copyWith(selectedTagIds: {});
  }

  /// Выбрать все видимые теги
  void selectAllVisible() {
    final visibleIds = state.filteredTags.map((t) => t.id).toSet();
    state = state.copyWith(selectedTagIds: visibleIds);
  }

  /// Поиск тегов
  Future<List<TagEntity>> searchTags(String query) async {
    if (query.trim().isEmpty) {
      return state.tags;
    }

    try {
      final results = await _repository.search(query, limit: 50);
      return results;
    } catch (e) {
      return [];
    }
  }

  /// Создание нового тега
  Future<TagEntity?> createTag({
    required String name,
    required String category,
    String? description,
  }) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final tag = TagEntity.create(
        id: id,
        name: name,
        category: category,
        description: description,
      );

      final created = await _repository.create(tag);
      
      // Добавление в локальный список
      state = state.copyWith(
        tags: [...state.tags, created],
      );

      return created;
    } on DuplicateTagException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to create tag: $e');
      return null;
    }
  }

  /// Обновление тега
  Future<bool> updateTag(TagEntity tag) async {
    try {
      await _repository.update(tag);
      
      // Обновление в локальном списке
      state = state.copyWith(
        tags: state.tags.map((t) => t.id == tag.id ? tag : t).toList(),
      );

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to update tag: $e');
      return false;
    }
  }

  /// Удаление тега
  Future<bool> deleteTag(String tagId) async {
    try {
      final success = await _repository.delete(tagId);
      
      if (success) {
        // Удаление из локального списка
        state = state.copyWith(
          tags: state.tags.where((t) => t.id != tagId).toList(),
          selectedTagIds: state.selectedTagIds.where((id) => id != tagId).toSet(),
        );
      }

      return success;
    } on ProtectedTagException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to delete tag: $e');
      return false;
    }
  }

  /// Инкремент использования тега
  Future<void> incrementTagUsage(String tagId) async {
    try {
      await _repository.incrementUsage(tagId);
      
      // Обновление в локальном списке
      final updatedTags = state.tags.map((tag) {
        if (tag.id == tagId) {
          return tag.copyWith(
            usageCount: tag.usageCount + 1,
            lastUsedAt: DateTime.now(),
          );
        }
        return tag;
      }).toList();

      state = state.copyWith(tags: updatedTags);
    } catch (e) {
      // Игнорирование ошибок для инкремента
    }
  }

  /// Слияние тегов
  Future<bool> mergeTags(String sourceTagId, String targetTagId) async {
    try {
      await _repository.mergeTags(sourceTagId, targetTagId);
      
      // Удаление source тега из списка
      state = state.copyWith(
        tags: state.tags.where((t) => t.id != sourceTagId).toList(),
        selectedTagIds: state.selectedTagIds
            .where((id) => id != sourceTagId)
            .toSet(),
      );

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to merge tags: $e');
      return false;
    }
  }

  /// Получение популярных тегов
  Future<List<TagEntity>> getPopularTags({int limit = 20}) async {
    try {
      return await _repository.getPopularTags(limit: limit);
    } catch (e) {
      return [];
    }
  }

  /// Получение недавно использованных тегов
  Future<List<TagEntity>> getRecentlyUsedTags({int limit = 20}) async {
    try {
      return await _repository.getRecentlyUsedTags(limit: limit);
    } catch (e) {
      return [];
    }
  }

  /// Получение тегов по категории
  Future<List<TagEntity>> getTagsByCategory(String category, {int limit = 50}) async {
    try {
      return await _repository.getByCategory(category, limit: limit);
    } catch (e) {
      return [];
    }
  }

  /// Перезагрузка данных
  Future<void> refresh() async {
    state = state.copyWith(status: TagLoadStatus.loading);
    
    try {
      await _repository.refresh();
      final tags = await _repository.getAll(limit: 100);
      state = state.copyWith(
        status: TagLoadStatus.success,
        tags: tags,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: TagLoadStatus.error,
        errorMessage: 'Failed to refresh tags: $e',
      );
    }
  }

  /// Очистка ошибки
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider для репозитория тегов (должен быть переопределен при инициализации)
final tagRepositoryProvider = Provider<TagRepository>((ref) {
  throw UnimplementedError('tagRepositoryProvider must be provided');
});

/// Provider для автодополнения тегов
final tagAutocompleteProvider = FutureProvider.autoDispose.family<List<TagEntity>, String>((ref, query) async {
  final repository = ref.watch(tagRepositoryProvider);
  
  if (query.trim().isEmpty) {
    return repository.getRecentlyUsedTags(limit: 10);
  }

  return repository.search(query, limit: 20);
});

/// Provider для популярных тегов
final popularTagsProvider = FutureProvider<List<TagEntity>>((ref) async {
  final repository = ref.watch(tagRepositoryProvider);
  return repository.getPopularTags(limit: 30);
});

/// Provider для недавно использованных тегов
final recentTagsProvider = FutureProvider<List<TagEntity>>((ref) async {
  final repository = ref.watch(tagRepositoryProvider);
  return repository.getRecentlyUsedTags(limit: 20);
});

/// Provider для тегов по категории
final tagsByCategoryProvider = FutureProvider.family<List<TagEntity>, String>((ref, category) async {
  final repository = ref.watch(tagRepositoryProvider);
  return repository.getByCategory(category, limit: 100);
});
