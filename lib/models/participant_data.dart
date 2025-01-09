import 'package:habitur/models/habit.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/models/user.dart';
import 'package:hive/hive.dart';

part 'participant_data.g.dart';

@HiveType(typeId: 10)
class ParticipantData {
  @HiveField(0)
  final String username;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  Habit habit;

  ParticipantData({
    required this.username,
    required this.userId,
    required this.habit,
  });

  factory ParticipantData.fromMap(Map<String, dynamic> map) {
    return ParticipantData(
      username: map['username'],
      userId: map['userId'],
      habit: Habit.fromMap(map['habit']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'userId': userId,
      'habit': habit.toMap(),
    };
  }
}

// Generate the adapter using the command:
// flutter packages pub run build_runner build
