import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/gallery/presentation/gallery_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/media_fullscreen/presentation/media_fullscreen_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/gallery',
        builder: (context, state) {
          final folderPath = state.uri.queryParameters['path'];
          return const GalleryScreen();
        },
      ),
      GoRoute(
        path: '/media/:id',
        builder: (context, state) {
          final mediaId = state.pathParameters['id']!;
          final initialIndex = state.uri.queryParameters['index'] != null
              ? int.parse(state.uri.queryParameters['index']!)
              : 0;
          return MediaFullscreenScreen(
            mediaId: mediaId,
            initialIndex: initialIndex,
          );
        },
      ),
    ],
  );
}
