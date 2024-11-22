// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_visibility.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitVisibilityAdapter extends TypeAdapter<HabitVisibility> {
  @override
  final int typeId = 7;

  @override
  HabitVisibility read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitVisibility(
      habitId: fields[0] as String,
      isVisible: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HabitVisibility obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.habitId)
      ..writeByte(1)
      ..write(obj.isVisible);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitVisibilityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
