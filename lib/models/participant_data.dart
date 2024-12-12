import 'package:habitur/models/habit.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/models/user.dart';

class ParticipantData {
  final UserModel user;
  Habit habit;
  ParticipantData({
    required this.user,
    required this.habit,
  });
  factory ParticipantData.fromMap(Map<String, dynamic> map) {
    return ParticipantData(
      user: UserModel.fromMap(map['user']),
      habit: Habit.fromMap(map['habit']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user': user.toMap(),
      'habit': habit.toMap(),
    };
  }
}
