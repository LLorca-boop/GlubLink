// lib/features/gallery/data/models/gallery_view_mode.dart
import 'package:flutter/material.dart';

/// Режимы отображения галереи
enum GalleryViewMode {
  /// Кирпичная кладка (Masonry)
  masonry('masonry', Icons.view_quilt, 'Плитка'),
  
  /// Выровненные ряды (Justified)
  justified('justified', Icons.view_day, 'Выравнивание'),
  
  /// Детальный список (List)
  list('list', Icons.view_list, 'Список'),
  
  /// Хронология (Timeline)
  timeline('timeline', Icons.timeline, 'Хронология');

  const GalleryViewMode(this.value, this.icon, this.displayName);

  final String value;
  final IconData icon;
  final String displayName;

  /// Получение режима из строки
  static GalleryViewMode fromValue(String value) {
    return GalleryViewMode.values.firstWhere(
      (mode) => mode.value == value,
      orElse: () => GalleryViewMode.masonry,
    );
  }

  /// Количество колонок по умолчанию для режима
  int getDefaultColumnCount(double screenWidth) {
    switch (this) {
      case GalleryViewMode.masonry:
        if (screenWidth < 600) return 2;
        if (screenWidth < 900) return 3;
        if (screenWidth < 1200) return 4;
        return 5;
      
      case GalleryViewMode.justified:
        if (screenWidth < 600) return 3;
        if (screenWidth < 900) return 4;
        if (screenWidth < 1200) return 5;
        return 6;
      
      case GalleryViewMode.list:
        return 1;
      
      case GalleryViewMode.timeline:
        return 1;
    }
  }

  /// Размер карточки в пикселях (базовый)
  double getBaseCardSize() {
    switch (this) {
      case GalleryViewMode.masonry:
        return 200.0;
      case GalleryViewMode.justified:
        return 180.0;
      case GalleryViewMode.list:
        return 100.0;
      case GalleryViewMode.timeline:
        return 120.0;
    }
  }
}
