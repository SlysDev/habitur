import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:intl/intl.dart';

class Habit {
  String title;
  String category;
  bool isCompleted = false;
  int proficiencyRating = 0;
  int streak = 0;
  int requiredCompletions;
  int completionsToday = 0;
  int totalCompletions = 0;
  List requiredDatesOfCompletion = [];
  String resetPeriod;
  DateTime dateCreated;
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
      required this.category,
      required this.dateCreated,
      required this.resetPeriod,
      this.requiredDatesOfCompletion = const [],
      this.requiredCompletions = 1});
}
