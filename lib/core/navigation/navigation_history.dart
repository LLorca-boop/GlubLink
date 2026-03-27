import 'package:flutter/foundation.dart';

enum NavigationActionType {
  pageChange,      // Переход между страницами (Home/Media/Notes)
  folderSelect,    // Выбор папки
  folderNavigate,  // Навигация по папкам (внутри Media)
  sidebarTab,      // Переход по вкладкам в sidebar
  search,          // Поиск/фильтр
  other,           // Другие действия
}

class NavigationAction {
  final NavigationActionType type;
  final String? page;           // Для pageChange: 'home', 'media', 'notes'
  final String? folderPath;     // Для folderSelect/folderNavigate
  final String? sidebarTab;     // Для sidebarTab
  final String? searchQuery;    // Для search
  final DateTime timestamp;

  NavigationAction({
    required this.type,
    this.page,
    this.folderPath,
    this.sidebarTab,
    this.searchQuery,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class NavigationHistory extends ChangeNotifier {
  final List<NavigationAction> _history = [];
  int _currentIndex = -1;

  // ✅ Максимальная длина истории
  static const int maxHistoryLength = 100;

  bool get canGoBack => _currentIndex > 0;
  bool get canGoForward => _currentIndex < _history.length - 1;
  int get currentIndex => _currentIndex;
  List<NavigationAction> get history => List.unmodifiable(_history);

  NavigationAction? get currentAction => 
      _currentIndex >= 0 && _currentIndex < _history.length 
          ? _history[_currentIndex] 
          : null;

  // ✅ Добавить действие в историю
  void addAction(NavigationAction action) {
    // Удаляем всю историю после текущей позиции при новом действии
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }

    // Ограничиваем длину истории
    if (_history.length >= maxHistoryLength) {
      _history.removeAt(0);
      _currentIndex--;
    }

    _history.add(action);
    _currentIndex = _history.length - 1;
    
    notifyListeners();
  }

  // ✅ Назад
  NavigationAction? goBack() {
    if (canGoBack) {
      _currentIndex--;
      notifyListeners();
      return _history[_currentIndex];
    }
    return null;
  }

  // ✅ Вперёд
  NavigationAction? goForward() {
    if (canGoForward) {
      _currentIndex++;
      notifyListeners();
      return _history[_currentIndex];
    }
    return null;
  }

  // ✅ Очистить историю
  void clear() {
    _history.clear();
    _currentIndex = -1;
    notifyListeners();
  }

  // ✅ Получить последнее действие определённого типа
  NavigationAction? getLastActionOfType(NavigationActionType type) {
    for (int i = _history.length - 1; i >= 0; i--) {
      if (_history[i].type == type) {
        return _history[i];
      }
    }
    return null;
  }
}