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
      email: fields[2] as String,
      uid: fields[3] as String,
      bio: fields[1] == null ? '' : fields[1] as String,
      userLevel: fields[4] == null ? 1 : fields[4] as int,
      userXP: fields[5] == null ? 0 : fields[5] as int,
      isAdmin: fields[6] == null ? false : fields[6] as bool,
      stats: fields[7] == null ? [] : (fields[7] as List).cast<StatPoint>(),
      friends: fields[8] == null ? [] : (fields[8] as List).cast<String>(),
      receivedFriendRequests:
          fields[9] == null ? [] : (fields[9] as List).cast<FriendRequest>(),
      sentFriendRequests:
          fields[10] == null ? [] : (fields[10] as List).cast<FriendRequest>(),
      profilePicture: fields[11] as String?,
      habitVisibilitySettings: (fields[12] as List).cast<HabitVisibility>(),
      isBlocked: fields[14] == null ? false : fields[14] as bool,
      blockedAt: fields[15] as DateTime?,
      blockReason: fields[16] as String?,
      hasSharedHabits: fields[17] == null ? false : fields[17] as bool,
      privacySettings: fields[13] as PrivacySettings,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(18)
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
      ..write(obj.privacySettings)
      ..writeByte(14)
      ..write(obj.isBlocked)
      ..writeByte(15)
      ..write(obj.blockedAt)
      ..writeByte(16)
      ..write(obj.blockReason)
      ..writeByte(17)
      ..write(obj.hasSharedHabits);
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
