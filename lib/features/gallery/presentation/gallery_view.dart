import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../core/animations/spring_config.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/pinned_tags_bar.dart';
import '../widgets/media_grid.dart';
import '../widgets/gallery_right_panel.dart';
import '../../../core/navigation/navigation_history.dart';
import '../../media_fullscreen/presentation/media_fullscreen_screen.dart';

class GalleryView extends StatefulWidget {
  final Function(NavigationAction)? onAction;
  final Function(String)? onFolderPathChanged;
  const GalleryView({super.key, this.onAction, this.onFolderPathChanged});

  @override
  State<GalleryView> createState() => GalleryViewState();
}

class GalleryViewState extends State<GalleryView> {
  bool _isFolderSelected = false;
  String _currentPath = '';
  bool _isJustifiedLayout = true;
  List<String> _pinnedTags = ['All'];
  String? _activeFilterTag = 'All';
  String _rightPanelSearchQuery = '';
  final List<Map<String, dynamic>> _allMediaFiles = [];
  final List<Map<String, dynamic>> _displayedFiles = [];
  final List<String> _folderHistory = [];
  int _currentFolderIndex = -1;
  bool _isRightPanelExpanded = false;
  String _tagSortMode = 'ByCount';
  String _selectedLanguage = 'Русский';
  bool _isScanning = false;
  bool _isLoadingMore = false;
  bool _hasMoreItems = false;
  int _currentPage = 0;
  static const int _filesPerPage = 100;
  final Map<String, List<Map<String, dynamic>>> _folderCache = {};

  // ✅ ПУЛ ТЕГОВ - динамическое пространство всех тегов
  final List<Map<String, dynamic>> _tagPool = [];

  // ✅ Защищённые Meta-теги (нельзя удалить)
  static const List<String> _protectedMetaTags = [
    'image',
    'gif',
    'video',
  ];

  void selectFolder() => _selectFolder();
  void toggleLayout() => setState(() => _isJustifiedLayout = !_isJustifiedLayout);
  void refresh() => _scanFolder(_currentPath);
  void navigateToFolder(String path) => _navigateToFolder(path);
  void toggleRightPanel() => setState(() => _isRightPanelExpanded = !_isRightPanelExpanded);
  bool get isFolderSelected => _isFolderSelected;
  String get currentPath => _currentPath;
  bool get isJustifiedLayout => _isJustifiedLayout;
  bool get isRightPanelExpanded => _isRightPanelExpanded;
  List<String> get pinnedTags => List.unmodifiable(_pinnedTags);
  List<Map<String, dynamic>> get tagPool => List.unmodifiable(_tagPool);

  void addPinnedTag(String tagName) {
    setState(() {
      if (!_pinnedTags.contains(tagName)) {
        _pinnedTags.add(tagName);
      }
      _activeFilterTag = tagName;
      _currentPage = 0;
      _updateDisplayedFiles();
      _savePinnedTags();
    });
  }

  void removePinnedTag(String tagName) {
    setState(() {
      if (tagName != 'All' || _pinnedTags.length > 1) {
        _pinnedTags.remove(tagName);
        if (_activeFilterTag == tagName) {
          _activeFilterTag = _pinnedTags.isEmpty ? 'All' : _pinnedTags.first;
        }
        _savePinnedTags();
        _updateDisplayedFiles();
      }
    });
  }

  void onPinnedTagClick(String tagName) {
    setState(() {
      _activeFilterTag = tagName;
      _currentPage = 0;
      _updateDisplayedFiles();
    });
  }

  void _savePinnedTags() {
    debugPrint('Saving pinned tags: $_pinnedTags');
  }

