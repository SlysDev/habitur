// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 4;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      username: fields[0] as String,
      bio: fields[1] as String,
      email: fields[2] as String,
      uid: fields[3] as String,
      userLevel: fields[4] as int,
      userXP: fields[5] as int,
      isAdmin: fields[6] as bool,
      profilePicture: fields[11] as String?,
      stats: (fields[7] as List?)?.cast<StatPoint>(),
      friends: (fields[8] as List?)?.cast<String>(),
      receivedFriendRequests: (fields[9] as List?)?.cast<FriendRequest>(),
      sentFriendRequests: (fields[10] as List?)?.cast<FriendRequest>(),
      habitVisibilitySettings: (fields[12] as List?)?.cast<HabitVisibility>(),
      privacySettings: fields[13] as PrivacySettings?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.bio)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.uid)
      ..writeByte(4)
      ..write(obj.userLevel)
      ..writeByte(5)
      ..write(obj.userXP)
      ..writeByte(6)
      ..write(obj.isAdmin)
      ..writeByte(7)
      ..write(obj.stats)
      ..writeByte(8)
      ..write(obj.friends)
      ..writeByte(9)
      ..write(obj.receivedFriendRequests)
      ..writeByte(10)
      ..write(obj.sentFriendRequests)
      ..writeByte(11)
      ..write(obj.profilePicture)
      ..writeByte(12)
      ..write(obj.habitVisibilitySettings)
      ..writeByte(13)
      ..write(obj.privacySettings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
