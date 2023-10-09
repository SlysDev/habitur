import 'package:habitur/models/habit.dart';

class Challenge {
  String name;
  String description;
  List participants;
  List creators;
  List<Habit> habit;
  int id;
  DateTime startDate;
  DateTime endDate;
  Challenge(
      {required this.name,
      required this.description,
      required this.creators,
      required this.participants,
      required this.id,
      required this.startDate,
      required this.endDate,
      required this.habit});
}
