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
      statsScope: fields[0] as SharingScope,
      habitsScope: fields[1] as SharingScope,
      shareConfidenceLevel: fields[2] as bool,
      shareConsistencyFactor: fields[3] as bool,
      shareActivities: fields[4] as bool,
      shareHabitCompletions: fields[5] as bool,
      shareStreakMilestones: fields[6] as bool,
      shareNewHabits: fields[7] as bool,
      shareCommunityChallengeCompletions: fields[9] as bool,
      shareProfilePicture: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PrivacySettings obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.statsScope)
      ..writeByte(1)
      ..write(obj.habitsScope)
      ..writeByte(2)
      ..write(obj.shareConfidenceLevel)
      ..writeByte(3)
      ..write(obj.shareConsistencyFactor)
      ..writeByte(4)
      ..write(obj.shareActivities)
      ..writeByte(5)
      ..write(obj.shareHabitCompletions)
      ..writeByte(6)
      ..write(obj.shareStreakMilestones)
      ..writeByte(7)
      ..write(obj.shareNewHabits)
      ..writeByte(9)
      ..write(obj.shareCommunityChallengeCompletions)
      ..writeByte(8)
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

class SharingScopeAdapter extends TypeAdapter<SharingScope> {
  @override
  final int typeId = 6;

  @override
  SharingScope read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SharingScope.none;
      case 1:
        return SharingScope.friends;
      case 2:
        return SharingScope.everyone;
      default:
        return SharingScope.none;
    }
  }

  @override
  void write(BinaryWriter writer, SharingScope obj) {
    switch (obj) {
      case SharingScope.none:
        writer.writeByte(0);
        break;
      case SharingScope.friends:
        writer.writeByte(1);
        break;
      case SharingScope.everyone:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SharingScopeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
