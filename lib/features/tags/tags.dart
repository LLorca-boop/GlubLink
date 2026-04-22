/// Библиотека системы тегирования GlubLink
/// 
/// Предоставляет полный набор компонентов для работы с тегами:
/// - Модели данных (Tag, TagCategory)
/// - Репозиторий для доступа к данным
/// - Riverpod провайдеры для управления состоянием
/// - UI виджеты для отображения и редактирования тегов
/// 
/// Архитектура:
/// - Domain layer: entities, repositories interfaces
/// - Data layer: models, repositories implementations, data sources
/// - Presentation layer: providers, widgets

// Domain Layer
export 'domain/entities/tag_entity.dart';
export 'domain/repositories/tag_repository.dart';

// Data Layer
export 'data/models/tag.dart';
export 'data/models/tag_category.dart';
export 'data/repositories/tag_repository_impl.dart';

// Presentation Layer
export 'presentation/providers/tag_providers.dart';
export 'presentation/widgets/tag_widgets.dart';
