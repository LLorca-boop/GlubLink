import 'package:isar/isar.dart';

part 'note_entity_db.g.dart';

@collection
class NoteEntityDb {
  Id id = Isar.autoIncrement;

  late String title;
  late String content; // JSON string

  late DateTime createdAt;
  late DateTime updatedAt;

  List<String> attachedMediaIds = [];

  int? parentNoteId;

  @Index()
  Map<String, int> version = {};
}
