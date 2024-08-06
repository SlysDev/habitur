// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 0;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      title: fields[0] as String,
      dateCreated: fields[8] as DateTime,
      resetPeriod: fields[7] as String,
      id: fields[11] as int,
      lastSeen: fields[10] as DateTime,
      streak: fields[2] as int,
      highestStreak: fields[6] as int,
      completionsToday: fields[4] as int,
      totalCompletions: fields[5] as int,
      confidenceLevel: fields[9] as double,
      requiredDatesOfCompletion: (fields[13] as List).cast<String>(),
      requiredCompletions: fields[3] as int,
    )
      ..proficiencyRating = fields[1] as int
      ..daysCompleted = (fields[12] as List).cast<DateTime>()
      ..stats = (fields[14] as List).cast<StatPoint>();
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.proficiencyRating)
      ..writeByte(2)
      ..write(obj.streak)
      ..writeByte(3)
      ..write(obj.requiredCompletions)
      ..writeByte(4)
      ..write(obj.completionsToday)
      ..writeByte(5)
      ..write(obj.totalCompletions)
      ..writeByte(6)
      ..write(obj.highestStreak)
      ..writeByte(7)
      ..write(obj.resetPeriod)
      ..writeByte(8)
      ..write(obj.dateCreated)
      ..writeByte(9)
      ..write(obj.confidenceLevel)
      ..writeByte(10)
      ..write(obj.lastSeen)
      ..writeByte(11)
      ..write(obj.id)
      ..writeByte(12)
      ..write(obj.daysCompleted)
      ..writeByte(13)
      ..write(obj.requiredDatesOfCompletion)
      ..writeByte(14)
      ..write(obj.stats);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
