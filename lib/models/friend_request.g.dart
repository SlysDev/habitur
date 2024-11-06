// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_request.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FriendRequestAdapter extends TypeAdapter<FriendRequest> {
  @override
  final int typeId = 5;

  @override
  FriendRequest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FriendRequest(
      senderUid: fields[0] as String,
      recipientUid: fields[1] as String,
      dateSent: fields[2] as DateTime,
      isAccepted: fields[3] as bool,
      dateAccepted: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, FriendRequest obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.senderUid)
      ..writeByte(1)
      ..write(obj.recipientUid)
      ..writeByte(2)
      ..write(obj.dateSent)
      ..writeByte(3)
      ..write(obj.isAccepted)
      ..writeByte(4)
      ..write(obj.dateAccepted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendRequestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
