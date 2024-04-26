import 'package:habitur/models/user.dart';

class ParticipantData {
  final User user;
  int completionCount;

  ParticipantData({
    required this.user,
    required this.completionCount,
  });
}
