// lib/shared/cache/image_cache_manager.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Менеджер кэша изображений с 3 уровнями
/// L1: Memory Cache (ImageCache) - быстрый доступ
/// L2: Disk Cache (файлы) - средний доступ
/// L3: Original Source (медленный доступ)
class ImageCacheManager {
  static final ImageCacheManager _instance = ImageCacheManager._internal();
  
  factory ImageCacheManager() => _instance;
  
  ImageCacheManager._internal();

  /// Директория для дискового кэша
  Directory? _cacheDirectory;
  
  /// Максимальный размер memory cache (в MB)
  static const int _maxMemoryCacheSizeMB = 100;
  
  /// Максимальный возраст кэша (в днях)
  static const int _maxCacheAgeDays = 30;

  /// Инициализация кэш директории
  Future<void> initialize() async {
    _cacheDirectory = await getTemporaryDirectory();
    _cacheDirectory = Directory('${_cacheDirectory!.path}/glublink_image_cache');
    
    if (!await _cacheDirectory!.exists()) {
      await _cacheDirectory!.create(recursive: true);
    }
    
    // Очищаем старый кэш при инициализации
    await _cleanOldCache();
  }

  /// Получение пути к файлу в кэше
  String _getCachePath(String key) {
    // Хэшируем ключ для безопасного имени файла
    final sanitizedKey = key.replaceAll(RegExp(r'[^\w\-\.]'), '_');
    return '${_cacheDirectory!.path}/$sanitizedKey';
  }

  /// Проверка наличия изображения в кэше
  Future<bool> isCached(String key) async {
    // Сначала проверяем memory cache
    if (_isInMemoryCache(key)) {
      return true;
    }
    
    // Затем проверяем disk cache
    final cachePath = _getCachePath(key);
    return File(cachePath).exists();
  }

  /// Проверка memory cache
  bool _isInMemoryCache(String key) {
    return PaintingBinding.instance.imageCache.containsKey(key);
  }

  /// Добавление изображения в кэш
  Future<void> cacheImage(String key, Uint8List data) async {
    // Добавляем в memory cache
    PaintingBinding.instance.imageCache.putIfAbsent(
      key,
      () => ImageInfo(
        image: MemoryImage(data).image,
        scale: 1.0,
      ),
    );
    
    // Добавляем в disk cache
    final cachePath = _getCachePath(key);
    final file = File(cachePath);
    await file.writeAsBytes(data, flush: true);
  }

  /// Получение изображения из кэша
  Future<Uint8List?> getCachedImage(String key) async {
    // Проверяем disk cache
    final cachePath = _getCachePath(key);
    final file = File(cachePath);
    
    if (await file.exists()) {
      return file.readAsBytes();
    }
    
    return null;
  }

  /// Очистка старого кэша
  Future<void> _cleanOldCache() async {
    if (_cacheDirectory == null) return;
    
    final now = DateTime.now();
    final maxAge = Duration(days: _maxCacheAgeDays);
    
    try {
      await for (final entity in _cacheDirectory!.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          final age = now.difference(stat.modified);
          
          if (age > maxAge) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      // Игнорируем ошибки очистки
      debugPrint('Ошибка очистки кэша: $e');
    }
  }

  /// Полная очистка кэша
  Future<void> clearCache() async {
    // Очищаем memory cache
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    
    // Очищаем disk cache
    if (_cacheDirectory != null && await _cacheDirectory!.exists()) {
      await _cacheDirectory!.delete(recursive: true);
      await _cacheDirectory!.create(recursive: true);
    }
  }

  /// Получение размера кэша на диске (в байтах)
  Future<int> getDiskCacheSize() async {
    if (_cacheDirectory == null || !await _cacheDirectory!.exists()) {
      return 0;
    }
    
    int totalSize = 0;
    
    try {
      await for (final entity in _cacheDirectory!.list()) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
    } catch (e) {
      debugPrint('Ошибка подсчёта размера кэша: $e');
    }
    
    return totalSize;
  }

  /// Форматированный размер кэша
  Future<String> getFormattedCacheSize() async {
    final size = await getDiskCacheSize();
    
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }
}
