import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';

/// Точка входа приложения GlubLink
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: Инициализация Isar базы данных
  // TODO: Инициализация Riverpod контейнера
  
  runApp(const GlubLinkApp());
}

/// Корневой виджет приложения GlubLink
class GlubLinkApp extends StatelessWidget {
  const GlubLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlubLink',
      debugShowCheckedModeBanner: false,
      
      // Тема приложения
      theme: AppTheme.darkTheme,
      
      // Локализация
      locale: const Locale('ru'),
      supportedLocales: const [
        Locale('ru'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Домашний экран
      home: const DashboardScreen(),
    );
  }
}
