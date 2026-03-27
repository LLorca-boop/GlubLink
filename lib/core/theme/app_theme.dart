import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color accentColor = Color(0xFFFF6B9D);
  static const Color activeButtonColor = Color(0xFFF4A4A4);

  // Dark Theme
  static const Color backgroundColorDark = Color(0xFF1A1A1E);
  static const Color sidebarColorDark = Color(0xFF121215);
  static const Color surfaceColorDark = Color(0xFF25252B);
  static const Color textColorDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFF8E8E93);

  // Light Theme
  static const Color backgroundColorLight = Color(0xFFF5F5F7);
  static const Color sidebarColorLight = Color(0xFFFFFFFF);
  static const Color surfaceColorLight = Color(0xFFEFEFF4);
  static const Color textColorLight = Color(0xFF1D1D1F);
  static const Color textSecondaryLight = Color(0xFF86868B);

  // ✅ Цвета категорий тегов (7 категорий из документации)
// Добавить в конец класса AppTheme:

  // ✅ Цвета категорий тегов (7 категорий из документации)
  static Color getTagCategoryColor(String category) {
    switch (category) {
      case 'Artist':
        return const Color(0xFFE91E63);
      case 'Copyrights':
        return const Color(0xFF9C27B0);
      case 'Characters':
        return const Color(0xFF673AB7);
      case 'Species':
        return const Color(0xFF3F51B5);
      case 'General':
        return const Color(0xFF2196F3);
      case 'Meta':
        return const Color(0xFF009688);
      case 'References':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF2196F3);
    }
  }

  static Color getIconColor(bool isActive, bool isDark) {
    if (isActive) {
      return isDark ? backgroundColorDark : backgroundColorLight;
    } else {
      return activeButtonColor;
    }
  }

  static Color withAlpha(Color color, double alpha) {
    return color.withValues(alpha: alpha);
  }

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColorDark,
    cardColor: surfaceColorDark,
    useMaterial3: true,
    fontFamily: 'Segoe UI',
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: surfaceColorDark,
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColorLight,
    cardColor: surfaceColorLight,
    useMaterial3: true,
    fontFamily: 'Segoe UI',
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surface: surfaceColorLight,
    ),
  );
}