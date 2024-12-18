import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'friend_request.g.dart';

@HiveType(typeId: 8)
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

  @HiveField(5)
  bool isDeclined;

  FriendRequest({
    required this.senderUid,
    required this.recipientUid,
    required this.dateSent,
    this.isAccepted = false,
    this.dateAccepted,
    this.isDeclined = false,
  });

  factory FriendRequest.fromMap(Map<String, dynamic> map) {
    return FriendRequest(
      senderUid: map['senderUid'],
      recipientUid: map['recipientUid'],
      dateSent: map['dateSent'] != null
          ? map['dateSent'] is Timestamp
              ? map['dateSent'].toDate()
              : map['dateSent'] as DateTime
          : null,
      isAccepted: map['isAccepted'] ?? false,
      dateAccepted: map['dateAccepted'] != null
          ? map['dateAccepted'] is Timestamp
              ? map['dateAccepted'].toDate()
              : map['dateAccepted'] as DateTime
          : null,
      isDeclined: map['isDeclined'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderUid': senderUid,
      'recipientUid': recipientUid,
      'dateSent': dateSent,
      'isAccepted': isAccepted,
      'dateAccepted': dateAccepted,
      'isDeclined': isDeclined,
    };
  }

  Map<String, dynamic> toFirebaseMap() {
    Map<String, dynamic> map = toMap();
    map['dateSent'] = Timestamp.fromDate(map['dateSent']);
    if (map['dateAccepted'] != null) {
      map['dateAccepted'] = Timestamp.fromDate(map['dateAccepted']);
    }
    return map;
  }

  bool equals(Map<String, dynamic> other) {
    return senderUid == other['senderUid'] &&
        recipientUid == other['recipientUid'] &&
        dateSent == (other['dateSent'] as Timestamp).toDate() &&
        isAccepted == other['isAccepted'] &&
        dateAccepted ==
            (other['dateAccepted'] != null
                ? (other['dateAccepted'] as Timestamp).toDate()
                : null) &&
        isDeclined == other['isDeclined'];
  }
}
