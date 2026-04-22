/// Константы приложения GlubLink
class AppConstants {
  AppConstants._();

  /// Название приложения
  static const String appName = 'GlubLink';

  /// Версия приложения
  static const String appVersion = '1.0.0';

  /// Минимальная ширина окна для Desktop
  static const double minWindowWidth = 800.0;

  /// Минимальная высота окна для Desktop
  static const double minWindowHeight = 600.0;

  /// Максимальная ширина контента
  static const double maxContentWidth = 1440.0;

  /// Базовая анимация: длительность
  static const Duration animationDuration = Duration(milliseconds: 200);

  /// Медленная анимация: длительность
  static const Duration slowAnimationDuration = Duration(milliseconds: 400);

  /// Быстрая анимация: длительность
  static const Duration fastAnimationDuration = Duration(milliseconds: 100);

  /// Время авто-скрытия уведомлений (мс)
  static const int snackbarDurationMs = 3000;

  /// Максимальное количество последних элементов
  static const int maxRecentItems = 50;

  /// Размер пагинации по умолчанию
  static const int defaultPageSize = 20;

  /// Максимальный размер загружаемого файла (MB)
  static const int maxFileSizeMb = 100;

  /// Поддерживаемые расширения изображений
  static const List<String> imageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'svg',
    'bmp',
  ];

  /// Поддерживаемые расширения видео
  static const List<String> videoExtensions = [
    'mp4',
    'webm',
    'avi',
    'mov',
  ];

  /// Поддерживаемые расширения документов
  static const List<String> documentExtensions = [
    'pdf',
    'doc',
    'docx',
    'txt',
    'md',
  ];
}
