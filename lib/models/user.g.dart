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
      profilePicture: fields[4] as AssetImage,
      userLevel: fields[5] as int,
      userXP: fields[6] as int,
      stats: (fields[8] as List).cast<StatPoint>(),
      isAdmin: fields[7] as bool,
      friends: (fields[9] as List).cast<String>(),
      receivedFriendRequests: (fields[10] as List).cast<FriendRequest>(),
      sentFriendRequests: (fields[11] as List).cast<FriendRequest>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.bio)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.uid)
      ..writeByte(4)
      ..write(obj.profilePicture)
      ..writeByte(5)
      ..write(obj.userLevel)
      ..writeByte(6)
      ..write(obj.userXP)
      ..writeByte(7)
      ..write(obj.isAdmin)
      ..writeByte(8)
      ..write(obj.stats)
      ..writeByte(9)
      ..write(obj.friends)
      ..writeByte(10)
      ..write(obj.receivedFriendRequests)
      ..writeByte(11)
      ..write(obj.sentFriendRequests);
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
