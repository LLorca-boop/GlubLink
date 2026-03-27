import 'package:isar/isar.dart';

part 'change_log_entity.g.dart';

@collection
class ChangeLogEntity {
  Id id = Isar.autoIncrement;

  late String entityType; // media, tag, note, settings
  late int entityId;
  late String operation; // create, update, delete
  late DateTime timestamp;
  late Map<String, dynamic> changes;
  late String deviceId;
}
