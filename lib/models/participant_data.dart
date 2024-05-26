import 'package:habitur/models/user.dart';

class ParticipantData {
  final UserModel user;
  int fullCompletionCount;
  int currentCompletions;
  ParticipantData({
    required this.user,
    required this.fullCompletionCount,
    this.currentCompletions = 0,
  });
}
