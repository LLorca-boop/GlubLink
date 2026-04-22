import 'package:intl/intl.dart';

/// Утилиты для работы с датами и временем
class DateUtils {
  DateUtils._();

  /// Формат: ДД.ММ.ГГГГ
  static const String _datePattern = 'dd.MM.yyyy';

  /// Формат: ЧЧ:ММ
  static const String _timePattern = 'HH:mm';

  /// Формат: ДД.ММ.ГГГГ ЧЧ:ММ
  static const String _dateTimePattern = 'dd.MM.yyyy HH:mm';

  /// Формат для относительных дат (сегодня, вчера)
  static const String _relativePattern = 'd MMMM';

  /// Форматирует дату в формат ДД.ММ.ГГГГ
  static String formatDate(DateTime date) {
    return DateFormat(_datePattern).format(date);
  }

  /// Форматирует время в формат ЧЧ:ММ
  static String formatTime(DateTime date) {
    return DateFormat(_timePattern).format(date);
  }

  /// Форматирует дату и время в формат ДД.ММ.ГГГГ ЧЧ:ММ
  static String formatDateTime(DateTime date) {
    return DateFormat(_dateTimePattern).format(date);
  }

  /// Форматирует дату в относительном формате
  /// Сегодня: ЧЧ:ММ
  /// Вчера: вчера, ЧЧ:ММ
  /// На этой неделе: День недели
  /// Старее: ДД.ММ.ГГГГ
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      // Сегодня
      return formatTime(date);
    } else if (difference.inDays == 1) {
      // Вчера
      return 'вчера, ${formatTime(date)}';
    } else if (difference.inDays < 7) {
      // На этой неделе
      return DateFormat('EEEE', 'ru_RU').format(date);
    } else {
      // Старше недели
      return formatDate(date);
    }
  }

  /// Проверяет, является ли дата сегодняшней
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Проверяет, является ли дата вчерашней
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Вычисляет возраст даты в днях
  static int daysAgo(DateTime date) {
    return DateTime.now().difference(date).inDays;
  }

  /// Добавляет дни к дате
  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  /// Добавляет месяцы к дате
  static DateTime addMonths(DateTime date, int months) {
    return DateTime(date.year, date.month + months, date.day);
  }
}
