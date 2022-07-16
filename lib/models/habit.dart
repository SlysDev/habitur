import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:intl/intl.dart';

class Habit {
  String title;
  String category;
  bool isCompleted = false;
  int proficiencyRating = 0;
  int streak = 0;
  double difficulty;
  int requiredCompletions;
  int currentCompletions = 0;
  int totalCompletions = 0;
  List requiredDatesOfCompletion = [];
  List currentDatesOfCompletion = [];
  String resetPeriod;
  DateTime dateCreated;
  Color color = kDarkBlue;
  void incrementCompletion() {
    currentCompletions++;
    totalCompletions++;
  }

  void resetHabitCompletions() {
    currentCompletions = 0;
  }

  Habit(
      {required this.title,
      required this.category,
      required this.difficulty,
      required this.dateCreated,
      required this.resetPeriod,
      this.requiredDatesOfCompletion = const [],
      this.requiredCompletions = 1});
}
