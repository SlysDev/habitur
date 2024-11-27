import 'package:habitur/models/user.dart';

class ParticipantData {
  final UserModel user;
  int fullCompletionCount;
  int currentCompletions;
  DateTime lastSeen;
  ParticipantData({
    required this.user,
    required this.fullCompletionCount,
    required this.lastSeen,
    this.currentCompletions = 0,
  });
  factory ParticipantData.fromMap(Map<String, dynamic> map) {
    return ParticipantData(
      user: UserModel.fromMap(map['user']),
      fullCompletionCount: map['fullCompletionCount'],
      currentCompletions: map['currentCompletions'],
      lastSeen: DateTime.parse(map['lastSeen']).toLocal(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user': user.toMap(),
      'fullCompletionCount': fullCompletionCount,
      'currentCompletions': currentCompletions,
      'lastSeen': lastSeen.toIso8601String(),
    };
  }
}
