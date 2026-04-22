import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/widgets/empty_state_widget.dart';

/// Экран галереи медиафайлов
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Галерея'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Добавить новый медиафайл
            },
          ),
        ],
      ),
      body: const EmptyStateWidget(
        icon: Icons.image_outlined,
        title: 'Галерея пуста',
        subtitle: 'Добавьте первые медиафайлы для начала работы',
        actionText: 'Добавить файл',
      ),
    );
  }
}
