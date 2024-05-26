import 'package:habitur/models/habit.dart';
import 'package:habitur/models/participant_data.dart';

class SharedHabit {
  Habit habit;
  String description;
  List<ParticipantData> participantData = [];
  List creators;
  int id;
  DateTime startDate;
  DateTime endDate;
  SharedHabit({
    required this.habit,
    required this.description,
    required this.creators,
    required this.participantData,
    required this.id,
    required this.startDate,
    required this.endDate,
  });
}
