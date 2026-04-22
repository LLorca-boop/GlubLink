// lib/features/gallery/presentation/pages/gallery_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/gallery_widgets.dart';

/// Главная страница галереи контента
/// Реализует макет с тремя зонами:
/// 1. Верхняя панель управления (Toolbar)
/// 2. Центральная область с сеткой контента
/// 3. Правая контекстная панель (выезжает при необходимости)
class GalleryPage extends ConsumerStatefulWidget {
  const GalleryPage({super.key});

  @override
  ConsumerState<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends ConsumerState<GalleryPage>
    with TickerProviderStateMixin {
  bool _isContextPanelVisible = false;
  late AnimationController _contextPanelAnimationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Инициализация анимации контекстной панели
    _contextPanelAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contextPanelAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _contextPanelAnimationController.dispose();
    super.dispose();
  }

  void _toggleContextPanel() {
    setState(() {
      _isContextPanelVisible = !_isContextPanelVisible;
      if (_isContextPanelVisible) {
        _contextPanelAnimationController.forward();
      } else {
        _contextPanelAnimationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Основная область (Toolbar + Grid)
          Expanded(
            child: Column(
              children: [
                // Верхняя панель управления
                const GalleryToolbar(),
                
                // Сетка контента
                Expanded(
                  child: Stack(
                    children: [
                      const GalleryGrid(),
                      
                      // Кнопка переключения контекстной панели
                      Positioned(
                        top: 16,
                        right: 16,
                        child: FloatingActionButton.small(
                          onPressed: _toggleContextPanel,
                          heroTag: 'context_panel_toggle',
                          child: Icon(
                            _isContextPanelVisible
                                ? Icons.close
                                : Icons.tune,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Контекстная панель (выезжает справа)
          if (_isContextPanelVisible)
            SlideTransition(
              position: _slideAnimation,
              child: GestureDetector(
                onTap: () {
                  // Клик вне области закрывает панель
                  _toggleContextPanel();
                },
                child: Container(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: () {}, // Предотвращаем закрытие при клике на панель
                    child: const ContextTagsPanel(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
