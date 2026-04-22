import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// Виджет пустого состояния для отображения когда нет данных
class EmptyStateWidget extends StatelessWidget {
  /// Иконка для отображения
  final IconData icon;

  /// Заголовок состояния
  final String title;

  /// Подзаголовок с описанием
  final String? subtitle;

  /// Текст кнопки действия (опционально)
  final String? actionText;

  /// Callback при нажатии на кнопку действия
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Иконка с акцентным градиентом
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.mdLg),

              // Заголовок
              Text(
                title,
                style: AppTypography.titleSm.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              // Подзаголовок
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  subtitle!,
                  style: AppTypography.md.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              // Кнопка действия
              if (actionText != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.mdLg),
                ElevatedButton(
                  onPressed: onAction,
                  child: Text(actionText!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
