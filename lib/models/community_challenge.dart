import 'package:habitur/models/challenge.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/participant_data.dart';

class CommunityChallenge extends Challenge {
  String name;
  String description;
  Habit habit;
  int id;
  DateTime startDate;
  DateTime endDate;
  List<ParticipantData> participantData = [];

  CommunityChallenge({
    required this.name,
    required this.description,
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.habit,
  }) : super(
          name: name,
          description: description,
          id: id,
          startDate: startDate,
          endDate: endDate,
          habit: habit,
          participants: [], // Empty list for participants
          creators: [], // Empty list for creators
        );
}
