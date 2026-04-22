import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// Экран просмотра медиафайла
class MediaViewerScreen extends StatelessWidget {
  /// Путь к медиафайлу
  final String? filePath;

  const MediaViewerScreen({super.key, this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Просмотр'),
        actions: [
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: () {
              // TODO: Полноэкранный режим
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // TODO: Показать информацию о файле
            },
          ),
        ],
      ),
      body: Center(
        child: filePath != null
            ? _buildMediaContent(filePath!)
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildMediaContent(String path) {
    // TODO: Реализовать отображение различных типов медиа
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Text(
          'Просмотр медиа',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Text(
      'Файл не выбран',
      style: AppTypography.md.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }
}
