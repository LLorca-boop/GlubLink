import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/media_entity.dart';
import '../../core/models/tag_entity.dart';
import '../widgets/media_grid.dart';
import '../widgets/gallery_top_bar.dart';
import '../widgets/pinned_tags_bar.dart';
import '../widgets/gallery_right_panel.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String? _selectedFolderPath;
  bool _isRightPanelExpanded = true;
  LayoutMode _layoutMode = LayoutMode.justified;
  final List<TagEntity> _pinnedTags = [];
  final List<MediaEntity> _mediaItems = [];
  
  // Навигационная история
  final List<String> _backHistory = [];
  final List<String> _forwardHistory = [];
  String _currentPath = '';

  @override
  void initState() {
    super.initState();
    _checkInitialFolder();
  }

  Future<void> _checkInitialFolder() async {
    // Проверка выбранной папки при первом запуске
    setState(() {
      _selectedFolderPath = null; // В реальной реализации загружается из БД
    });
  }

  Future<void> _selectMainFolder() async {
    // В реальной реализации: file_picker для выбора папки
    setState(() {
      _selectedFolderPath = '/home/user/Pictures'; // Mock
      _currentPath = _selectedFolderPath!;
      _loadMediaForPath(_currentPath);
    });
  }

  void _loadMediaForPath(String path) {
    // В реальной реализации: загрузка из БД/файловой системы
    setState(() {
      _mediaItems.clear();
      // Mock данные для демонстрации
    });
  }

  void _navigateBack() {
    if (_backHistory.isNotEmpty) {
      setState(() {
        _forwardHistory.add(_currentPath);
        _currentPath = _backHistory.removeLast();
        _loadMediaForPath(_currentPath);
      });
    }
  }

  void _navigateForward() {
    if (_forwardHistory.isNotEmpty) {
      setState(() {
        _backHistory.add(_currentPath);
        _currentPath = _forwardHistory.removeLast();
        _loadMediaForPath(_currentPath);
      });
    }
  }

  Future<void> _refresh() async {
    if (_currentPath.isNotEmpty) {
      _loadMediaForPath(_currentPath);
    }
  }

  void _toggleRightPanel() {
    setState(() {
      _isRightPanelExpanded = !_isRightPanelExpanded;
    });
  }

  void _onLayoutModeChanged(LayoutMode mode) {
    setState(() {
      _layoutMode = mode;
    });
  }

  void _onMediaTap(MediaEntity media) {
    context.push('/media/${media.id}');
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedFolderPath == null) {
      return _buildEmptyState();
    }

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                GalleryTopBar(
                  onBack: _navigateBack,
                  onForward: _navigateForward,
                  onRefresh: _refresh,
                  onSelectFolder: _selectMainFolder,
                  currentPath: _currentPath,
                  onPathSelected: (path) {
                    setState(() {
                      _backHistory.add(_currentPath);
                      _forwardHistory.clear();
                      _currentPath = path;
                      _loadMediaForPath(path);
                    });
                  },
                  layoutMode: _layoutMode,
                  onLayoutModeChanged: _onLayoutModeChanged,
                  canGoBack: _backHistory.isNotEmpty,
                  canGoForward: _forwardHistory.isNotEmpty,
                ),
                PinnedTagsBar(
                  pinnedTags: _pinnedTags,
                  onAddTag: _addPinnedTag,
                  onRemoveTag: _removePinnedTag,
                  onTagTap: _onPinnedTagTap,
                ),
                Expanded(
                  child: MediaGrid(
                    mediaItems: _mediaItems,
                    layoutMode: _layoutMode,
                    onMediaTap: _onMediaTap,
                  ),
                ),
              ],
            ),
          ),
          if (_isRightPanelExpanded)
            GalleryRightPanel(
              onToggle: _toggleRightPanel,
              onSearch: _handleSearch,
              onTagSelect: _handleTagSelect,
            ),
        ],
      ),
      floatingActionButton: !_isRightPanelExpanded
          ? FloatingActionButton(
              onPressed: _toggleRightPanel,
              child: const Icon(Icons.chevron_right),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.folder_open,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'Select the main media folder',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _selectMainFolder,
              icon: const Icon(Icons.folder),
              label: const Text('Choose Folder'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addPinnedTag(TagEntity tag) {
    setState(() {
      if (!_pinnedTags.contains(tag)) {
        _pinnedTags.add(tag);
      }
    });
  }

  void _removePinnedTag(TagEntity tag) {
    setState(() {
      _pinnedTags.remove(tag);
    });
  }

  void _onPinnedTagTap(TagEntity tag) {
    // Открыть поиск с этим тегом
  }

  void _handleSearch(String query) {
    // Обработка поиска
  }

  void _handleTagSelect(TagEntity tag) {
    // Обработка выбора тега
  }
}
