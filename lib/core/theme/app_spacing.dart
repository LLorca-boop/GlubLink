/// Токены отступов приложения GlubLink
/// Все значения кратны 4px для консистентной сетки
class AppSpacing {
  AppSpacing._();

  /// Минимальный отступ: 4px
  static const double xs = 4.0;

  /// Малый отступ: 8px
  static const double sm = 8.0;

  /// Средний малый отступ: 12px
  static const double mdSm = 12.0;

  /// Средний отступ: 16px
  static const double md = 16.0;

  /// Средний большой отступ: 24px
  static const double mdLg = 24.0;

  /// Большой отступ: 32px
  static const double lg = 32.0;

  /// Максимальный отступ: 48px
  static const double xl = 48.0;

  /// Список всех доступных отступов
  static const List<double> allValues = [xs, sm, mdSm, md, mdLg, lg, xl];
}
