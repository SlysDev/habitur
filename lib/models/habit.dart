import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/providers/user_data.dart';
import 'package:intl/intl.dart';

class Habit {
  String title;
  bool isCompleted = false;
  int proficiencyRating = 0;
  int streak = 0;
  int requiredCompletions;
  int completionsToday;
  int totalCompletions = 0;
  List requiredDatesOfCompletion = [];
  String resetPeriod;
  DateTime dateCreated;
  var lastCompleted;
  DateTime lastSeen = DateTime.now();
  Color color = kDarkBlue;
  void incrementCompletion(context) {
    completionsToday++;
    totalCompletions++;
    if (completionsToday == requiredCompletions) {
      isCompleted = true;
      Provider.of<UserData>(context, listen: false).addFullHabitCompletion();
      Provider.of<UserData>(context, listen: false).addHabiturRating();
    }
  }

  void decrementCompletion(context) {
    if (completionsToday == requiredCompletions) {
      isCompleted = false;
      Provider.of<UserData>(context, listen: false).removeFullHabitCompletion();
      Provider.of<UserData>(context, listen: false).removeHabiturRating();
    }
    completionsToday--;
    totalCompletions--;
  }

  void resetHabitCompletions() {
    completionsToday = 0;
  }

  Habit(
      {required this.title,
      required this.dateCreated,
      required this.resetPeriod,
      this.lastCompleted = '',
      this.completionsToday = 0,
      required this.lastSeen,
      this.requiredDatesOfCompletion = const [],
      this.requiredCompletions = 1});
}
