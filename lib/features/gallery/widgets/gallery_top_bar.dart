import 'package:flutter/material.dart';
import '../../../../core/animations/spring_config.dart';
import '../../../../core/theme/app_theme.dart';

class GalleryTopBar extends StatelessWidget {
  final bool isDark;
  final String currentPath;
  final bool isFolderSelected;
  final Function(String) onPathChanged;
  final VoidCallback onLayoutToggle;
  final bool isJustifiedLayout;
  final VoidCallback onSelectFolder;
  
  const GalleryTopBar({
    super.key,
    required this.isDark,
    required this.currentPath,
    required this.isFolderSelected,
    required this.onPathChanged,
    required this.onLayoutToggle,
    required this.isJustifiedLayout,
    required this.onSelectFolder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Row(
            children: [
              _buildNavButton(
                icon: Icons.folder_open_rounded,
                isDark: isDark,
                onTap: onSelectFolder,
                isEnabled: true,
              ),
            ],
          ),
          const Spacer(),
          Container(
            height: 24,
            width: 1,
            color: isDark ? Colors.white10 : Colors.black12,
            margin: const EdgeInsets.only(right: 16),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: isFolderSelected ? onLayoutToggle : null,
              child: AnimatedContainer(
                duration: GlubSpringConfig.microInteraction,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isJustifiedLayout ? Icons.view_comfy_rounded : Icons.dashboard_rounded,
                  color: isFolderSelected
                    ? AppTheme.activeButtonColor
                    : (isDark ? Colors.white10 : Colors.black12),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required bool isDark,
    VoidCallback? onTap,
    bool isEnabled = true,
  }) {
    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: AnimatedContainer(
          duration: GlubSpringConfig.microInteraction,
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isEnabled
              ? AppTheme.activeButtonColor
              : (isDark ? Colors.white10 : Colors.black12),
            size: 18,
          ),
        ),
      ),
    );
  }
}