// lib/features/gallery/presentation/widgets/gallery_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../providers/gallery_providers.dart';
import '../../data/models/gallery_view_mode.dart';
import '../../../../shared/cache/image_cache_manager.dart';

/// Верхняя панель управления галереей
class GalleryToolbar extends ConsumerWidget {
  const GalleryToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(galleryStateProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Первая строка: навигация и поиск
          Row(
            children: [
              // Кнопки истории навигации
              _NavigationButtons(),
              
              const SizedBox(width: 16),
              
              // Поисковая строка
              Expanded(
                child: _SearchField(
                  initialValue: state.searchQuery,
                  onChanged: (query) => ref
                      .read(galleryStateProvider.notifier)
                      .updateSearchQuery(query),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Переключатель режима просмотра
              _ViewModeSelector(),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Вторая строка: быстрые фильтры (закреплённые теги)
          _QuickFilters(),
        ],
      ),
    );
  }
}

/// Кнопки навигации (назад/вперёд)
class _NavigationButtons extends StatelessWidget {
  const _NavigationButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Логика навигации назад
          },
          tooltip: 'Назад',
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            // Логика навигации вперёд
          },
          tooltip: 'Вперёд',
        ),
      ],
    );
  }
}

/// Поле поиска с парсером запросов
class _SearchField extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Поиск: fox -sketch (cat || dog)',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onChanged: widget.onChanged,
      onSubmitted: (_) {},
    );
  }
}

/// Переключатель режимов просмотра
class _ViewModeSelector extends ConsumerWidget {
  const _ViewModeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(currentViewModeProvider);
    
    return SegmentedButton<GalleryViewMode>(
      segments: GalleryViewMode.values.map((mode) {
        return ButtonSegment(
          value: mode,
          icon: Icon(mode.icon),
          tooltip: mode.displayName,
        );
      }).toList(),
      selected: {currentMode},
      onSelectionChanged: (selected) {
        if (selected.isNotEmpty) {
          ref.read(galleryStateProvider.notifier).changeViewMode(selected.first);
        }
      },
      showSelectedIcon: false,
    );
  }
}

/// Быстрые фильтры (закреплённые теги)
class _QuickFilters extends ConsumerWidget {
  const _QuickFilters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextTags = ref.watch(contextTagsProvider);
    
    if (contextTags.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: contextTags.entries.take(10).map((entry) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text('${entry.key} (${entry.value})'),
              onSelected: (selected) {
                ref.read(galleryStateProvider.notifier).filterByTag(entry.key);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Сетка контента с виртуализацией
class GalleryGrid extends ConsumerStatefulWidget {
  const GalleryGrid({super.key});

  @override
  ConsumerState<GalleryGrid> createState() => _GalleryGridState();
}

class _GalleryGridState extends ConsumerState<GalleryGrid> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = ref.read(galleryStateProvider);
    ref.read(galleryStateProvider.notifier).updateScrollOffset(
      _scrollController.offset,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(galleryStateProvider);
    final viewMode = state.viewMode;
    
    if (state.isLoading && state.blockIds.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Ошибка: ${state.error}'),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          // Сохраняем позицию скролла при остановке
        }
        return false;
      },
      child: _buildGrid(viewMode, state.blockIds),
    );
  }

  Widget _buildGrid(GalleryViewMode viewMode, List<String> blockIds) {
    switch (viewMode) {
      case GalleryViewMode.masonry:
        return _buildMasonryGrid(blockIds);
      case GalleryViewMode.justified:
        return _buildJustifiedGrid(blockIds);
      case GalleryViewMode.list:
        return _buildListGrid(blockIds);
      case GalleryViewMode.timeline:
        return _buildTimelineGrid(blockIds);
    }
  }

  /// Masonry сетка (кирпичная кладка)
  Widget _buildMasonryGrid(List<String> blockIds) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = GalleryViewMode.masonry.getDefaultColumnCount(
          constraints.maxWidth,
        );
        final columnWidth = (constraints.maxWidth - (columnCount - 1) * 8) / columnCount;

        return ListView.builder(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          itemCount: blockIds.length,
          itemBuilder: (context, index) {
            return _MediaCard(
              blockId: blockIds[index],
              width: columnWidth,
              viewMode: GalleryViewMode.masonry,
            );
          },
        );
      },
    );
  }

  /// Justified сетка (выровненные ряды)
  Widget _buildJustifiedGrid(List<String> blockIds) {
    return GridView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.5,
      ),
      itemCount: blockIds.length,
      itemBuilder: (context, index) {
        return _MediaCard(
          blockId: blockIds[index],
          viewMode: GalleryViewMode.justified,
        );
      },
    );
  }

  /// List вид (детальный список)
  Widget _buildListGrid(List<String> blockIds) {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: blockIds.length,
      itemBuilder: (context, index) {
        return _MediaCard(
          blockId: blockIds[index],
          viewMode: GalleryViewMode.list,
        );
      },
    );
  }

  /// Timeline вид (хронология)
  Widget _buildTimelineGrid(List<String> blockIds) {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: blockIds.length,
      itemBuilder: (context, index) {
        return _MediaCard(
          blockId: blockIds[index],
          viewMode: GalleryViewMode.timeline,
        );
      },
    );
  }
}

