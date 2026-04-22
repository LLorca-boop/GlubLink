import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/tag_entity.dart';
import '../../data/models/tag_category.dart';
import '../providers/tag_providers.dart';

/// Виджет чипса тега с цветовой индикацией категории
class TagChip extends ConsumerWidget {
  final TagEntity tag;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final double fontSize;
  final bool showCount;

  const TagChip({
    super.key,
    required this.tag,
    this.isSelected = false,
    this.onTap,
    this.onRemove,
    this.fontSize = 12,
    this.showCount = false,
  });

  /// Получить цвет категории
  Color _getCategoryColor(BuildContext context) {
    final category = TagCategory.fromName(tag.category);
    final hexColor = category.hexColor.replaceFirst('#', '');
    return Color(int.parse(hexColor, radix: 16));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _getCategoryColor(context);
    
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.3) : color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? color : color.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Индикатор категории
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              
              // Название тега
              Text(
                tag.name,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? color : Colors.white70,
                ),
              ),
              
              // Счетчик использования
              if (showCount && tag.usageCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${tag.usageCount}',
                    style: TextStyle(
                      fontSize: fontSize - 2,
                      color: color,
                    ),
                  ),
                ),
              ],
              
              // Кнопка удаления
              if (onRemove != null) ...[
                const SizedBox(width: 4),
                InkWell(
                  onTap: onRemove,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      Icons.close,
                      size: fontSize + 2,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Виджет списка тегов с автодополнением
class TagAutocompleteField extends ConsumerStatefulWidget {
  final Function(List<TagEntity>) onTagsSelected;
  final List<TagEntity> initialTags;
  final String? hint;

  const TagAutocompleteField({
    super.key,
    required this.onTagsSelected,
    this.initialTags = const [],
    this.hint,
  });

  @override
  ConsumerState<TagAutocompleteField> createState() => _TagAutocompleteFieldState();
}

class _TagAutocompleteFieldState extends ConsumerState<TagAutocompleteField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<TagEntity> _selectedTags = [];
  List<TagEntity> _suggestions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedTags = List.from(widget.initialTags);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() async {
    final query = _controller.text.trim();
    
    setState(() {
      _isLoading = true;
    });

    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
      return;
    }

    // Поиск с задержкой для оптимизации
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (_controller.text.trim() != query) {
      return;
    }

    final notifier = ref.read(tagStateProvider.notifier);
    final results = await notifier.searchTags(query);
    
    if (mounted) {
      setState(() {
        _suggestions = results.where((t) => !_selectedTags.any((st) => st.id == t.id)).toList();
        _isLoading = false;
      });
    }
  }

  void _addTag(TagEntity tag) {
    setState(() {
      _selectedTags.add(tag);
      _controller.clear();
      _suggestions = [];
    });
    widget.onTagsSelected(_selectedTags);
    
    // Инкремент использования
    ref.read(tagStateProvider.notifier).incrementTagUsage(tag.id);
  }

  void _removeTag(TagEntity tag) {
    setState(() {
      _selectedTags.removeWhere((t) => t.id == tag.id);
    });
    widget.onTagsSelected(_selectedTags);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Выбранные теги
        if (_selectedTags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedTags.map((tag) {
              return TagChip(
                tag: tag,
                onRemove: () => _removeTag(tag),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],

        // Поле ввода с автодополнением
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: widget.hint ?? 'Введите тег...',
            prefixIcon: const Icon(Icons.tag, size: 20),
            suffixIcon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),

        // Список подсказок
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final tag = _suggestions[index];
                return ListTile(
                  leading: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getColorFromCategory(tag.category),
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(tag.name),
                  subtitle: tag.usageCount > 0
                      ? Text('Использований: ${tag.usageCount}')
                      : null,
                  trailing: tag.isProtected
                      ? const Icon(Icons.lock, size: 16, color: Colors.grey)
                      : null,
                  onTap: () => _addTag(tag),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Color _getColorFromCategory(String category) {
    final tagCategory = TagCategory.fromName(category);
    final hexColor = tagCategory.hexColor.replaceFirst('#', '');
    return Color(int.parse(hexColor, radix: 16));
  }
}

/// Виджет фильтра по категориям тегов
class TagCategoryFilter extends ConsumerWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  const TagCategoryFilter({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Фильтр "Все"
          _CategoryChip(
            label: 'Все',
            isSelected: selectedCategory == null,
            color: Colors.grey,
            onTap: () => onCategorySelected(null),
          ),
          const SizedBox(width: 8),
          
          // Фильтры по категориям
          ...TagCategory.values.map((category) {
            final color = Color(int.parse(category.hexColor.replaceFirst('#', ''), radix: 16));
            return _CategoryChip(
              label: _getCategoryDisplayName(category.name),
              isSelected: selectedCategory == category.name,
              color: color,
              onTap: () => onCategorySelected(category.name),
            );
          }),
        ],
      ),
    );
  }

  String _getCategoryDisplayName(String name) {
    switch (name) {
      case 'artist': return 'Автор';
      case 'copyright': return 'Франшиза';
      case 'character': return 'Персонаж';
      case 'species': return 'Вид';
      case 'general': return 'Общее';
      case 'meta': return 'Мета';
      case 'references': return 'Ссылки';
      default: return name;
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.white24,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Colors.white70,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

/// Виджет управления тегами (создание, редактирование, удаление)
class TagManagerDialog extends ConsumerStatefulWidget {
  final TagEntity? tag;

  const TagManagerDialog({super.key, this.tag});

  @override
  ConsumerState<TagManagerDialog> createState() => _TagManagerDialogState();
}

class _TagManagerDialogState extends ConsumerState<TagManagerDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _selectedCategory;
  TextEditingController? _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tag?.name ?? '');
    _selectedCategory = widget.tag?.category ?? 'general';
    if (widget.tag?.description != null) {
      _descriptionController = TextEditingController(text: widget.tag!.description!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController?.dispose();
    super.dispose();
  }

  Future<void> _saveTag() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final notifier = ref.read(tagStateProvider.notifier);
    
    if (widget.tag == null) {
      // Создание нового тега
      final created = await notifier.createTag(
        name: _nameController.text,
        category: _selectedCategory,
        description: _descriptionController?.text,
      );
      
      if (created != null && mounted) {
        Navigator.of(context).pop(created);
      }
    } else {
      // Обновление существующего тега
      final updated = widget.tag!.copyWith(
        name: _nameController.text.toLowerCase().trim(),
        category: _selectedCategory,
        description: _descriptionController?.text,
      );
      
      final success = await notifier.updateTag(updated);
      
      if (success && mounted) {
        Navigator.of(context).pop(updated);
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.tag != null;

    return AlertDialog(
      title: Text(isEditing ? 'Редактировать тег' : 'Новый тег'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Название тега
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Название',
                  hintText: 'Введите название тега',
                  prefixIcon: Icon(Icons.tag),
                ),
                textCapitalization: TextCapitalization.none,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите название тега';
                  }
                  if (value.trim().length > 50) {
                    return 'Название слишком длинное (макс. 50 символов)';
                  }
                  if (!RegExp(r'^[a-z0-9_\-\s]+$').hasMatch(value.toLowerCase())) {
                    return 'Разрешены только буквы, цифры, _ и -';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Категория
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Категория',
                  prefixIcon: Icon(Icons.category),
                ),
                items: TagCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category.name,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Color(int.parse(category.hexColor.replaceFirst('#', ''), radix: 16)),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(_getCategoryDisplayName(category.name)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Описание
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание (опционально)',
                  hintText: 'Краткое описание тега',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),

              // Предупреждение для защищенных тегов
              if (isEditing && widget.tag!.isProtected) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Это защищенный тег. Его нельзя удалить.',
                          style: TextStyle(color: Colors.amber.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        if (isEditing && !widget.tag!.isProtected)
          TextButton(
            onPressed: _isLoading
                ? null
                : () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Удалить тег?'),
                        content: Text('Вы уверены, что хотите удалить тег "${widget.tag!.name}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Отмена'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Удалить'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true && mounted) {
                      final notifier = ref.read(tagStateProvider.notifier);
                      await notifier.deleteTag(widget.tag!.id);
                      if (mounted) Navigator.pop(context);
                    }
                  },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        FilledButton(
          onPressed: _isLoading ? null : _saveTag,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Сохранить' : 'Создать'),
        ),
      ],
    );
  }

  String _getCategoryDisplayName(String name) {
    switch (name) {
      case 'artist': return 'Автор';
      case 'copyright': return 'Франшиза';
      case 'character': return 'Персонаж';
      case 'species': return 'Вид';
      case 'general': return 'Общее';
      case 'meta': return 'Мета';
      case 'references': return 'Ссылки';
      default: return name;
    }
  }
}
