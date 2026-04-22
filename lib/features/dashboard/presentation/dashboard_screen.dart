import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// Экран главной панели (Dashboard)
/// Отображает сводную информацию и быстрый доступ к контенту
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главная'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Реализовать поиск
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Навигация к настройкам
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Добро пожаловать в GlubLink',
              style: AppTypography.titleMd.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Система визуального кураторства',
              style: AppTypography.md.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                children: [
                  _buildActionCard(
                    context,
                    icon: Icons.folder_outlined,
                    title: 'Рабочие пространства',
                    subtitle: 'Управление проектами',
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.image_outlined,
                    title: 'Галерея',
                    subtitle: 'Все медиафайлы',
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.note_outlined,
                    title: 'Заметки',
                    subtitle: 'Быстрые записи',
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.link_outlined,
                    title: 'Коллекции',
                    subtitle: 'Сохраненные ссылки',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      child: InkWell(
        onTap: () {
          // TODO: Навигация к соответствующему разделу
        },
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: AppTypography.lg.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: AppTypography.sm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
