import 'package:hive/hive.dart';

part 'devices.schema.g.dart';

@HiveType(typeId: 0)
class DeviceData extends HiveObject {
  @HiveField(0)
  late String deviceId;

  @HiveField(1)
  String? deviceName;

  @HiveField(2)
  String? serialNumber;

  @HiveField(3)
  String? city;

  @HiveField(4)
  String? status;

  @HiveField(5) // Add this field
  String? updatedAt;
}