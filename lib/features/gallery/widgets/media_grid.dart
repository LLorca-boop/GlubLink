import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import '../../../../core/theme/app_theme.dart';

class MediaGrid extends StatefulWidget {
  final bool isDark;
  final bool isJustifiedLayout;
  final String searchQuery;
  final List<String> pinnedTags;
  final String currentPath;
  final List<Map<String, dynamic>> mediaFiles;
  final Function(Map<String, dynamic>)? onMediaTap;
  final Future<void> Function()? onLoadMore;
  final bool isLoading;
  final bool hasMoreItems;

  const MediaGrid({
    super.key,
    required this.isDark,
    required this.isJustifiedLayout,
    required this.searchQuery,
    required this.pinnedTags,
    required this.currentPath,
    required this.mediaFiles,
    this.onMediaTap,
    this.onLoadMore,
    this.isLoading = false,
    this.hasMoreItems = false,
  });

  @override
  State<MediaGrid> createState() => _MediaGridState();
}

class _MediaGridState extends State<MediaGrid> {
  final Map<String, Uint8List> _imageCache = {};
  static const int _maxCacheSize = 50;
  final ScrollController _scrollController = ScrollController();
  final Set<String> _loadingPaths = {};
  final Map<String, bool> _errorPaths = {};  // ✅ Кэш ошибок

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _imageCache.clear();
    _loadingPaths.clear();
    _errorPaths.clear();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      if (!widget.isLoading && widget.hasMoreItems) {
        widget.onLoadMore?.call();
      }
    }
  }

  void _addToCache(String path, Uint8List bytes) {
    if (_imageCache.length >= _maxCacheSize) {
      _imageCache.remove(_imageCache.keys.first);
    }
    _imageCache[path] = bytes;
  }

  Uint8List? _getFromCache(String path) {
    return _imageCache[path];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.isDark ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
      padding: const EdgeInsets.all(16),
      child: widget.mediaFiles.isEmpty
          ? _buildEmptyGrid(widget.isDark)
          : NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollEndNotification) {
                  _onScroll();
                }
                return false;
              },
              child: widget.isJustifiedLayout
                  ? _buildJustifiedLayout(widget.isDark)
                  : _buildMasonryLayout(widget.isDark),
            ),
    );
  }

  Widget _buildEmptyGrid(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.image_outlined,
            size: 64,
            color: AppTheme.activeButtonColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No media files found',
            style: TextStyle(
              fontSize: 14,
              color: widget.isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJustifiedLayout(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 0 || widget.mediaFiles.isEmpty) {
          return const SizedBox.shrink();
        }
        return _buildJustifiedGrid(constraints.maxWidth, isDark);
      },
    );
  }

  Widget _buildJustifiedGrid(double maxWidth, bool isDark) {
    const double targetRowHeight = 250.0;
    const double gap = 4.0;
    List<List<Map<String, dynamic>>> rows = _calculateRows(
      widget.mediaFiles,
      maxWidth,
      targetRowHeight,
      gap,
    );

    List<Widget> rowWidgets = [];
    for (int i = 0; i < rows.length; i++) {
      bool isLastRow = (i == rows.length - 1);
      rowWidgets.add(
        _buildJustifiedRow(
          rows[i],
          targetRowHeight,
          gap,
          isDark,
          maxWidth,
          isLastRow,
        ),
      );
    }

    return ListView(
      controller: _scrollController,
      children: [
        ...rowWidgets,
        if (widget.isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  List<List<Map<String, dynamic>>> _calculateRows(
    List<Map<String, dynamic>> files,
    double maxWidth,
    double targetRowHeight,
    double gap,
  ) {
    List<List<Map<String, dynamic>>> rows = [];
    List<Map<String, dynamic>> currentRow = [];
    double currentRowWidth = 0;

    for (var media in files) {
      double aspectRatio = _getAspectRatio(media);
      if (aspectRatio <= 0 || !aspectRatio.isFinite) {
        aspectRatio = 1.0;
      }
      double elementWidth = targetRowHeight * aspectRatio;
      double newTotalWidth = currentRowWidth + elementWidth;

      if (currentRow.isNotEmpty) {
        newTotalWidth += gap;
      }

      if (newTotalWidth > maxWidth && currentRow.isNotEmpty) {
        rows.add(List.from(currentRow));
        currentRow = [];
        currentRowWidth = 0;
      }

      currentRow.add(media);
      currentRowWidth += elementWidth;
      if (currentRow.length > 1) {
        currentRowWidth += gap;
      }
    }

    if (currentRow.isNotEmpty) {
      rows.add(currentRow);
    }

    return rows;
  }

  Widget _buildJustifiedRow(
    List<Map<String, dynamic>> row,
    double targetRowHeight,
    double gap,
    bool isDark,
    double maxWidth,
    bool isLastRow,
  ) {
    if (row.isEmpty) return const SizedBox.shrink();

    double totalNaturalWidth = 0;
    List<double> aspectRatios = [];

    for (var media in row) {
      double ar = _getAspectRatio(media);
      if (ar <= 0 || !ar.isFinite) {
        ar = 1.0;
      }
      aspectRatios.add(ar);
      totalNaturalWidth += targetRowHeight * ar;
    }

    double totalGaps = gap * (row.length - 1);
    totalNaturalWidth += totalGaps;

    double scale = 1.0;
    if (!isLastRow) {
      scale = (maxWidth) / totalNaturalWidth;
    }

    double finalRowHeight = targetRowHeight * scale;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: row.asMap().entries.map((entry) {
          int index = entry.key;
          var media = entry.value;
          double aspectRatio = aspectRatios[index];
          double elementWidth = (targetRowHeight * aspectRatio * scale);

          return SizedBox(
            width: elementWidth,
            height: finalRowHeight,
            child: Container(
              margin: EdgeInsets.only(right: index < row.length - 1 ? gap : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDark ? AppTheme.surfaceColorDark : AppTheme.surfaceColorLight,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: GestureDetector(
                  onTap: () => widget.onMediaTap?.call(media),
                  child: _buildMediaPreview(media, isDark, elementWidth, finalRowHeight),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMasonryLayout(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 0 || widget.mediaFiles.isEmpty) {
          return const SizedBox.shrink();
        }
        return _buildMasonryGrid(constraints.maxWidth, isDark);
      },
    );
  }

  Widget _buildMasonryGrid(double maxWidth, bool isDark) {
    const double gap = 4.0;
    int columnCount = (maxWidth / 250).floor();
    columnCount = columnCount.clamp(2, 6);
    double columnWidth = (maxWidth - (gap * (columnCount - 1))) / columnCount;

    List<double> columnHeights = List.filled(columnCount, 0.0);
    List<List<Map<String, dynamic>>> columns = List.generate(columnCount, (_) => []);

    for (var media in widget.mediaFiles) {
      double aspectRatio = _getAspectRatio(media);
      if (aspectRatio <= 0 || !aspectRatio.isFinite) {
        aspectRatio = 1.0;
      }
      double elementHeight = columnWidth / aspectRatio;

      int targetColumn = 0;
      double minHeight = columnHeights[0];
      for (int i = 1; i < columnCount; i++) {
        if (columnHeights[i] < minHeight) {
          minHeight = columnHeights[i];
          targetColumn = i;
        }
      }

      columns[targetColumn].add(media);
      columnHeights[targetColumn] += elementHeight + gap;
    }

    return ListView(
      controller: _scrollController,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: columns.asMap().entries.map((entry) {
            int colIndex = entry.key;
            var column = entry.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: colIndex == 0 ? 0 : gap / 2,
                  right: colIndex == columnCount - 1 ? 0 : gap / 2,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: column.map((media) {
                    double aspectRatio = _getAspectRatio(media);
                    if (aspectRatio <= 0 || !aspectRatio.isFinite) {
                      aspectRatio = 1.0;
                    }
                    double height = columnWidth / aspectRatio;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: SizedBox(
                        width: columnWidth,
                        height: height,
                        child: GestureDetector(
                          onTap: () => widget.onMediaTap?.call(media),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: isDark ? AppTheme.surfaceColorDark : AppTheme.surfaceColorLight,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _buildMediaPreview(media, isDark, columnWidth, height),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          }).toList(),
        ),
        if (widget.isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  double _getAspectRatio(Map<String, dynamic> media) {
    if (media['width'] != null && media['height'] != null) {
      int width = media['width'] as int;
      int height = media['height'] as int;
      if (width > 0 && height > 0) {
        return width / height;
      }
    }
    switch (media['type']) {
      case 'video':
        return 16 / 9;
      case 'gif':
        return 1;
      default:
        return 4 / 3;
    }
  }

  Widget _buildMediaPreview(Map<String, dynamic> mediaFile, bool isDark, double width, double height) {
    final filePath = mediaFile['path'] as String;
    final fileType = mediaFile['type'] as String;

    if (fileType == 'video') {
      return Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: isDark ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
            child: const Center(
              child: Icon(
                Icons.play_circle_outline_rounded,
                size: 48,
                color: AppTheme.activeButtonColor,
              ),
            ),
          ),
        ],
      );
    } else {
      return _buildResilientImage(filePath, isDark, width, height, fileType);
    }
  }

  // ✅ УСТОЙЧИВАЯ ЗАГРУЗКА ИЗОБРАЖЕНИЙ С ОБРАБОТКОЙ ОШИБОК
  Widget _buildResilientImage(String filePath, bool isDark, double width, double height, String fileType) {
    // ✅ Проверяем кэш ошибок
    if (_errorPaths[filePath] == true) {
      return _buildErrorPlaceholder(isDark, fileType);
    }

    final cachedBytes = _getFromCache(filePath);
    if (cachedBytes != null) {
      return _buildDecodedImage(cachedBytes, isDark, width, height, filePath, fileType);
    }

    // ✅ Не загружаем повторно если уже в процессе
    if (_loadingPaths.contains(filePath)) {
      return Container(
        color: isDark ? AppTheme.surfaceColorDark : AppTheme.surfaceColorLight,
        child: const Center(
          child: Icon(
            Icons.image_outlined,
            size: 48,
            color: AppTheme.textSecondaryDark,
          ),
        ),
      );
    }

    _loadingPaths.add(filePath);

    return FutureBuilder<Uint8List>(
      future: _loadImageBytes(filePath, width, height, fileType),
      builder: (context, snapshot) {
        _loadingPaths.remove(filePath);

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: isDark ? AppTheme.surfaceColorDark : AppTheme.surfaceColorLight,
            child: const Center(
              child: Icon(
                Icons.image_outlined,
                size: 48,
                color: AppTheme.textSecondaryDark,
              ),
            ),
          );
        }

        // ✅ Обработка ошибок загрузки
        if (snapshot.hasError || !snapshot.hasData) {
          _errorPaths[filePath] = true;  // ✅ Кэшируем ошибку
          return _buildErrorPlaceholder(isDark, fileType);
        }

        _addToCache(filePath, snapshot.data!);
        return _buildDecodedImage(
          snapshot.data!,
          isDark,
          width,
          height,
          filePath,
          fileType,
        );
      },
    );
  }

  // ✅ Плейсхолдер для ошибок
  Widget _buildErrorPlaceholder(bool isDark, String fileType) {
    return Container(
      color: isDark ? AppTheme.surfaceColorDark : AppTheme.surfaceColorLight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_rounded,
              size: 48,
              color: AppTheme.textSecondaryDark,
            ),
            const SizedBox(height: 8),
            Text(
              fileType == 'gif' ? 'GIF Error' : 'Image Error',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ ОПТИМИЗИРОВАННАЯ ЗАГРУЗКА С ОБРАБОТКОЙ ОШИБОК
  Future<Uint8List> _loadImageBytes(String filePath, double targetWidth, double targetHeight, String fileType) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found');
      }

      // ✅ Для GIF - загружаем как есть (сохраняем анимацию)
      if (fileType == 'gif') {
        final bytes = await file.readAsBytes();
        // ✅ Проверяем валидность GIF
        if (bytes.length < 6 || 
            bytes[0] != 0x47 || 
            bytes[1] != 0x49 || 
            bytes[2] != 0x46) {
          throw Exception('Invalid GIF format');
        }
        return bytes;
      }

      // ✅ Для изображений - ресайзим для превью
      final bytes = await file.readAsBytes();
      
      // ✅ Проверяем минимальный размер файла
      if (bytes.length < 24) {
        throw Exception('File too small');
      }

      // ✅ Проверяем сигнатуру файла
      bool isValidImage = false;
      if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
        isValidImage = true;  // JPEG
      } else if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
        isValidImage = true;  // PNG
      } else if (bytes[0] == 0x42 && bytes[1] == 0x4D) {
        isValidImage = true;  // BMP
      } else if (bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46) {
        isValidImage = true;  // WebP
      }

      if (!isValidImage) {
        throw Exception('Invalid image format');
      }

      // ✅ Декодируем с изменением размера для экономии памяти
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: (targetWidth * 2).round(),
        targetHeight: (targetHeight * 2).round(),
      );

      final frame = await codec.getNextFrame();
      
      // ✅ Проверяем успешность декодирования
      if (frame == null) {
        throw Exception('Failed to decode frame');
      }

      final byteData = await frame.image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to get byte data');
      }

      return byteData.buffer.asUint8List();
    } catch (e) {
      // ✅ Логируем ошибку для отладки
      debugPrint('Error loading image $filePath: $e');
      rethrow;
    }
  }

  // ✅ УЛУЧШЕННАЯ ОТРИСОВКА С ОБРАБОТКОЙ ОШИБОК
    Widget _buildDecodedImage(
    Uint8List bytes,
    bool isDark,
    double width,
    double height,
    String filePath,
    String fileType,
  ) {
    return Image.memory(
      bytes,
      fit: BoxFit.contain,
      width: width,
      height: height,
      alignment: Alignment.topCenter,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      excludeFromSemantics: true,
      cacheWidth: (width * 2).round(),
      cacheHeight: (height * 2).round(),
      errorBuilder: (context, error, stackTrace) {
        // ✅ Кэшируем ошибку чтобы не пытаться загрузить снова
        _errorPaths[filePath] = true;
        return _buildErrorPlaceholder(isDark, fileType);
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          child: child,
        );
      },
    );
  }
}