import 'package:flutter/material.dart';
import '../../../../core/animations/spring_config.dart';
import '../../../../core/theme/app_theme.dart';

class GalleryRightPanel extends StatefulWidget {
  final bool isDark;
  final String searchQuery;
  final Function(String) onSearchChanged;
  final Function(String) onSearchSubmitted;
  final VoidCallback onCollapse;
  final Function(String) onTagAdd;
  final List<Map<String, dynamic>> tags;
  final String tagSortMode;
  final bool isExpanded;
  final String selectedLanguage;
  final Function(String) onLanguageChanged;
  final Function(String) onTagSortModeChanged;
  final Function(String, String) onAddNewTag;
  final Function(String) onRemoveTag;
  final List<Map<String, dynamic>> displayedMediaTags;
  final String? activeFilterTag;

  const GalleryRightPanel({
    super.key,
    required this.isDark,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.onCollapse,
    required this.onTagAdd,
    required this.tags,
    this.tagSortMode = 'ByCount',
    required this.isExpanded,
    required this.selectedLanguage,
    required this.onLanguageChanged,
    required this.onTagSortModeChanged,
    required this.onAddNewTag,
    required this.onRemoveTag,
    required this.displayedMediaTags,
    this.activeFilterTag,
  });

  @override
  State<GalleryRightPanel> createState() => _GalleryRightPanelState();
}

class _GalleryRightPanelState extends State<GalleryRightPanel> {
  bool _showSettings = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  double _fontSize = 16.0; // ✅ По умолчанию 16
  bool _showAutocomplete = false;
  List<Map<String, dynamic>> _autocompleteSuggestions = [];
  final LayerLink _autocompleteLayerLink = LayerLink();
  OverlayEntry? _autocompleteOverlayEntry;
  
  // ✅ Для редактирования тега
  String? _editingTagName;
  final TextEditingController _editController = TextEditingController();
  final FocusNode _editFocusNode = FocusNode();

  // ✅ Для добавления нового тега
  bool _showAddTagForm = false;
  final TextEditingController _newTagController = TextEditingController();
  String _newTagCategory = 'General';

