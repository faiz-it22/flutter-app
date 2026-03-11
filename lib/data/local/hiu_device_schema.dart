import 'package:hive/hive.dart';

part 'hiu_device_schema.g.dart';

@HiveType(typeId: 1)
class HiuDevice extends HiveObject {
  @HiveField(0)
  late String remoteId;

  @HiveField(1)
  late String name;

  @HiveField(2)
  DateTime? lastConnected;

  @HiveField(3)
  String? firmwareVersion;
}
