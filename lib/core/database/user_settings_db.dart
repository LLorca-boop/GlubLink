import 'package:isar/isar.dart';

part 'user_settings_db.g.dart';

@collection
class UserSettingsDb {
  Id id = 0; // Singleton

  late String fileOrganizationMode; // Virtual, Physical
  String? selectedFolderPath;
  late String theme; // Dark, Light
  late String language; // ru, en
  late String tagSortMode; // ByCount, Alphabetical, ByFrequency
  late String layoutMode; // Justified, Masonry
  int fontSize = 14;
  bool showTagCount = true;

  // AI Settings
  String? qwenApiKey;
  String? huggingFaceApiKey;

  // NSFW Settings
  bool showNsfwContent = false;

  // Backup settings
  DateTime? lastBackupDate;
}
