import 'package:flutter/material.dart';

/// Типографика приложения GlubLink
/// Используются системные шрифты для лучшей производительности
class AppTypography {
  AppTypography._();

  /// Базовый размер шрифта: 14px
  static const double baseSize = 14.0;

  /// Минимальный размер: 11px
  static const double xsSize = 11.0;

  /// Малый размер: 12px
  static const double smSize = 12.0;

  /// Средний размер: 14px
  static const double mdSize = 14.0;

  /// Большой размер: 16px
  static const double lgSize = 16.0;

  /// Средний большой размер: 18px
  static const double xlSize = 18.0;

  /// Заголовок малый: 20px
  static const double titleSmSize = 20.0;

  /// Заголовок средний: 24px
  static const double titleMdSize = 24.0;

  /// Семейство шрифтов (системное)
  static const String fontFamily = '.SF Pro Display';

  /// Высота строки по умолчанию
  static const double lineHeight = 1.5;

  /// Плотная высота строки
  static const double lineHeightTight = 1.25;

  /// Свободная высота строки
  static const double lineHeightLoose = 1.75;

  /// Стиль текста: XS (11px)
  static TextStyle get xs => const TextStyle(
        fontSize: xsSize,
        fontWeight: FontWeight.w400,
        height: lineHeight,
        fontFamily: fontFamily,
      );

  /// Стиль текста: SM (12px)
  static TextStyle get sm => const TextStyle(
        fontSize: smSize,
        fontWeight: FontWeight.w400,
        height: lineHeight,
        fontFamily: fontFamily,
      );

  /// Стиль текста: MD (14px)
  static TextStyle get md => const TextStyle(
        fontSize: mdSize,
        fontWeight: FontWeight.w400,
        height: lineHeight,
        fontFamily: fontFamily,
      );

  /// Стиль текста: LG (16px)
  static TextStyle get lg => const TextStyle(
        fontSize: lgSize,
        fontWeight: FontWeight.w400,
        height: lineHeight,
        fontFamily: fontFamily,
      );

  /// Стиль текста: XL (18px)
  static TextStyle get xl => const TextStyle(
        fontSize: xlSize,
        fontWeight: FontWeight.w500,
        height: lineHeightTight,
        fontFamily: fontFamily,
      );

  /// Стиль заголовка: SM (20px)
  static TextStyle get titleSm => const TextStyle(
        fontSize: titleSmSize,
        fontWeight: FontWeight.w600,
        height: lineHeightTight,
        fontFamily: fontFamily,
      );

  /// Стиль заголовка: MD (24px)
  static TextStyle get titleMd => const TextStyle(
        fontSize: titleMdSize,
        fontWeight: FontWeight.w700,
        height: lineHeightTight,
        fontFamily: fontFamily,
      );

  /// Жирный стиль
  static TextStyle bold(TextStyle base) {
    return base.copyWith(fontWeight: FontWeight.w700);
  }

  /// Полужирный стиль
  static TextStyle semiBold(TextStyle base) {
    return base.copyWith(fontWeight: FontWeight.w600);
  }

  /// Средний вес
  static TextStyle medium(TextStyle base) {
    return base.copyWith(fontWeight: FontWeight.w500);
  }
}
