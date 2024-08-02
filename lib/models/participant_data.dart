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
}
