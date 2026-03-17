// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'devices.schema.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeviceDataAdapter extends TypeAdapter<DeviceData> {
  @override
  final int typeId = 0;

  @override
  DeviceData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeviceData()
      ..deviceId = fields[0] as String
      ..deviceName = fields[1] as String?
      ..serialNumber = fields[2] as String?
      ..city = fields[3] as String?
      ..status = fields[4] as String?
      ..updatedAt = fields[5] as String?;
  }

  @override
  void write(BinaryWriter writer, DeviceData obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.deviceId)
      ..writeByte(1)
      ..write(obj.deviceName)
      ..writeByte(2)
      ..write(obj.serialNumber)
      ..writeByte(3)
      ..write(obj.city)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
