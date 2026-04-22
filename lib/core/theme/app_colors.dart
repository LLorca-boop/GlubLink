import 'package:flutter/material.dart';

/// Цветовая палитра приложения GlubLink
/// Design tokens для консистентного использования цветов
class AppColors {
  AppColors._();

  /// Основные цвета фона
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFF2D2D2D);

  /// Основной цвет (светлый для темной темы)
  static const Color primary = Color(0xFFEAEAEA);
  static const Color onPrimary = Color(0xFF121212);

  /// Акцентный градиент: #6C63FF → #FF6B9D
  static const Color accentStart = Color(0xFF6C63FF);
  static const Color accentEnd = Color(0xFFFF6B9D);

  /// Градиент для акцентных элементов
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentStart, accentEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Текст
  static const Color textPrimary = Color(0xFFEAEAEA);
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color textDisabled = Color(0xFF666666);

  /// Состояния
  static const Color error = Color(0xFFCF6679);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFB74D);

  /// Границы и разделители
  static const Color divider = Color(0xFF333333);
  static const Color border = Color(0xFF404040);
}
