import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// Виджет индикатора загрузки
class LoadingWidget extends StatelessWidget {
  /// Размер индикатора
  final double size;

  /// Цвет индикатора (по умолчанию используется акцентный)
  final Color? color;

  /// Текст подсказки (опционально)
  final String? message;

  const LoadingWidget({
    super.key,
    this.size = 40.0,
    this.color,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Круговой индикатор прогресса
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.accentStart,
              ),
            ),
          ),

          // Текст сообщения
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: AppTypography.sm.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Виджет линейного индикатора загрузки
class LinearLoadingWidget extends StatelessWidget {
  /// Текущее значение прогресса (0.0 - 1.0)
  final double? value;

  /// Цвет индикатора
  final Color? color;

  const LinearLoadingWidget({
    super.key,
    this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: value,
      minHeight: 4,
      backgroundColor: AppColors.surfaceVariant,
      valueColor: AlwaysStoppedAnimation<Color>(
        color ?? AppColors.accentStart,
      ),
      borderRadius: BorderRadius.circular(AppRadius.full),
    );
  }
}
