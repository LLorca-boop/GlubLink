import 'dart:io';
import 'package:flutter/foundation.dart';

/// File Organization Service - сервис организации файлов
/// Поддерживает два режима: Virtual и Physical
class FileOrganizationService {
  static final FileOrganizationService _instance = FileOrganizationService._internal();
  factory FileOrganizationService() => _instance;
  FileOrganizationService._internal();

  bool _isPhysicalMode = false;
  String _basePath = '';
  
  // Категории для физического режима
  static const List<String> _categories = [
    '01_Artist',
    '02_Copyrights',
    '03_Characters',
    '04_Species',
    '05_General',
    '06_Meta',
    '07_References',
  ];

  /// Инициализация сервиса
  Future<void> initialize(String basePath, bool isPhysicalMode) async {
    _basePath = basePath;
    _isPhysicalMode = isPhysicalMode;
    
    if (_isPhysicalMode) {
      await _createCategoryFolders();
    }
  }

  /// Создание папок категорий для физического режима
  Future<void> _createCategoryFolders() async {
    for (final category in _categories) {
      final folderPath = '$_basePath/$category';
      final directory = Directory(folderPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        debugPrint('Created category folder: $folderPath');
      }
    }
    
    // Создание подпапок для Meta категории
    final metaTypes = ['image', 'gif', 'video'];
    for (final type in metaTypes) {
      final metaPath = '$_basePath/06_Meta/$type';
      final metaDir = Directory(metaPath);
      if (!await metaDir.exists()) {
        await metaDir.create(recursive: true);
        debugPrint('Created meta folder: $metaPath');
      }
    }
  }

  /// Проверка поддержки NTFS
  Future<bool> checkNTFSSupport(String driveLetter) async {
    try {
      if (Platform.isWindows) {
        final result = await Process.run(
          'fsutil',
          ['fsinfo', 'volumeinfo', '$driveLetter:'],
        );
        final output = result.stdout as String;
        return output.contains('NTFS');
      }
      return false;
    } catch (e) {
      debugPrint('Error checking NTFS support: $e');
      return false;
    }
  }

  /// Создание Hard Link
  Future<bool> createHardLink(String sourcePath, String linkPath) async {
    try {
      if (!Platform.isWindows) {
        debugPrint('Hard Links supported only on Windows');
        return false;
      }

      final sourceVolume = _getVolumeId(sourcePath);
      final targetVolume = _getVolumeId(linkPath);
      
      if (sourceVolume != targetVolume) {
        debugPrint('Cannot create Hard Link across different volumes');
        return false;
      }

      final result = await Process.run(
        'cmd',
        ['/c', 'mklink', '/H', linkPath, sourcePath],
      );

      if (result.exitCode == 0) {
        debugPrint('Hard Link created: $linkPath -> $sourcePath');
        return true;
      } else {
        debugPrint('Failed to create Hard Link: ${result.stderr}');
        return false;
      }
    } catch (e) {
      debugPrint('Error creating Hard Link: $e');
      return false;
    }
  }

  /// Удаление Hard Link
  Future<bool> removeHardLink(String linkPath) async {
    try {
      final linkFile = File(linkPath);
      if (await linkFile.exists()) {
        await linkFile.delete();
        debugPrint('Hard Link removed: $linkPath');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error removing Hard Link: $e');
      return false;
    }
  }

  String _getVolumeId(String path) {
    if (path.isEmpty) return '';
    return path[0].toUpperCase();
  }

  bool get isPhysicalMode => _isPhysicalMode;
  String get basePath => _basePath;
}
