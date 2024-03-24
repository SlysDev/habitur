import 'package:habitur/models/user.dart';

class ParticipantData {
  final User user;
  final int completionCount;

  ParticipantData({
    required this.user,
    required this.completionCount,
  });
}