  void _loadPinnedTags() {
    setState(() {
      _pinnedTags = ['All'];
      _activeFilterTag = 'All';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPinnedTags();
    _initializeProtectedMetaTags();
  }

  void _initializeProtectedMetaTags() {
    for (var metaTag in _protectedMetaTags) {
      _tagPool.add({
        'name': metaTag,
        'count': 0,
        'category': 'Meta',
        'frequency': 0,
        'isProtected': true,
      });
    }
  }

  Future<void> _selectFolder() async {
    try {
      String? selectedPath = await FilePicker.platform.getDirectoryPath();
      if (selectedPath != null) {
        final isInitialSelection = !_isFolderSelected;
        if (_folderCache.containsKey(selectedPath)) {
          setState(() {
            _currentPath = selectedPath;
            _isFolderSelected = true;
            _allMediaFiles.clear();
            _allMediaFiles.addAll(_folderCache[selectedPath]!);
            _currentPage = 0;
            _updateDisplayedFiles();
          });
        } else {
          setState(() {
            _currentPath = selectedPath;
            _isFolderSelected = true;
            _allMediaFiles.clear();
            _displayedFiles.clear();
          });
          await _scanFolder(selectedPath);
        }
        _addToFolderHistory(selectedPath);
        _updateFolderPath(selectedPath);
        _recordAction(
          NavigationAction(
            type: isInitialSelection
                ? NavigationActionType.folderSelect
                : NavigationActionType.folderNavigate,
            folderPath: selectedPath,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error selecting folder: $e');
    }
  }

  void _navigateToFolder(String path) {
    setState(() {
      _currentPath = path;
      _allMediaFiles.clear();
      _displayedFiles.clear();
      _currentPage = 0;
    });
    _scanFolder(path);
    _updateFolderPath(path);
  }

  Future<void> _scanFolder(String path) async {
    setState(() {
      _isScanning = true;
      _allMediaFiles.clear();
      _displayedFiles.clear();
      _currentPage = 0;
      _tagPool.removeWhere((tag) => tag['isProtected'] != true);
    });
    try {
      final scanResult = await compute(_scanFolderInIsolate, path);
      _folderCache[path] = scanResult['files'] as List<Map<String, dynamic>>;
      final scannedTags = scanResult['tags'] as List<Map<String, dynamic>>;

      setState(() {
        _allMediaFiles.addAll(_folderCache[path]!);
        for (var tag in scannedTags) {
          _addTagToPool(tag['name'] as String, tag['category'] as String, tag['count'] as int);
        }
        _isScanning = false;
        _hasMoreItems = _allMediaFiles.length > _filesPerPage;
        _updateDisplayedFiles();
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      debugPrint('Error scanning folder: $e');
    }
  }

  static Map<String, dynamic> _scanFolderInIsolate(String path) {
    final List<Map<String, dynamic>> files = [];
    final Map<String, Map<String, dynamic>> tagCountMap = {};

    try {
      final directory = Directory(path);
      if (!directory.existsSync()) {
        return {'files': files, 'tags': <Map<String, dynamic>>[]};
      }
      _scanFolderRecursiveSync(directory.path, files, tagCountMap);
    } catch (e) {
      debugPrint('Error in isolate: $e');
    }

    final List<Map<String, dynamic>> tags = tagCountMap.values.toList();
    return {'files': files, 'tags': tags};
  }

  static void _scanFolderRecursiveSync(
    String path,
    List<Map<String, dynamic>> files,
    Map<String, Map<String, dynamic>> tagCountMap,
  ) {
    final directory = Directory(path);
    if (!directory.existsSync()) return;
    final entities = directory.listSync(recursive: false, followLinks: false);

    for (final entity in entities) {
      if (entity is File) {
        final extension = entity.path.split('.').last.toLowerCase();
        if (_isSupportedMediaExtensionStatic(extension)) {
          int width = 1920;
          int height = 1080;
          final mediaType = _getMediaTypeStatic(extension);
          final List<String> fileTags = [mediaType];

          _updateTagCount(tagCountMap, mediaType, 'Meta');

          if (extension != 'mp4' && extension != 'webm' && extension != 'avi') {
            try {
              final bytes = entity.readAsBytesSync();
              final size = _getImageDimensionsQuick(bytes);
              if (size != null) {
                width = size.$1;
                height = size.$2;
              }
            } catch (e) {
              debugPrint('Error getting image dimensions: $e');
            }
          }

          files.add({
            'path': entity.path,
            'type': mediaType,
            'name': entity.path.split('\\').last,
            'width': width,
            'height': height,
            'tags': fileTags,
          });
        }
      } else if (entity is Directory) {
        _scanFolderRecursiveSync(entity.path, files, tagCountMap);
      }
    }
  }

  static void _updateTagCount(
    Map<String, Map<String, dynamic>> tagCountMap,
    String tagName,
    String category,
  ) {
    final key = tagName.toLowerCase();
    if (tagCountMap.containsKey(key)) {
      tagCountMap[key]!['count'] = (tagCountMap[key]!['count'] as int) + 1;
    } else {
      tagCountMap[key] = {
        'name': tagName,
        'count': 1,
        'category': category,
        'frequency': 0,
        'isProtected': _protectedMetaTags.contains(tagName),
      };
    }
  }

  static (int, int)? _getImageDimensionsQuick(Uint8List bytes) {
    try {
      if (bytes.length < 24) return null;
      if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
        int i = 2;
        while (i < bytes.length) {
          if (bytes[i] == 0xFF) {
            final marker = bytes[i + 1];
            if (marker >= 0xC0 && marker <= 0xC3) {
              final height = (bytes[i + 5] << 8) | bytes[i + 6];
              final width = (bytes[i + 7] << 8) | bytes[i + 8];
              return (width, height);
            }
            i += 2 + (bytes[i + 2] << 8) + bytes[i + 3];
          } else {
            i++;
          }
        }
      }
      if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
        final width = (bytes[16] << 24) | (bytes[17] << 16) | (bytes[18] << 8) | bytes[19];
        final height = (bytes[20] << 24) | (bytes[21] << 16) | (bytes[22] << 8) | bytes[23];
        return (width, height);
      }
      if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) {
        final width = bytes[6] | (bytes[7] << 8);
        final height = bytes[8] | (bytes[9] << 8);
        return (width, height);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  static bool _isSupportedMediaExtensionStatic(String extension) {
    const supportedExtensions = [
      'jpg', 'jpeg', 'png', 'bmp', 'webp',
      'gif',
      'mp4', 'webm', 'avi'
    ];
    return supportedExtensions.contains(extension);
  }

  static String _getMediaTypeStatic(String extension) {
    if (['jpg', 'jpeg', 'png', 'bmp', 'webp'].contains(extension)) return 'image';
    if (extension == 'gif') return 'gif';
    if (['mp4', 'webm', 'avi'].contains(extension)) return 'video';
    return 'image';
  }

  void _addTagToPool(String tagName, String category, int count) {
    final existingIndex = _tagPool.indexWhere(
      (t) => t['name'].toString().toLowerCase() == tagName.toLowerCase(),
    );

    if (existingIndex >= 0) {
      _tagPool[existingIndex]['count'] = count;
    } else {
      _tagPool.add({
        'name': tagName,
        'count': count,
        'category': category,
        'frequency': 0,
        'isProtected': _protectedMetaTags.contains(tagName),
      });
    }
  }

  void addTagToPool(String tagName, String category) {
    setState(() {
      final existingIndex = _tagPool.indexWhere(
        (t) => t['name'].toString().toLowerCase() == tagName.toLowerCase(),
      );

      if (existingIndex < 0) {
        _tagPool.add({
          'name': tagName,
          'count': 0,
          'category': category,
          'frequency': 0,
          'isProtected': false,
        });
      }
    });
  }

  void removeTagFromPool(String tagName) {
    setState(() {
      final tagIndex = _tagPool.indexWhere(
        (t) => t['name'].toString().toLowerCase() == tagName.toLowerCase(),
      );

      if (tagIndex >= 0 && _tagPool[tagIndex]['isProtected'] != true) {
        _tagPool.removeAt(tagIndex);
        _pinnedTags.remove(tagName);
        if (_activeFilterTag == tagName) {
          _activeFilterTag = _pinnedTags.isEmpty ? 'All' : _pinnedTags.first;
        }
      }
    });
  }

  void _updateDisplayedFiles() {
    final filtered = _filterMediaBySearch();
    final startIndex = _currentPage * _filesPerPage;
    final endIndex = (startIndex + _filesPerPage).clamp(0, filtered.length);
    setState(() {
      _displayedFiles.clear();
      if (startIndex < filtered.length) {
        _displayedFiles.addAll(filtered.sublist(startIndex, endIndex));
      }
      _hasMoreItems = endIndex < filtered.length;
    });
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMoreItems) return;
    setState(() {
      _isLoadingMore = true;
    });
    await Future.delayed(const Duration(milliseconds: 50));
    setState(() {
      _currentPage++;
      _updateDisplayedFiles();
      _isLoadingMore = false;
    });
  }

  void _addToFolderHistory(String path) {
    if (_currentFolderIndex < _folderHistory.length - 1) {
      _folderHistory.removeRange(_currentFolderIndex + 1, _folderHistory.length);
    }
    _folderHistory.add(path);
    _currentFolderIndex = _folderHistory.length - 1;
  }

  void _recordAction(NavigationAction action) {
    widget.onAction?.call(action);
  }

  void _updateFolderPath(String path) {
    widget.onFolderPathChanged?.call(path);
  }

  void _onMediaTap(Map<String, dynamic> media) {
    // ✅ Открываем MediaFullscreenScreen при клике на медиа
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MediaFullscreenScreen(
          mediaFiles: _displayedFiles,
          initialIndex: _displayedFiles.indexOf(media),
          currentPath: _currentPath,
          onTagClick: (tagName) {
            // ✅ Закрываем фуллскрин и открываем поиск с тегом
            Navigator.of(context).pop();
            setState(() {
              _rightPanelSearchQuery = tagName;
              _activeFilterTag = 'All';
              _currentPage = 0;
              _updateDisplayedFiles();
            });
          },
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _filterMediaBySearch() {
    List<Map<String, dynamic>> results = List.from(_allMediaFiles);

    if (_activeFilterTag != null && _activeFilterTag != 'All') {
      results = results.where((media) {
        final mediaTags = (media['tags'] as List<String>).map((t) => t.toLowerCase()).toList();
        return mediaTags.contains(_activeFilterTag!.toLowerCase());
      }).toList();
    }

    if (_rightPanelSearchQuery.isNotEmpty) {
      final query = _rightPanelSearchQuery.trim();

      if (query.startsWith('-')) {
        final excludeTag = query.substring(1).trim().toLowerCase();
        results = results.where((media) {
          final mediaTags = (media['tags'] as List<String>).map((t) => t.toLowerCase()).toList();
          return !mediaTags.contains(excludeTag);
        }).toList();
      } else if (query.contains('||')) {
        final tags = query.split('||').map((t) => t.trim().toLowerCase()).toList();
        results = results.where((media) {
          final mediaTags = (media['tags'] as List<String>).map((t) => t.toLowerCase()).toList();
          return tags.any((tag) => mediaTags.contains(tag));
        }).toList();
      } else {
        final searchTags = query.split(' ').map((t) => t.trim().toLowerCase()).toList();
        results = results.where((media) {
          final mediaTags = (media['tags'] as List<String>).map((t) => t.toLowerCase()).toList();
          return searchTags.every((tag) => mediaTags.contains(tag));
        }).toList();
      }
    }

    return results;
  }

  // ✅ Получение тегов из отображаемых медиа (для правой панели)
  List<Map<String, dynamic>> _getDisplayedMediaTags() {
    final Map<String, Map<String, dynamic>> tagMap = {};

    for (var media in _displayedFiles) {
      for (var tagName in media['tags'] as List<String>) {
        final key = tagName.toLowerCase();
        if (!tagMap.containsKey(key)) {
          final tagInPool = _tagPool.firstWhere(
            (t) => t['name'].toString().toLowerCase() == key,
            orElse: () => {'name': tagName, 'category': 'General', 'count': 0},
          );
          tagMap[key] = {
            'name': tagName,
            'category': tagInPool['category'] ?? 'General',
            'count': tagInPool['count'] ?? 0,
          };
        }
      }
    }

    return tagMap.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Container(
            color: isDark ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
            child: Column(
              children: [
                if (_isFolderSelected)
                  PinnedTagsBar(
                    isDark: isDark,
                    pinnedTags: _pinnedTags,
                    activeFilterTag: _activeFilterTag,
                    onTagAdded: addPinnedTag,
                    onTagRemoved: removePinnedTag,
                    onTagClick: onPinnedTagClick,
                    tagPool: _tagPool,
                    displayedMediaTags: _getDisplayedMediaTags(),
                  ),
                Expanded(
                  child: _isFolderSelected
                      ? _isScanning
                          ? const Center(child: CircularProgressIndicator())
                          : MediaGrid(
                              isDark: isDark,
                              isJustifiedLayout: _isJustifiedLayout,
                              searchQuery: _rightPanelSearchQuery,
                              pinnedTags: _pinnedTags,
                              currentPath: _currentPath,
                              mediaFiles: _displayedFiles,
                              onMediaTap: _onMediaTap,
                              onLoadMore: _loadMore,
                              isLoading: _isLoadingMore,
                              hasMoreItems: _hasMoreItems,
                            )
                      : _buildEmptyState(isDark),
                ),
              ],
            ),
          ),
        ),
        GalleryRightPanel(
          isDark: isDark,
          searchQuery: _rightPanelSearchQuery,
          onSearchChanged: (query) {
            setState(() {
              _rightPanelSearchQuery = query;
              _currentPage = 0;
              _updateDisplayedFiles();
            });
          },
          onSearchSubmitted: (query) {
            setState(() {
              _rightPanelSearchQuery = query;
              _currentPage = 0;
              _updateDisplayedFiles();
            });
          },
          onCollapse: toggleRightPanel,
          onTagAdd: (tagName) {
            setState(() {
              if (_rightPanelSearchQuery.isEmpty) {
                _rightPanelSearchQuery = tagName;
              } else if (!_rightPanelSearchQuery.contains(tagName)) {
                _rightPanelSearchQuery = '$_rightPanelSearchQuery $tagName';
              }
              _currentPage = 0;
              _updateDisplayedFiles();
            });
          },
          tags: _tagPool,
          tagSortMode: _tagSortMode,
          isExpanded: _isRightPanelExpanded,
          selectedLanguage: _selectedLanguage,
          onLanguageChanged: (lang) {
            setState(() {
              _selectedLanguage = lang;
            });
          },
          onTagSortModeChanged: (mode) {
            setState(() {
              _tagSortMode = mode;
            });
          },
          onAddNewTag: addTagToPool,
          onRemoveTag: removeTagFromPool,
          displayedMediaTags: _getDisplayedMediaTags(),
          activeFilterTag: _activeFilterTag,
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.folder_open_rounded,
            size: 64,
            color: AppTheme.activeButtonColor,
          ),
          const SizedBox(height: 32),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _selectFolder,
              child: AnimatedContainer(
                duration: GlubSpringConfig.microInteraction,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.activeButtonColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.folder_open_rounded,
                      color: isDark ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Select the main media folder',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Select the root folder containing all your images. '
              'This folder may include subfolders – all media files within '
              'them will also be displayed in the main media menu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _folderCache.clear();
    // ✅ Закрыть overlay при уходе из галереи
    super.dispose();
  }
    // ✅ Закрыть overlay закрепленных тегов (при переключении вкладок)
  void closePinnedTagsOverlay() {
    // Будет вызываться при переключении вкладок
  }
}