/// Карточка медиа-блока
class _MediaCard extends StatefulWidget {
  final String blockId;
  final double? width;
  final GalleryViewMode viewMode;

  const _MediaCard({
    required this.blockId,
    this.width,
    required this.viewMode,
  });

  @override
  State<_MediaCard> createState() => _MediaCardState();
}

class _MediaCardState extends State<_MediaCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: _buildCard(context),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: _isHovered
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Превью изображения
          _buildPreview(),
          
          // Индикатор типа
          Positioned(
            top: 8,
            left: 8,
            child: _TypeIndicator(),
          ),
          
          // Панель быстрых действий (появляется при hover)
          if (_isHovered)
            Positioned(
              bottom: 8,
              right: 8,
              child: _QuickActionsPanel(),
            ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    // В реальной реализации здесь будет загрузка превью с кэшем
    return FutureBuilder<Uint8List?>(
      future: ImageCacheManager().getCachedImage(widget.blockId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder();
            },
          );
        } else if (snapshot.hasError) {
          return _buildPlaceholder();
        } else {
          return _buildPlaceholder();
        }
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: Center(
        child: Icon(Icons.image, size: 48, color: Colors.grey[600]),
      ),
    );
  }
}

/// Индикатор типа контента
class _TypeIndicator extends StatelessWidget {
  const _TypeIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            'IMG',
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

/// Панель быстрых действий
class _QuickActionsPanel extends StatelessWidget {
  const _QuickActionsPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.favorite_border, size: 20),
            onPressed: () {
              // Добавить в избранное
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          IconButton(
            icon: const Icon(Icons.tag, size: 20),
            onPressed: () {
              // Добавить теги
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, size: 20),
            onPressed: () {
              // Показать информацию
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

/// Контекстная панель с тегами
class ContextTagsPanel extends ConsumerWidget {
  const ContextTagsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(contextTagsProvider);
    
    // Сортировка: по частоте → алфавиту → категории
    final sortedTags = tags.entries.toList()
      ..sort((a, b) {
        // Сначала по частоте (убывание)
        final freqCompare = b.value.compareTo(a.value);
        if (freqCompare != 0) return freqCompare;
        
        // Затем по алфавиту
        return a.key.compareTo(b.key);
      });

    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Контекстные теги',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: sortedTags.length,
              itemBuilder: (context, index) {
                final entry = sortedTags[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: FilterChip(
                    label: Text('${entry.key} (${entry.value})'),
                    onSelected: (selected) {
                      ref.read(galleryStateProvider.notifier).filterByTag(entry.key);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
