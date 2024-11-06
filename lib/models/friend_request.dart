import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'friend_request.g.dart';

@HiveType(typeId: 5)
class FriendRequest {
  @HiveField(0)
  String senderUid;

  @HiveField(1)
  String recipientUid;

  @HiveField(2)
  DateTime dateSent;

  @HiveField(3)
  bool isAccepted;

  @HiveField(4)
  DateTime? dateAccepted;

  FriendRequest({
    required this.senderUid,
    required this.recipientUid,
    required this.dateSent,
    this.isAccepted = false,
    this.dateAccepted,
  });

  factory FriendRequest.fromMap(Map<String, dynamic> map) {
    return FriendRequest(
      senderUid: map['senderUid'],
      recipientUid: map['recipientUid'],
      dateSent: (map['dateSent'] as Timestamp).toDate(),
      isAccepted: map['isAccepted'] ?? false,
      dateAccepted: map['dateAccepted'] != null
          ? (map['dateAccepted'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderUid': senderUid,
      'recipientUid': recipientUid,
      'dateSent': dateSent,
      'isAccepted': isAccepted,
      'dateAccepted': dateAccepted,
    };
  }
}
