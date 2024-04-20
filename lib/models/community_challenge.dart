import 'package:habitur/models/data_point.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/models/shared_habit.dart';

class CommunityChallenge extends SharedHabit {
  String description;
  int id;
  DateTime startDate;
  DateTime endDate;
  int requiredFullCompletions;
  int currentFullCompletions = 0;
  List<ParticipantData> participantData = [];

  void checkFullCompletion() {
    if (habit.isCompleted == true) {
      currentFullCompletions++;
    }
  }

  void decrementFullCompletion() {
    currentFullCompletions--;
  }

  CommunityChallenge({
    required this.description,
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.requiredFullCompletions,
    this.currentFullCompletions = 0,
    required String title,
    required Habit habit,
  }) : super(
          description: description,
          id: id,
          startDate: startDate,
          endDate: endDate,
          participantData: [], // Empty list for participants
          creators: [], // Empty list for creators
          habit: habit,
        );
}
