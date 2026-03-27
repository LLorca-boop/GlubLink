import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';

/// Media Fullscreen Screen - полноэкранный просмотр медиа
class MediaFullscreenScreen extends StatefulWidget {
  final List<Map<String, dynamic>> mediaFiles;
  final int initialIndex;
  final String? currentPath;
  final Function(String)? onTagClick;

  const MediaFullscreenScreen({
    super.key,
    required this.mediaFiles,
    this.initialIndex = 0,
    this.currentPath,
    this.onTagClick,
  });

  @override
  State<MediaFullscreenScreen> createState() => _MediaFullscreenScreenState();
}

class _MediaFullscreenScreenState extends State<MediaFullscreenScreen> {
  late int _currentIndex;
  bool _isCleanMode = false;
  double _zoomLevel = 1.0;
  bool _isRightPanelExpanded = true;
  String _selectedLanguage = 'Русский';
  final Map<String, dynamic> _editingTags = {};
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  Map<String, dynamic> get _currentMedia => widget.mediaFiles[_currentIndex];

  void _nextMedia() {
    if (_currentIndex < widget.mediaFiles.length - 1) {
      setState(() {
        _currentIndex++;
        _zoomLevel = 1.0;
      });
    }
  }

  void _previousMedia() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _zoomLevel = 1.0;
      });
    }
  }

  void _toggleCleanMode() {
    setState(() {
      _isCleanMode = !_isCleanMode;
    });
  }

  void _copyMedia() {
    // Копирование медиа
    debugPrint('Copying media: ${_currentMedia['path']}');
  }

  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel + 0.5).clamp(1.0, 5.0);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel - 0.5).clamp(1.0, 5.0);
    });
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _showInfo() {
    // Показать информацию о файле
    debugPrint('Showing info for: ${_currentMedia['path']}');
  }

  void _moveToTrash() {
    // Переместить в корзину
    debugPrint('Moving to trash: ${_currentMedia['path']}');
  }

  void _onTagTapped(String tagName) {
    widget.onTagClick?.call(tagName);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Stack(
        children: [
          // Центральная область с медиа
          Positioned.fill(
            child: _buildMediaArea(isDark),
          ),
          
          // Стрелки навигации
          if (!_isCleanMode) ...[
            Positioned(
              left: 20,
              top: 0,
              bottom: 0,
              child: Center(
                child: _buildNavButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: _currentIndex > 0 ? _previousMedia : null,
                  isEnabled: _currentIndex > 0,
                  isDark: isDark,
                ),
              ),
            ),
            Positioned(
              right: 20,
              top: 0,
              bottom: 0,
              child: Center(
                child: _buildNavButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: _currentIndex < widget.mediaFiles.length - 1 ? _nextMedia : null,
                  isEnabled: _currentIndex < widget.mediaFiles.length - 1,
                  isDark: isDark,
                ),
              ),
            ),
          ],
          
          // Нижняя панель управления
          if (!_isCleanMode)
            Positioned(
              left: 0,
              right: _isRightPanelExpanded ? 400 : 0,
              bottom: 0,
              child: _buildBottomBar(isDark),
            ),
          
          // Правая панель
          if (!_isCleanMode)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: _isRightPanelExpanded ? 400 : 0,
                child: ClipRect(
                  child: _buildRightPanel(isDark),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaArea(bool isDark) {
    final mediaType = _currentMedia['type'] as String;
    final filePath = _currentMedia['path'] as String;
    
    return Container(
      color: Colors.black,
      child: Center(
        child: Transform.scale(
          scale: _zoomLevel,
          child: _buildMediaContent(mediaType, filePath, isDark),
        ),
      ),
    );
  }

  Widget _buildMediaContent(String mediaType, String filePath, bool isDark) {
    switch (mediaType) {
      case 'gif':
        return Image.file(
          File(filePath),
          fit: BoxFit.contain,
          gaplessPlayback: true,
        );
      case 'video':
        return _buildVideoPreview(filePath, isDark);
      default:
        return Image.file(
          File(filePath),
          fit: BoxFit.contain,
        );
    }
  }

  Widget _buildVideoPreview(String filePath, bool isDark) {
    // TODO: Реализовать превью видео со случайным кадром
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Icon(Icons.videocam_rounded, size: 64, color: Colors.white54),
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.black87 : Colors.white.withOpacity(0.9),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Кнопка чистого экрана
          _buildIconButton(
            icon: _isCleanMode ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
            onTap: _toggleCleanMode,
            tooltip: _isCleanMode ? 'Exit Clean Mode' : 'Clean Mode',
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          
          // Кнопка копирования
          _buildIconButton(
            icon: Icons.copy_rounded,
            onTap: _copyMedia,
            tooltip: 'Copy Media',
            isDark: isDark,
          ),
          
          const Spacer(),
          
          // Кнопки зума
          _buildIconButton(
            icon: Icons.remove_rounded,
            onTap: _zoomOut,
            tooltip: 'Zoom Out',
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          
          // Слайдер зума
          Expanded(
            child: Slider(
              value: _zoomLevel,
              min: 1.0,
              max: 5.0,
              divisions: 8,
              onChanged: (value) {
                setState(() {
                  _zoomLevel = value;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          
          _buildIconButton(
            icon: Icons.add_rounded,
            onTap: _zoomIn,
            tooltip: 'Zoom In',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel(bool isDark) {
    return Container(
      color: isDark ? AppTheme.surfaceColorDark : AppTheme.surfaceColorLight,
      child: Column(
        children: [
          // Верхние кнопки
          _buildRightPanelTopBar(isDark),
          
          // Выпадающее меню языка
          _buildLanguageDropdown(isDark),
          
          // Поле с тегами
          Expanded(
            child: _buildTagsSection(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanelTopBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Кнопка редактирования
          _buildIconButton(
            icon: Icons.edit_rounded,
            onTap: _toggleEdit,
            tooltip: 'Edit Tags',
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          
          // Кнопка информации
          _buildIconButton(
            icon: Icons.info_outline_rounded,
            onTap: _showInfo,
            tooltip: 'Information',
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          
          // Кнопка удаления в корзину
          _buildIconButton(
            icon: Icons.delete_outline_rounded,
            onTap: _moveToTrash,
            tooltip: 'Move to Trash',
            isDark: isDark,
          ),
          
          const Spacer(),
          
          // Кнопка сворачивания панели
          _buildIconButton(
            icon: Icons.chevron_right_rounded,
            onTap: () {
              setState(() {
                _isRightPanelExpanded = !_isRightPanelExpanded;
              });
            },
            tooltip: 'Collapse Panel',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Language:',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _selectedLanguage,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'Русский', child: Text('Русский')),
              DropdownMenuItem(value: 'English', child: Text('English')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(bool isDark) {
    // Группировка тегов по категориям
    final categories = TagCategory.values;
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategorySection(category, isDark);
      },
    );
  }

  Widget _buildCategorySection(TagCategory category, bool isDark) {
    // Фильтрация тегов по категории
    final categoryTags = (widget.mediaFiles[_currentIndex]['tags'] as List?)
            ?.where((tag) => tag['category'] == category.name)
            .toList() ??
        [];
    
    if (categoryTags.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.displayName,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTagCategoryColor(category.name).withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categoryTags.map((tag) {
            return _buildTagChip(tag, isDark);
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTagChip(Map<String, dynamic> tag, bool isDark) {
    final tagName = tag['name'] as String;
    final category = tag['category'] as String? ?? 'general';
    final categoryColor = AppTheme.getTagCategoryColor(category);
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _onTagTapped(tagName),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: categoryColor,
              width: 1,
            ),
          ),
          child: Text(
            tagName,
            style: TextStyle(
              fontSize: 12,
              color: categoryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    VoidCallback? onTap,
    bool isEnabled = true,
    required bool isDark,
  }) {
    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isEnabled
                ? (isDark ? Colors.white10 : Colors.black12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            icon,
            color: isEnabled
                ? (isDark ? Colors.white : Colors.black87)
                : (isDark ? Colors.white10 : Colors.black12),
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    VoidCallback? onTap,
    String? tooltip,
    required bool isDark,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Tooltip(
          message: tooltip ?? '',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.black12,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isDark ? Colors.white : Colors.black87,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
