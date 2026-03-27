import 'package:isar/isar.dart';

part 'media_entity.g.dart';

@collection
class MediaEntity {
  Id id = Isar.autoIncrement;

  @Index()
  late String path;

  @Index()
  late String type; // image, gif, video

  @Index()
  List<String> tagIds = [];

  late DateTime dateAdded;
  late DateTime dateModified;

  int size = 0;

  int width = 0;
  int height = 0;

  bool isNsfw = false;
  bool isFavorite = false;

  String? noteId;

  @Index()
  Map<String, int> version = {};

  String? lastSyncDevice;

  @ignore
  List<String> tags = []; // Denormalized for quick access
}