  final Map<String, bool> _categoryFilters = {
    'Artist': true,
    'Copyrights': true,
    'Characters': true,
    'Species': true,
    'General': true,
    'Meta': true,
    'References': true,
  };

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
    _searchFocusNode.addListener(_onFocusChange);
    _editFocusNode.addListener(_onEditFocusChange);
  }

  @override
  void didUpdateWidget(GalleryRightPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery && !_searchFocusNode.hasFocus) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    _editController.dispose();
    _editFocusNode.removeListener(_onEditFocusChange);
    _editFocusNode.dispose();
    _newTagController.dispose();
    _removeAutocompleteOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_searchFocusNode.hasFocus) {
      _removeAutocompleteOverlay();
      setState(() {
        _showAutocomplete = false;
      });
    }
  }

  void _onEditFocusChange() {
    // ✅ Если потеряли фокус - сохраняем изменения
    if (!_editFocusNode.hasFocus && _editingTagName != null) {
      _saveTagEdit();
    }
  }

  void _removeAutocompleteOverlay() {
    _autocompleteOverlayEntry?.remove();
    _autocompleteOverlayEntry = null;
  }

  // ✅ Автодополнение как на e621
  void _updateAutocomplete(String query) {
    setState(() {
      if (query.isEmpty) {
        _autocompleteSuggestions = [];
        _showAutocomplete = false;
        _removeAutocompleteOverlay();
        return;
      }

      _autocompleteSuggestions = widget.tags.where((tag) {
        return tag['name'].toString().toLowerCase().contains(query.toLowerCase()) &&
            (tag['count'] as int) > 0;
      }).toList();

      _showAutocomplete = _autocompleteSuggestions.isNotEmpty;

      if (_showAutocomplete) {
        _showAutocompleteOverlay();
      } else {
        _removeAutocompleteOverlay();
      }
    });
  }

  void _showAutocompleteOverlay() {
    _removeAutocompleteOverlay();

    _autocompleteOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 280,
        child: CompositedTransformFollower(
          link: _autocompleteLayerLink,
          offset: const Offset(0, 36),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: widget.isDark ? AppTheme.surfaceColorDark : AppTheme.surfaceColorLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.isDark ? Colors.white10 : Colors.black12,
                  width: 1,
                ),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _autocompleteSuggestions.length > 10 ? 10 : _autocompleteSuggestions.length,
                itemBuilder: (context, index) {
                  final tag = _autocompleteSuggestions[index];
                  final categoryColor = AppTheme.getTagCategoryColor(tag['category'] as String);
                  final tagColor = _lightenColor(categoryColor, 0.3);
                  
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        _searchController.text = tag['name'] as String;
                        widget.onSearchChanged(tag['name'] as String);
                        _removeAutocompleteOverlay();
                        setState(() {
                          _showAutocomplete = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: index == 0 
                              ? (widget.isDark ? Colors.white10 : Colors.black12)
                              : Colors.transparent,
                          borderRadius: index == 0 
                              ? const BorderRadius.vertical(top: Radius.circular(8))
                              : BorderRadius.zero,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
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
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${tag['count']}',
                              style: TextStyle(
                                fontSize: 10,
                                color: categoryColor.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_autocompleteOverlayEntry!);
  }

  List<Map<String, dynamic>> get _filteredTags {
    var filtered = List<Map<String, dynamic>>.from(widget.tags);
    
    filtered = filtered.where((tag) => (tag['count'] as int) > 0).toList();
    filtered = filtered.where((tag) => _categoryFilters[tag['category']] == true).toList();
    
    if (widget.activeFilterTag != null && widget.activeFilterTag != 'All') {
      final displayedTagNames = widget.displayedMediaTags
          .map((t) => t['name'] as String)
          .toSet();
      filtered = filtered.where((tag) => displayedTagNames.contains(tag['name'])).toList();
    }
    
    if (widget.searchQuery.isNotEmpty) {
      final displayedTagNames = widget.displayedMediaTags
          .map((t) => t['name'] as String)
          .toSet();
      filtered = filtered.where((tag) => displayedTagNames.contains(tag['name'])).toList();
    }
    
    switch (widget.tagSortMode) {
      case 'ByCount':
        filtered.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
        break;
      case 'Alphabetical':
        filtered.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
        break;
      case 'ByFrequency':
        filtered.sort((a, b) => (b['frequency'] as int? ?? 0).compareTo(a['frequency'] as int? ?? 0));
        break;
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildCollapseArrow(),
        AnimatedContainer(
          duration: GlubSpringConfig.panelTransition,
          curve: Curves.easeInOut,
          width: widget.isExpanded ? 280 : 0,
          decoration: BoxDecoration(
            color: widget.isDark ? AppTheme.sidebarColorDark : AppTheme.sidebarColorLight,
            border: Border(
              left: BorderSide(
                color: widget.isDark ? Colors.white10 : Colors.black12,
                width: 1,
              ),
            ),
          ),
          child: ClipRect(
            child: widget.isExpanded
                ? Column(
                    children: [
                      _buildSearchBar(),
                      _buildSettingsButton(),
                      Expanded(child: _buildTagsList()),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _buildCollapseArrow() {
    return Container(
      width: 24,
      height: double.infinity,
      color: widget.isDark ? AppTheme.sidebarColorDark : AppTheme.sidebarColorLight,
      child: Center(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onCollapse,
            child: AnimatedContainer(
              duration: GlubSpringConfig.microInteraction,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: widget.isDark ? AppTheme.surfaceColorDark : AppTheme.surfaceColorLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                widget.isExpanded
                    ? Icons.chevron_right_rounded
                    : Icons.chevron_left_rounded,
                color: AppTheme.activeButtonColor,
                size: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: CompositedTransformTarget(
        link: _autocompleteLayerLink,
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: _updateAutocomplete,
          onSubmitted: widget.onSearchSubmitted,
          onTap: () {
            if (_searchController.text.isNotEmpty && _autocompleteSuggestions.isNotEmpty) {
              _showAutocompleteOverlay();
            }
          },
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(
              fontSize: 13,
              color: widget.isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppTheme.activeButtonColor,
              size: 18,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        widget.onSearchChanged('');
                        _removeAutocompleteOverlay();
                        setState(() {
                          _showAutocomplete = false;
                        });
                      },
                      child: Icon(
                        Icons.clear_rounded,
                        color: widget.isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                        size: 16,
                      ),
                    ),
                  )
                : null,
            filled: true,
            fillColor: widget.isDark ? AppTheme.surfaceColorDark : AppTheme.surfaceColorLight,
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
        ),
      ),
    );
  }

  Widget _buildSettingsButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showSettings = !_showSettings;
                });
              },
              child: AnimatedContainer(
                duration: GlubSpringConfig.microInteraction,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _showSettings
                      ? AppTheme.activeButtonColor
                      : (widget.isDark ? AppTheme.surfaceColorDark : AppTheme.surfaceColorLight),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.settings_rounded,
                  color: _showSettings
                      ? (widget.isDark ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight)
                      : AppTheme.activeButtonColor,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsList() {
    return Column(
      children: [
        if (_showSettings) _buildSettingsMenu(),
        Expanded(
          child: _filteredTags.isEmpty
              ? Center(
                  child: Text(
                    widget.searchQuery.isNotEmpty || (widget.activeFilterTag != null && widget.activeFilterTag != 'All')
                        ? 'No tags found'
                        : 'No tags with media',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  itemCount: _filteredTags.length,
                  itemBuilder: (context, index) {
                    final tag = _filteredTags[index];
                    return _buildTagItem(tag);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSettingsMenu() {
    if (!_showSettings) return const SizedBox.shrink();
    return AnimatedContainer(
      duration: GlubSpringConfig.microInteraction,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettingsOption(
            icon: Icons.sort_rounded,
            title: 'By Count',
            isActive: widget.tagSortMode == 'ByCount',
            onTap: () => widget.onTagSortModeChanged('ByCount'),
          ),
          const SizedBox(height: 3),
          _buildSettingsOption(
            icon: Icons.sort_by_alpha_rounded,
            title: 'Alphabetical',
            isActive: widget.tagSortMode == 'Alphabetical',
            onTap: () => widget.onTagSortModeChanged('Alphabetical'),
          ),
          const SizedBox(height: 3),
          _buildSettingsOption(
            icon: Icons.trending_up_rounded,
            title: 'By Frequency',
            isActive: widget.tagSortMode == 'ByFrequency',
            onTap: () => widget.onTagSortModeChanged('ByFrequency'),
          ),
          const Divider(height: 16),
          // ✅ Размер шрифта [13, 19], по умолчанию 16
          Text(
            'Font Size: ${_fontSize.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 11,
              color: widget.isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
            ),
          ),
          Slider(
            value: _fontSize,
            min: 13.0,
            max: 19.0,
            divisions: 6,
            onChanged: (value) {
              setState(() {
                _fontSize = value;
              });
            },
          ),
          const Divider(height: 16),
          // ✅ Добавить новый тег с категорией
          Text(
            'Add New Tag',
            style: TextStyle(
              fontSize: 11,
              color: widget.isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 4),
          _buildAddTagForm(),
          const Divider(height: 16),
          Text(
            'Categories',
            style: TextStyle(
              fontSize: 11,
              color: widget.isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 4),
          ..._categoryFilters.entries.map((entry) => _buildCategoryFilter(entry.key, entry.value)),
        ],
      ),
    );
  }

  // ✅ Форма добавления нового тега с обязательной категорией
  Widget _buildAddTagForm() {
    if (!_showAddTagForm) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _showAddTagForm = true;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.activeButtonColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.add_rounded,
                  size: 14,
                  color: AppTheme.activeButtonColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Add Tag',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.activeButtonColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        TextField(
          controller: _newTagController,
          decoration: InputDecoration(
            hintText: 'Tag name',
            hintStyle: TextStyle(
              fontSize: 11,
              color: widget.isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
            ),
            filled: true,
            fillColor: widget.isDark ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          style: const TextStyle(fontSize: 11),
          onSubmitted: (_) => _addNewTag(),
        ),
        const SizedBox(height: 4),
        DropdownButton<String>(
          value: _newTagCategory,
          isExpanded: true,
          dropdownColor: widget.isDark ? AppTheme.surfaceColorDark : AppTheme.surfaceColorLight,
          items: ['Artist', 'Copyrights', 'Characters', 'Species', 'General', 'Meta', 'References']
              .map((cat) => DropdownMenuItem(
                    value: cat,
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppTheme.getTagCategoryColor(cat),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cat,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _newTagCategory = value;
              });
            }
          },
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _addNewTag,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.activeButtonColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 10,
                          color: widget.isDark ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showAddTagForm = false;
                    _newTagController.clear();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.isDark ? Colors.white10 : Colors.black12,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Text(
                      'Cancel',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _addNewTag() {
    final tagName = _newTagController.text.trim();
    if (tagName.isNotEmpty) {
      widget.onAddNewTag(tagName, _newTagCategory);
      setState(() {
        _showAddTagForm = false;
        _newTagController.clear();
      });
    }
  }

  Widget _buildCategoryFilter(String category, bool isEnabled) {
    final color = AppTheme.getTagCategoryColor(category);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              category,
              style: TextStyle(
                fontSize: 10,
                color: widget.isDark ? AppTheme.textColorDark : AppTheme.textColorLight,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Transform.scale(
            scale: 0.7,
            child: Switch(
              value: isEnabled,
              onChanged: (value) {
                setState(() {
                  _categoryFilters[category] = value;
                });
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.activeButtonColor.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 12,
                color: isActive
                    ? AppTheme.activeButtonColor
                    : (widget.isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: isActive
                      ? AppTheme.activeButtonColor
                      : (widget.isDark ? AppTheme.textColorDark : AppTheme.textColorLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Тег с редактированием по клику на название
  Widget _buildTagItem(Map<String, dynamic> tag) {
    final categoryColor = AppTheme.getTagCategoryColor(tag['category'] as String);
    final showCount = widget.tagSortMode != 'Alphabetical';
    final isProtected = tag['isProtected'] == true;
    final mediaCount = tag['count'] as int;
    final isEditing = _editingTagName == tag['name'];

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // ✅ Клик на тег - редактирование
          if (!isEditing) {
            setState(() {
              _editingTagName = tag['name'] as String;
              _editController.text = tag['name'] as String;
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _editFocusNode.requestFocus();
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              // ✅ "+" кнопка слева (добавляет в поиск)
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    widget.onTagAdd(tag['name'] as String);
                  },
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: categoryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isEditing ? Icons.remove_rounded : Icons.add_rounded,
                      color: widget.isDark ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
                      size: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // ✅ Название тега (редактируемое)
              Expanded(
                child: isEditing
                    ? TextField(
                        controller: _editController,
                        focusNode: _editFocusNode,
                        autofocus: true,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          filled: true,
                          fillColor: widget.isDark ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: categoryColor),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: _fontSize,
                          color: categoryColor,
                          fontWeight: FontWeight.w500,
                        ),
                        onSubmitted: (_) => _saveTagEdit(),
                      )
                    : Text(
                        tag['name'] as String,
                        style: TextStyle(
                          fontSize: _fontSize,
                          color: categoryColor, // ✅ Цвет тега = цвет категории
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              // ✅ Количество справа
              if (showCount) ...[
                const SizedBox(width: 6),
                Text(
                  mediaCount.toString(),
                  style: TextStyle(
                    fontSize: _fontSize - 1,
                    color: categoryColor.withValues(alpha: 0.7), // ✅ Цвет числа = цвет категории
                  ),
                ),
              ],
              // ✅ Кнопка удаления (если не защищён)
              if (!isProtected) ...[
                const SizedBox(width: 6),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      _confirmTagDelete(tag['name'] as String);
                    },
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 16,
                      color: widget.isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
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

  void _saveTagEdit() {
    if (_editingTagName != null) {
      final newName = _editController.text.trim();
      if (newName.isNotEmpty && newName != _editingTagName) {
        // ✅ Здесь должна быть логика переименования тега в БД
        debugPrint('Rename tag: $_editingTagName -> $newName');
      }
      setState(() {
        _editingTagName = null;
      });
    }
  }

  void _confirmTagDelete(String tagName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDark ? AppTheme.surfaceColorDark : AppTheme.surfaceColorLight,
        title: Text(
          'Delete Tag',
          style: TextStyle(
            color: widget.isDark ? AppTheme.textColorDark : AppTheme.textColorLight,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$tagName" from the tag pool?',
          style: TextStyle(
            color: widget.isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: widget.isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              widget.onRemoveTag(tagName);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Color _lightenColor(Color color, double amount) {
    return Color.fromRGBO(
      (color.r + (255 - color.r) * amount).round(),
      (color.g + (255 - color.g) * amount).round(),
      (color.b + (255 - color.b) * amount).round(),
      color.a,
    );
  }
}