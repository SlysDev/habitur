import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';

class Habit {
  String title;
  String category;
  bool isCompleted = false;
  int proficiencyRating = 0;
  int streak = 0;
  double difficulty;
  int requiredCompletions;
  int currentCompletions = 0;
  List requiredDatesOfCompletion = [];
  List currentDatesOfCompletion = [];
  Color color = kDarkBlue;
  Habit(
      {required this.title,
      required this.category,
      required this.difficulty,
      this.requiredCompletions = 1});
}
