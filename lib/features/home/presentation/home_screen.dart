import 'package:flutter/material.dart';
import '../../../core/animations/spring_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/navigation_history.dart';
import '../../gallery/presentation/gallery_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSidebarExpanded = false;
  bool _isMediaExpandedInSidebar = false;
  bool _isNotesExpandedInSidebar = false;
  bool _isMediaExpandedOnMain = false;
  bool _isNotesExpandedOnMain = false;
  int? _hoveredButtonIndex;
  String _currentPage = 'home';
  final GlobalKey<GalleryViewState> _galleryKey = GlobalKey<GalleryViewState>();
  final List<NavigationAction> _navigationHistory = [];
  int _currentHistoryIndex = -1;
  String _currentFolderPath = '';

  @override
  void initState() {
    super.initState();
    _addAction(NavigationAction(
      type: NavigationActionType.pageChange,
      page: 'home',
    ));
  }

  void _addAction(NavigationAction action) {
    if (_currentHistoryIndex < _navigationHistory.length - 1) {
      _navigationHistory.removeRange(_currentHistoryIndex + 1, _navigationHistory.length);
    }
    _navigationHistory.add(action);
    _currentHistoryIndex = _navigationHistory.length - 1;
  }

  void _navigateToPage(String page) {
    if (_currentPage == page) return;
    setState(() {
      _currentPage = page;
    });
    _addAction(NavigationAction(
      type: NavigationActionType.pageChange,
      page: page,
    ));
  }

  void _goBack() {
    if (_currentHistoryIndex > 0) {
      _currentHistoryIndex--;
      final action = _navigationHistory[_currentHistoryIndex];
      _handleAction(action);
    }
  }

  void _goForward() {
    if (_currentHistoryIndex < _navigationHistory.length - 1) {
      _currentHistoryIndex++;
      final action = _navigationHistory[_currentHistoryIndex];
      _handleAction(action);
    }
  }

  void _handleAction(NavigationAction action) {
    switch (action.type) {
      case NavigationActionType.pageChange:
        if (action.page != null) {
          setState(() {
            _currentPage = action.page!;
          });
        }
        break;
      case NavigationActionType.folderSelect:
      case NavigationActionType.folderNavigate:
        if (action.folderPath != null && _currentPage == 'media') {
          _galleryKey.currentState?.navigateToFolder(action.folderPath!);
          setState(() {
            _currentFolderPath = action.folderPath!;
          });
        }
        break;
      default:
        break;
    }
  }

  void _refresh() {
    if (_currentPage == 'media') {
      _galleryKey.currentState?.refresh();
    }
  }

  void _selectFolder() {
    if (_currentPage == 'media') {
      _galleryKey.currentState?.selectFolder();
    }
  }

  void _addGalleryAction(NavigationAction action) {
    _addAction(action);
    if (action.folderPath != null) {
      setState(() {
        _currentFolderPath = action.folderPath!;
      });
    }
  }

  void _updateFolderPath(String path) {
    setState(() {
      _currentFolderPath = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Row(
        children: [
          ClipRect(
            child: AnimatedContainer(
              duration: GlubSpringConfig.panelTransition,
              curve: Curves.easeInOut,
              width: _isSidebarExpanded ? 220 : 60,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.sidebarColorDark : AppTheme.sidebarColorLight,
                border: Border(
                  right: BorderSide(
                    color: isDark ? Colors.white10 : Colors.black12,
                    width: 1,
                  ),
                ),
              ),
              child: _buildSidebar(isDark),
            ),
          ),
          Expanded(
            child: Container(
              color: isDark ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
              child: _buildMainPanel(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildExpandButton(isDark),
        const SizedBox(height: 32),
        _buildSidebarItem(
          index: 0,
          icon: Icons.home_rounded,
          label: 'Home',
          isActive: _currentPage == 'home',
          isDark: isDark,
          onTap: () => _navigateToPage('home'),
        ),
        if (_isSidebarExpanded)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Divider(color: Colors.white10, height: 1),
          ),
        const SizedBox(height: 8),
        _buildSidebarItemWithDropdown(
          index: 1,
          icon: Icons.photo_library_rounded,
          label: 'Media',
          isActive: _currentPage == 'media',
          isDark: isDark,
          isExpanded: _isMediaExpandedInSidebar,
          onItemTap: () {
            _navigateToPage('media');
            setState(() {
              _isMediaExpandedInSidebar = false;
            });
          },
          onArrowTap: () {
            setState(() {
              _isMediaExpandedInSidebar = !_isMediaExpandedInSidebar;
              _isNotesExpandedInSidebar = false;
            });
          },
        ),
        if (_isSidebarExpanded && _isMediaExpandedInSidebar) ...[
          const SizedBox.shrink(),
        ],
        const SizedBox(height: 4),
        _buildSidebarItemWithDropdown(
          index: 2,
          icon: Icons.note_rounded,
          label: 'Notes',
          isActive: _currentPage == 'notes',
          isDark: isDark,
          isExpanded: _isNotesExpandedInSidebar,
          onItemTap: () {
            _navigateToPage('notes');
            setState(() {
              _isNotesExpandedInSidebar = false;
            });
          },
          onArrowTap: () {
            setState(() {
              _isNotesExpandedInSidebar = !_isNotesExpandedInSidebar;
              _isMediaExpandedInSidebar = false;
            });
          },
        ),
        if (_isSidebarExpanded && _isNotesExpandedInSidebar) ...[
          const SizedBox.shrink(),
        ],
        const Spacer(),
        if (_isSidebarExpanded)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Divider(color: Colors.white10, height: 1),
          ),
        _buildSidebarItem(
          index: 3,
          icon: Icons.settings_rounded,
          label: 'Settings',
          isActive: _currentPage == 'settings',
          isDark: isDark,
          onTap: () => _navigateToPage('settings'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildExpandButton(bool isDark) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isSidebarExpanded = !_isSidebarExpanded;
          });
        },
        child: AnimatedContainer(
          duration: GlubSpringConfig.microInteraction,
          width: 40,
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceColorDark : AppTheme.surfaceColorLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.menu_rounded,
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        if (_hoveredButtonIndex != index) {
          setState(() => _hoveredButtonIndex = index);
        }
      },
      onExit: (_) {
        if (_hoveredButtonIndex != null) {
          setState(() => _hoveredButtonIndex = null);
        }
      },
      child: AnimatedContainer(
        duration: GlubSpringConfig.microInteraction,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.activeButtonColor
              : (_hoveredButtonIndex == index
                  ? (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03))
                  : Colors.transparent),
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            height: 44,
            child: ClipRect(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 12,
                    top: 10,
                    child: Icon(
                      icon,
                      color: AppTheme.getIconColor(isActive, isDark),
                      size: 20,
                    ),
                  ),
                  if (_isSidebarExpanded)
                    Positioned(
                      left: 48,
                      right: 12,
                      top: 12,
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isActive
                              ? (isDark ? Colors.white : Colors.black87)
                              : (isDark ? AppTheme.textColorDark : AppTheme.textColorLight),
                          fontSize: 14,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarItemWithDropdown({
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isDark,
    required bool isExpanded,
    VoidCallback? onItemTap,
    VoidCallback? onArrowTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        if (_hoveredButtonIndex != index) {
          setState(() => _hoveredButtonIndex = index);
        }
      },
      onExit: (_) {
        if (_hoveredButtonIndex != null) {
          setState(() => _hoveredButtonIndex = null);
        }
      },
      child: AnimatedContainer(
        duration: GlubSpringConfig.microInteraction,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.activeButtonColor
              : (_hoveredButtonIndex == index
                  ? (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03))
                  : Colors.transparent),
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox(
          height: 44,
          child: ClipRect(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: _isSidebarExpanded ? 44 : 0,
                  top: 0,
                  bottom: 0,
                  child: InkWell(
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      bottomLeft: const Radius.circular(12),
                      topRight: isActive && _isSidebarExpanded ? Radius.zero : const Radius.circular(12),
                      bottomRight: isActive && _isSidebarExpanded ? Radius.zero : const Radius.circular(12),
                    ),
                    onTap: onItemTap,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 12,
                          top: 10,
                          child: Icon(
                            icon,
                            color: AppTheme.getIconColor(isActive, isDark),
                            size: 20,
                          ),
                        ),
                        if (_isSidebarExpanded)
                          Positioned(
                            left: 48,
                            right: 12,
                            top: 12,
                            child: Text(
                              label,
                              style: TextStyle(
                                color: isActive
                                    ? (isDark ? Colors.white : Colors.black87)
                                    : (isDark ? AppTheme.textColorDark : AppTheme.textColorLight),
                                fontSize: 14,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (_isSidebarExpanded)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: onArrowTap,
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: GlubSpringConfig.microInteraction,
                          width: 44,
                          height: 44,
                          decoration: isActive
                              ? BoxDecoration(
                                  color: isDark
                                      ? AppTheme.activeButtonColor.withValues(alpha: 0.8)
                                      : AppTheme.activeButtonColor.withValues(alpha: 0.9),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                )
                              : null,
                          child: AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: GlubSpringConfig.microInteraction,
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppTheme.getIconColor(isActive, isDark),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainPanel(bool isDark) {
    return Column(
      children: [
        _buildTopBar(isDark),
        Expanded(child: _buildContentArea(isDark)),
      ],
    );
  }

  Widget _buildTopBar(bool isDark) {
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
                icon: Icons.arrow_back_ios_rounded,
                isDark: isDark,
                onTap: _currentHistoryIndex > 0 ? _goBack : null,
                isEnabled: _currentHistoryIndex > 0,
              ),
              const SizedBox(width: 8),
              _buildNavButton(
                icon: Icons.arrow_forward_ios_rounded,
                isDark: isDark,
                onTap: _currentHistoryIndex < _navigationHistory.length - 1 ? _goForward : null,
                isEnabled: _currentHistoryIndex < _navigationHistory.length - 1,
              ),
              const SizedBox(width: 8),
              _buildNavButton(
                icon: Icons.refresh_rounded,
                isDark: isDark,
                onTap: _refresh,
                isEnabled: true,
              ),
            ],
          ),
          if (_currentPage == 'media') ...[
            const SizedBox(width: 8),
            _buildNavButton(
              icon: Icons.folder_open_rounded,
              isDark: isDark,
              onTap: _selectFolder,
              isEnabled: true,
            ),
            if (_currentFolderPath.isNotEmpty) ...[
              const SizedBox(width: 24),
              Expanded(child: _buildPathBar(isDark)),
            ],
          ],
          if (_currentPage == 'media') ...[
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
                onTap: () {
                  _galleryKey.currentState?.toggleLayout();
                },
                child: AnimatedContainer(
                  duration: GlubSpringConfig.microInteraction,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.view_comfy_rounded,
                    color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPathBar(bool isDark) {
    if (_currentFolderPath.isEmpty) return const SizedBox.shrink();
    final pathSegments = _currentFolderPath.split('\\');
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < pathSegments.length; i++) ...[
            if (i > 0)
              const Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: AppTheme.textSecondaryDark,
              ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  final newPath = pathSegments.sublist(0, i + 1).join('\\');
                  _galleryKey.currentState?.navigateToFolder(newPath);
                  setState(() {
                    _currentFolderPath = newPath;
                  });
                  _addAction(NavigationAction(
                    type: NavigationActionType.folderNavigate,
                    folderPath: newPath,
                  ));
                },
                child: Text(
                  pathSegments[i].isEmpty ? 'C:' : pathSegments[i],
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppTheme.textColorDark : AppTheme.textColorLight,
                  ),
                ),
              ),
            ),
          ],
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

  Widget _buildContentArea(bool isDark) {
    return IndexedStack(
      index: _getPageIndex(_currentPage),
      children: [
        _buildHomePageContent(isDark),
        GalleryView(
          key: _galleryKey,
          onAction: _addGalleryAction,
          onFolderPathChanged: _updateFolderPath,
        ),
        _buildNotesPageContent(isDark),
        _buildSettingsPageContent(isDark),
      ],
    );
  }

  int _getPageIndex(String page) {
    switch (page) {
      case 'home':
        return 0;
      case 'media':
        return 1;
      case 'notes':
        return 2;
      case 'settings':
        return 3;
      default:
        return 0;
    }
  }

  Widget _buildHomePageContent(bool isDark) {
    return Stack(
      children: [
        Center(child: _buildLogo()),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.15,
          top: MediaQuery.of(context).size.height * 0.55,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEmptyStateIndicator(
                icon: Icons.note_outlined,
                label: 'recent notes',
                isDark: isDark,
                isExpanded: _isNotesExpandedOnMain,
                onTap: () {
                  setState(() {
                    _isNotesExpandedOnMain = !_isNotesExpandedOnMain;
                  });
                },
              ),
              const SizedBox(height: 8),
              _buildEmptyStateIndicator(
                icon: Icons.image_outlined,
                label: 'recent media',
                isDark: isDark,
                isExpanded: _isMediaExpandedOnMain,
                onTap: () {
                  setState(() {
                    _isMediaExpandedOnMain = !_isMediaExpandedOnMain;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesPageContent(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.note_rounded,
            size: 64,
            color: AppTheme.activeButtonColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Notes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.textColorDark : AppTheme.textColorLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming in v0.2',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPageContent(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.settings_rounded,
            size: 64,
            color: AppTheme.activeButtonColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.textColorDark : AppTheme.textColorLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Glub',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6C63FF),
            letterSpacing: -1,
          ),
        ),
        Container(
          width: 40,
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFFFF6B9D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(5),
              bottomLeft: Radius.circular(5),
            ),
          ),
        ),
        const Text(
          'ink',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF6B9D),
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStateIndicator({
    required IconData icon,
    required String label,
    required bool isDark,
    required bool isExpanded,
    VoidCallback? onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: GlubSpringConfig.microInteraction,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: AppTheme.activeButtonColor,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                ),
              ),
              const SizedBox(width: 6),
              AnimatedRotation(
                turns: isExpanded ? 0.25 : 0,
                duration: GlubSpringConfig.microInteraction,
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 10,
                  color: AppTheme.activeButtonColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}