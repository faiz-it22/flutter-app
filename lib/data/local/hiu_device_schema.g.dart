// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hiu_device_schema.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiuDeviceAdapter extends TypeAdapter<HiuDevice> {
  @override
  final int typeId = 1;

  @override
  HiuDevice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiuDevice()
      ..remoteId = fields[0] as String
      ..name = fields[1] as String
      ..lastConnected = fields[2] as DateTime?
      ..firmwareVersion = fields[3] as String?;
  }

  @override
  void write(BinaryWriter writer, HiuDevice obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.remoteId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.lastConnected)
      ..writeByte(3)
      ..write(obj.firmwareVersion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiuDeviceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
