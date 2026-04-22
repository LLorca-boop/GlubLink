import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/widgets/empty_state_widget.dart';

/// Экран управления рабочими пространствами
class WorkspacesScreen extends StatelessWidget {
  const WorkspacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Рабочие пространства'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Создать новое пространство
            },
          ),
        ],
      ),
      body: const EmptyStateWidget(
        icon: Icons.folder_outlined,
        title: 'Нет рабочих пространств',
        subtitle: 'Создайте первое рабочее пространство для организации контента',
        actionText: 'Создать пространство',
      ),
    );
  }
}
