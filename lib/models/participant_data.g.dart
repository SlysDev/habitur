// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ParticipantDataAdapter extends TypeAdapter<ParticipantData> {
  @override
  final int typeId = 10;

  @override
  ParticipantData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ParticipantData(
      username: fields[0] as String,
      userId: fields[1] as String,
      habit: fields[2] as Habit,
    );
  }

  @override
  void write(BinaryWriter writer, ParticipantData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.habit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParticipantDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
