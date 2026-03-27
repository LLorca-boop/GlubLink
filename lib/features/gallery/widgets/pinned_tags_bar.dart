import 'package:flutter/material.dart';
import '../../../../core/animations/spring_config.dart';
import '../../../../core/theme/app_theme.dart';

class PinnedTagsBar extends StatefulWidget {
  final bool isDark;
  final List<String> pinnedTags;
  final String? activeFilterTag;
  final Function(String) onTagAdded;
  final Function(String) onTagRemoved;
  final Function(String)? onTagClick;
  final List<Map<String, dynamic>> tagPool;
  final List<Map<String, dynamic>> displayedMediaTags;

  const PinnedTagsBar({
    super.key,
    required this.isDark,
    required this.pinnedTags,
    this.activeFilterTag,
    required this.onTagAdded,
    required this.onTagRemoved,
    this.onTagClick,
    required this.tagPool,
    required this.displayedMediaTags,
  });

  @override
  State<PinnedTagsBar> createState() => _PinnedTagsBarState();
}

class _PinnedTagsBarState extends State<PinnedTagsBar> {
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<Map<String, dynamic>> _autocompleteSuggestions = [];
  bool _showAutocomplete = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    // ✅ Не закрываем overlay при потере фокуса - только по крестику
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _showAutocomplete = false;
    });
  }

  // ✅ Автодополнение как на e621 - после каждого символа
  void _updateAutocomplete(String query) {
    setState(() {
      if (query.isEmpty) {
        _autocompleteSuggestions = [];
        _showAutocomplete = false;
        return;
      }

      // ✅ Фильтруем теги из пула по запросу (только те, что count > 0)
      _autocompleteSuggestions = widget.tagPool.where((tag) {
        return tag['name'].toString().toLowerCase().contains(query.toLowerCase()) &&
            (tag['count'] as int) > 0;
      }).toList();

      _showAutocomplete = _autocompleteSuggestions.isNotEmpty;

      if (_showAutocomplete) {
        _showAutocompleteOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  void _showAutocompleteOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 320,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: const Offset(0, 40),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 400),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.isDark ? AppTheme.surfaceColorDark : AppTheme.surfaceColorLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isDark ? Colors.white10 : Colors.black12,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ Поле поиска с крестиком
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Search tags...',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: widget.isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: AppTheme.activeButtonColor,
                              size: 18,
                            ),
                            filled: true,
                            fillColor: widget.isDark ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            color: widget.isDark ? AppTheme.textColorDark : AppTheme.textColorLight,
                          ),
                          onChanged: _updateAutocomplete,
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              _selectTag(value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // ✅ Крестик для закрытия меню (единственный способ закрыть)
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            _removeOverlay();
                            setState(() {
                              _isSearchVisible = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: widget.isDark ? Colors.white10 : Colors.black12,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: AppTheme.activeButtonColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // ✅ Список подсказок тегов
                  if (_autocompleteSuggestions.isNotEmpty)
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _autocompleteSuggestions.length > 15 ? 15 : _autocompleteSuggestions.length,
                        itemBuilder: (context, index) {
                          final tag = _autocompleteSuggestions[index];
                          final categoryColor = AppTheme.getTagCategoryColor(tag['category'] as String);
                          final tagColor = _lightenColor(categoryColor, 0.3);
                          final isAlreadyPinned = widget.pinnedTags.contains(tag['name']);
                          
                          return MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () => _selectTag(tag['name'] as String),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  color: isAlreadyPinned
                                      ? (widget.isDark ? Colors.white10 : Colors.black12)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: categoryColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        tag['name'] as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: tagColor,
                                          fontWeight: isAlreadyPinned ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '${tag['count']}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: categoryColor.withValues(alpha: 0.7),
                                      ),
                                    ),
                                    if (isAlreadyPinned) ...[
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.check_circle_rounded,
                                        size: 14,
                                        color: AppTheme.activeButtonColor,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  else if (_searchController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No tags found',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _selectTag(String tagName) {
    // ✅ Можно добавить только тег из пула
    final tagExists = widget.tagPool.any((tag) => 
      tag['name'].toString().toLowerCase() == tagName.toLowerCase() &&
      (tag['count'] as int) > 0
    );
    
    if (tagExists) {
      widget.onTagAdded(tagName);
      _searchController.clear();
      _removeOverlay();
      setState(() {
        _isSearchVisible = false;
      });
    }
  }

  // ✅ Метод для закрытия overlay извне (при переключении вкладок)
  void closeOverlay() {
    _removeOverlay();
    setState(() {
      _isSearchVisible = false;
    });
  }

  Color _lightenColor(Color color, double amount) {
    return Color.fromRGBO(
      (color.r + (255 - color.r) * amount).round(),
      (color.g + (255 - color.g) * amount).round(),
      (color.b + (255 - color.b) * amount).round(),
      color.a,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: widget.isDark ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
        border: Border(
          bottom: BorderSide(
            color: widget.isDark ? Colors.white10 : Colors.black12,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPinnedTag(
                    tag: 'All',
                    isActive: widget.activeFilterTag == 'All',
                    isDark: widget.isDark,
                    onRemove: widget.pinnedTags.length > 1 ? () => widget.onTagRemoved('All') : null,
                  ),
                  const SizedBox(width: 8),
                  for (final tag in widget.pinnedTags)
                    if (tag != 'All') ...[
                      _buildPinnedTag(
                        tag: tag,
                        isActive: widget.activeFilterTag == tag,
                        isDark: widget.isDark,
                        onRemove: () => widget.onTagRemoved(tag),
                      ),
                      const SizedBox(width: 8),
                    ],
                  CompositedTransformTarget(
                    link: _layerLink,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSearchVisible = !_isSearchVisible;
                          });
                          if (_isSearchVisible) {
                            _showAutocompleteOverlay();
                            // ✅ Фокус на поле ввода после открытия
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _searchFocusNode.requestFocus();
                            });
                          }
                        },
                        child: AnimatedContainer(
                          duration: GlubSpringConfig.microInteraction,
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppTheme.activeButtonColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: AppTheme.backgroundColorDark,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinnedTag({
    required String tag,
    required bool isActive,
    required bool isDark,
    VoidCallback? onRemove,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          widget.onTagClick?.call(tag);
        },
        child: AnimatedContainer(
          duration: GlubSpringConfig.microInteraction,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.activeButtonColor
                : (isDark ? AppTheme.surfaceColorDark : AppTheme.surfaceColorLight),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tag,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isActive
                      ? (isDark ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight)
                      : (isDark ? AppTheme.textColorDark : AppTheme.textColorLight),
                ),
              ),
              if (onRemove != null && tag != 'All') ...[
                const SizedBox(width: 6),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      onRemove();
                    },
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: isActive
                          ? (isDark ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight)
                          : (isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}