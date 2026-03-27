import 'package:isar/isar.dart';

part 'tag_entity_db.g.dart';

@collection
class TagEntityDb {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  String? nameEn;
  String? nameRu;

  @Index()
  late String category; // Artist, Copyrights, Characters, Species, General, Meta, References

  late String color;

  @Index()
  int usageCount = 0;

  bool isNsfw = false;
  bool isMeta = false;

  @Index()
  Map<String, int> version = {};
}
