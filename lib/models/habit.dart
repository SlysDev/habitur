import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
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
  void incrementCompletion() {
    completionsToday++;
    totalCompletions++;
  }

  void decrementCompletion() {
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
      this.completionsToday = 0,
      // this.lastSeen,
      this.requiredDatesOfCompletion = const [],
      this.requiredCompletions = 1});
}
