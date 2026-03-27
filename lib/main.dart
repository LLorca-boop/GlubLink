import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/database/database_service.dart';
import 'core/services/ai_service.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация базы данных
  await DatabaseService.initialize();
  
  // Инициализация AI сервиса
  await AiService().initialize();
  
  runApp(const ProviderScope(child: GlubLinkApp()));
}

class GlubLinkApp extends StatelessWidget {
  const GlubLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GlubLink',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: AppRouter.router,
    );
  }
}
