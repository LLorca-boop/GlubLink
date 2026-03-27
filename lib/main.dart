import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/navigation_history.dart';
import 'features/home/presentation/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: GlubLinkApp()));
}

// ✅ Провайдер для глобальной истории навигации
final navigationHistoryProvider = ChangeNotifierProvider((ref) {
  return NavigationHistory();
});

class GlubLinkApp extends ConsumerWidget {
  const GlubLinkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'GlubLink',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);