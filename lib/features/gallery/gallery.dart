// lib/features/gallery/gallery.dart
/// Barrel export для модуля Gallery
/// Экспортирует все публичные компоненты галереи

// Domain layer
export 'domain/models/parsed_query.dart';
export 'domain/utils/query_parser.dart';
export 'domain/repositories/gallery_repository.dart';

// Data layer
export 'data/models/gallery_view_mode.dart';

// Presentation layer
export 'presentation/providers/gallery_providers.dart';
export 'presentation/widgets/gallery_widgets.dart';
export 'presentation/pages/gallery_page.dart';
