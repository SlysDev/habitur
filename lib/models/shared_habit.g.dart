// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_habit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SharedHabitAdapter extends TypeAdapter<SharedHabit> {
  @override
  final int typeId = 2;

  @override
  SharedHabit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SharedHabit(
      title: fields[0] as String,
      id: fields[11] as int,
      description: fields[17] == null ? '' : fields[17] as String?,
      targetGoal: fields[3] as int?,
      author: fields[20] as UserModel?,
      participantData: (fields[19] as List?)?.cast<ParticipantData>(),
      streak: fields[2] as int,
      currentProgress: fields[4] as int,
      totalProgress: fields[5] as int,
      highestStreak: fields[6] as int,
      resetPeriod: fields[7] as String,
      dateCreated: fields[8] as DateTime?,
      confidenceLevel: fields[9] as double,
      lastSeen: fields[10] as DateTime?,
      daysCompleted:
          fields[12] == null ? [] : (fields[12] as List?)?.cast<DateTime>(),
      requiredDatesOfCompletion: (fields[13] as List?)?.cast<String>(),
      smartNotifsEnabled: fields[14] as bool,
    )
      ..proficiencyRating = fields[1] as int
      ..isShared = fields[18] == null ? false : fields[18] as bool
      ..stats = fields[16] == null ? [] : (fields[16] as List).cast<StatPoint>()
      ..isVisible = fields[15] as bool;
  }

  @override
  void write(BinaryWriter writer, SharedHabit obj) {
    writer
      ..writeByte(21)
      ..writeByte(19)
      ..write(obj.participantData)
      ..writeByte(20)
      ..write(obj.author)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(17)
      ..write(obj.description)
      ..writeByte(1)
      ..write(obj.proficiencyRating)
      ..writeByte(2)
      ..write(obj.streak)
      ..writeByte(3)
      ..write(obj.targetGoal)
      ..writeByte(4)
      ..write(obj.currentProgress)
      ..writeByte(5)
      ..write(obj.totalProgress)
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
      ..writeByte(18)
      ..write(obj.isShared)
      ..writeByte(12)
      ..write(obj.daysCompleted)
      ..writeByte(13)
      ..write(obj.requiredDatesOfCompletion)
      ..writeByte(16)
      ..write(obj.stats)
      ..writeByte(14)
      ..write(obj.smartNotifsEnabled)
      ..writeByte(15)
      ..write(obj.isVisible);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SharedHabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
