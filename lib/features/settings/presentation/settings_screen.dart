import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/constants/app_constants.dart';

/// Экран настроек приложения
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Секция: О приложении
          _buildSectionTitle('О приложении'),
          Card(
            child: ListTile(
              leading: _buildIconContainer(Icons.info_outline),
              title: const Text('Версия'),
              subtitle: Text(AppConstants.appVersion),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Секция: Интерфейс
          _buildSectionTitle('Интерфейс'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: _buildIconContainer(Icons.palette_outlined),
                  title: const Text('Темная тема'),
                  subtitle: const Text('Использовать темную тему оформления'),
                  value: true,
                  onChanged: (value) {
                    // TODO: Переключение темы
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: _buildIconContainer(Icons.animation_outlined),
                  title: const Text('Анимации'),
                  subtitle: const Text('Включить анимации интерфейса'),
                  value: true,
                  onChanged: (value) {
                    // TODO: Переключение анимаций
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Секция: Хранилище
          _buildSectionTitle('Хранилище'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: _buildIconContainer(Icons.storage_outlined),
                  title: const Text('Использование хранилища'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Показать статистику хранилища
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: _buildIconContainer(Icons.cleaning_services_outlined),
                  title: const Text('Очистить кэш'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Очистка кэша
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: AppTypography.sm.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildIconContainer(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}
