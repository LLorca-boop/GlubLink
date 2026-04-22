// lib/features/gallery/presentation/providers/gallery_providers.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../workspaces/data/models/filter_rules.dart';
import '../../domain/models/parsed_query.dart';
import '../../domain/utils/query_parser.dart';
import '../../data/models/gallery_view_mode.dart';
import '../../domain/repositories/gallery_repository.dart';

/// Состояние галереи
class GalleryState {
  final String searchQuery;
  final ParsedQuery parsedQuery;
  final GalleryViewMode viewMode;
  final double scrollOffset;
  final List<String> blockIds;
  final Map<String, int> contextTags;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final FilterRules? activeWorkspaceRules;

  const GalleryState({
    this.searchQuery = '',
    this.parsedQuery = const ParsedQuery(),
    this.viewMode = GalleryViewMode.masonry,
    this.scrollOffset = 0.0,
    this.blockIds = const [],
    this.contextTags = const {},
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.activeWorkspaceRules,
  });

  GalleryState copyWith({
    String? searchQuery,
    ParsedQuery? parsedQuery,
    GalleryViewMode? viewMode,
    double? scrollOffset,
    List<String>? blockIds,
    Map<String, int>? contextTags,
    bool? isLoading,
    bool? hasMore,
    String? error,
    FilterRules? activeWorkspaceRules,
  }) {
    return GalleryState(
      searchQuery: searchQuery ?? this.searchQuery,
      parsedQuery: parsedQuery ?? this.parsedQuery,
      viewMode: viewMode ?? this.viewMode,
      scrollOffset: scrollOffset ?? this.scrollOffset,
      blockIds: blockIds ?? this.blockIds,
      contextTags: contextTags ?? this.contextTags,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      activeWorkspaceRules: activeWorkspaceRules ?? this.activeWorkspaceRules,
    );
  }
}

/// Провайдер состояния галереи
final galleryStateProvider = StateNotifierProvider<GalleryNotifier, GalleryState>(
  (ref) => GalleryNotifier(ref),
);

/// Нотификатор состояния галереи
class GalleryNotifier extends StateNotifier<GalleryState> {
  final Ref ref;
  Timer? _debounceTimer;
  
  // Дебаунс для поиска (150ms)
  static const Duration _debounceDuration = Duration(milliseconds: 150);

  GalleryNotifier(this.ref) : super(const GalleryState());

  /// Обновление поискового запроса с дебаунсом
  void updateSearchQuery(String query) {
    _debounceTimer?.cancel();
    
    state = state.copyWith(
      searchQuery: query,
      isLoading: query.isNotEmpty,
    );

    _debounceTimer = Timer(_debounceDuration, () {
      final parsed = QueryParser.parse(query);
      state = state.copyWith(
        parsedQuery: parsed,
        isLoading: false,
      );
      _applyFilters();
    });
  }

  /// Изменение режима просмотра
  void changeViewMode(GalleryViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  /// Обновление позиции скролла
  void updateScrollOffset(double offset) {
    state = state.copyWith(scrollOffset: offset);
    
    // Проверка на достижение конца для ленивой загрузки
    _checkLoadMore(offset);
  }

  /// Применение фильтров
  Future<void> _applyFilters() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Здесь будет вызов репозитория
      // final repository = ref.read(galleryRepositoryProvider);
      // final result = await repository.getFilteredBlockIds(
      //   query: state.parsedQuery,
      //   workspaceRules: state.activeWorkspaceRules,
      // );
      
      // Имитация задержки
      await Future.delayed(const Duration(milliseconds: 100));
      
      state = state.copyWith(
        isLoading: false,
        // blockIds: result,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Проверка необходимости загрузки дополнительных элементов
  void _checkLoadMore(double offset) {
    // Порог загрузки: maxScrollExtent - 500px
    const loadThreshold = 500.0;
    
    // Получаем максимальную позицию скролла (должно приходить из виджета)
    // Для упрощения проверяем относительное значение
    if (state.hasMore && !state.isLoading) {
      // Логика ленивой загрузки
      // if (offset > maxScrollExtent - loadThreshold) {
      //   _loadMore();
      // }
    }
  }

  /// Загрузка дополнительных элементов
  Future<void> _loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    
    // Логика загрузки следующей страницы
  }

  /// Обновление контекстных тегов
  void updateContextTags(Map<String, int> tags) {
    state = state.copyWith(contextTags: tags);
  }

  /// Фильтрация по тегу из контекстной панели
  void filterByTag(String tag, {bool exclude = false}) {
    final currentQuery = state.searchQuery;
    final prefix = exclude ? '-' : '';
    final tagString = '$prefix$tag';
    
    // Проверяем, есть ли уже такой тег в запросе
    if (currentQuery.contains(RegExp(r'\b$tagString\b'))) {
      // Удаляем тег из запроса
      final newQuery = currentQuery.replaceAll(RegExp(r'\s*$tagString\\b'), '');
      updateSearchQuery(newQuery.trim());
    } else {
      // Добавляем тег к запросу
      final newQuery = currentQuery.isEmpty ? tagString : '$currentQuery $tagString';
      updateSearchQuery(newQuery);
    }
  }

  /// Установка правил workspace
  void setWorkspaceRules(FilterRules? rules) {
    state = state.copyWith(activeWorkspaceRules: rules);
    _applyFilters();
  }

  /// Сброс фильтров
  void resetFilters() {
    _debounceTimer?.cancel();
    state = const GalleryState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Провайдер для получения отфильтрованных блоков
final filteredBlocksProvider = StreamProvider<List<String>>((ref) {
  final galleryState = ref.watch(galleryStateProvider);
  // Возвращает поток ID блоков на основе текущего состояния
  // В реальной реализации будет подписка на репозиторий
  return Stream.value(galleryState.blockIds);
});

/// Провайдер для контекстных тегов
final contextTagsProvider = Provider<Map<String, int>>((ref) {
  final galleryState = ref.watch(galleryStateProvider);
  return galleryState.contextTags;
});

/// Провайдер текущего режима просмотра
final currentViewModeProvider = Provider<GalleryViewMode>((ref) {
  final galleryState = ref.watch(galleryStateProvider);
  return galleryState.viewMode;
});
