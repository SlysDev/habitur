import 'package:flutter/material.dart';
import 'package:habitur/providers/leveling_system.dart';
import 'package:provider/provider.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/providers/user_data.dart';
import 'package:intl/intl.dart';

class Habit {
  String title;
  bool isCompleted = false;
  int proficiencyRating = 0;
  int streak = 0;
  List<DateTime> daysCompleted = [];
  int requiredCompletions;
  int completionsToday;
  int totalCompletions;
  List requiredDatesOfCompletion = [];
  String resetPeriod;
  DateTime dateCreated;
  DateTime lastSeen = DateTime.now();
  Color color = kDarkBlue;
  void incrementCompletion(context) {
    completionsToday++;
    totalCompletions++;
    if (completionsToday == requiredCompletions) {
      isCompleted = true;
      Provider.of<UserData>(context, listen: false).addFullHabitCompletion();
      Provider.of<LevelingSystem>(context, listen: false).addHabiturRating();
    }
    daysCompleted.add(DateTime.now());
  }

  void decrementCompletion(context) {
    if (completionsToday == 0) {
      return;
    }
    if (completionsToday == requiredCompletions) {
      isCompleted = false;
      Provider.of<UserData>(context, listen: false).removeFullHabitCompletion();
      Provider.of<LevelingSystem>(context, listen: false).removeHabiturRating();
    }
    completionsToday--;
    totalCompletions--;
  }

  void resetHabitCompletions() {
    completionsToday = 0;
    streak = 0;
  }

  Habit(
      {required this.title,
      required this.dateCreated,
      required this.resetPeriod,
      this.completionsToday = 0,
      required this.lastSeen,
      this.totalCompletions = 0,
      this.requiredDatesOfCompletion = const [],
      this.requiredCompletions = 1});
}
