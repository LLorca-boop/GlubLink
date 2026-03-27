/// User Settings Entity - модель пользовательских настроек
class UserSettingsEntity {
  FileOrganizationMode fileOrganizationMode;
  String selectedFolderPath;
  AppTheme theme;
  String language;
  TagSortMode tagSortMode;
  LayoutMode layoutMode;
  int fontSize;
  bool showTagCount;

  UserSettingsEntity({
    this.fileOrganizationMode = FileOrganizationMode.virtual,
    this.selectedFolderPath = '',
    this.theme = AppTheme.dark,
    this.language = 'Русский',
    this.tagSortMode = TagSortMode.byCount,
    this.layoutMode = LayoutMode.justified,
    this.fontSize = 14,
    this.showTagCount = true,
  });

  UserSettingsEntity copyWith({
    FileOrganizationMode? fileOrganizationMode,
    String? selectedFolderPath,
    AppTheme? theme,
    String? language,
    TagSortMode? tagSortMode,
    LayoutMode? layoutMode,
    int? fontSize,
    bool? showTagCount,
  }) {
    return UserSettingsEntity(
      fileOrganizationMode: fileOrganizationMode ?? this.fileOrganizationMode,
      selectedFolderPath: selectedFolderPath ?? this.selectedFolderPath,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      tagSortMode: tagSortMode ?? this.tagSortMode,
      layoutMode: layoutMode ?? this.layoutMode,
      fontSize: fontSize ?? this.fontSize,
      showTagCount: showTagCount ?? this.showTagCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fileOrganizationMode': fileOrganizationMode.name,
      'selectedFolderPath': selectedFolderPath,
      'theme': theme.name,
      'language': language,
      'tagSortMode': tagSortMode.name,
      'layoutMode': layoutMode.name,
      'fontSize': fontSize,
      'showTagCount': showTagCount,
    };
  }

  factory UserSettingsEntity.fromMap(Map<String, dynamic> map) {
    return UserSettingsEntity(
      fileOrganizationMode: FileOrganizationMode.fromString(
        map['fileOrganizationMode'] as String? ?? 'virtual',
      ),
      selectedFolderPath: map['selectedFolderPath'] as String? ?? '',
      theme: AppTheme.fromString(map['theme'] as String? ?? 'dark'),
      language: map['language'] as String? ?? 'Русский',
      tagSortMode: TagSortMode.fromString(map['tagSortMode'] as String? ?? 'byCount'),
      layoutMode: LayoutMode.fromString(map['layoutMode'] as String? ?? 'justified'),
      fontSize: map['fontSize'] as int? ?? 14,
      showTagCount: map['showTagCount'] as bool? ?? true,
    );
  }
}

enum FileOrganizationMode {
  virtual, // Виртуальный режим (файлы не перемещаются)
  physical; // Физический режим (Hard Links)

  static FileOrganizationMode fromString(String value) {
    switch (value.toLowerCase()) {
      case 'physical':
        return FileOrganizationMode.physical;
      default:
        return FileOrganizationMode.virtual;
    }
  }
}

enum AppTheme {
  dark,
  light;

  static AppTheme fromString(String value) {
    switch (value.toLowerCase()) {
      case 'light':
        return AppTheme.light;
      default:
        return AppTheme.dark;
    }
  }
}

enum TagSortMode {
  byCount, // по количеству медиа
  alphabetical, // по алфавиту
  byFrequency; // по частоте использования

  static TagSortMode fromString(String value) {
    switch (value.toLowerCase()) {
      case 'alphabetical':
        return TagSortMode.alphabetical;
      case 'byFrequency':
        return TagSortMode.byFrequency;
      default:
        return TagSortMode.byCount;
    }
  }
}

enum LayoutMode {
  justified, // Justified Layout - горизонтальная сетка с выравниванием
  masonry; // Masonry Layout - плотная кирпичная кладка

  static LayoutMode fromString(String value) {
    switch (value.toLowerCase()) {
      case 'masonry':
        return LayoutMode.masonry;
      default:
        return LayoutMode.justified;
    }
  }
}
