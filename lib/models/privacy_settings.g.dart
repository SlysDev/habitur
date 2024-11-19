// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privacy_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrivacySettingsAdapter extends TypeAdapter<PrivacySettings> {
  @override
  final int typeId = 5;

  @override
  PrivacySettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrivacySettings(
      shareActivities: fields[0] as bool,
      shareHabitCompletions: fields[1] as bool,
      shareStreakMilestones: fields[2] as bool,
      shareNewHabits: fields[3] as bool,
      shareProfilePicture: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PrivacySettings obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.shareActivities)
      ..writeByte(1)
      ..write(obj.shareHabitCompletions)
      ..writeByte(2)
      ..write(obj.shareStreakMilestones)
      ..writeByte(3)
      ..write(obj.shareNewHabits)
      ..writeByte(4)
      ..write(obj.shareProfilePicture);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrivacySettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
