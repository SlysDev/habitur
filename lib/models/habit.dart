import 'package:flutter/material.dart';
import 'package:habitur/providers/leveling_system.dart';
import 'package:habitur/providers/statistics_manager.dart';
import 'package:provider/provider.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/providers/user_data.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class Habit {
  String title;
  bool isCompleted = false;
  int proficiencyRating = 0;
  int streak = 0;
  List<DateTime> daysCompleted = [];
  int requiredCompletions;
  int completionsToday;
  int totalCompletions;
  int highestStreak;
  List requiredDatesOfCompletion = [];
  String resetPeriod;
  DateTime dateCreated;
  double confidenceLevel;
  DateTime lastSeen = DateTime.now();
  Color color = kMainBlue;
  void incrementCompletion(context) {
    completionsToday++;
    totalCompletions++;
    if (completionsToday == requiredCompletions) {
      isCompleted = true;
      Provider.of<StatisticsManager>(context, listen: false)
          .totalHabitsCompleted++;
      Provider.of<LevelingSystem>(context, listen: false).addHabiturRating();
      streak++;
      confidenceLevel = confidenceLevel * pow(1.10, confidenceLevel);
      print(confidenceLevel);
    }
    daysCompleted.add(DateTime.now());
  }

  void decrementCompletion(context) {
    if (completionsToday == 0) {
      return;
    }
    if (completionsToday == requiredCompletions) {
      isCompleted = false;
      Provider.of<StatisticsManager>(context, listen: false)
          .totalHabitsCompleted++;
      Provider.of<LevelingSystem>(context, listen: false).removeHabiturRating();
      streak--;
    }
    completionsToday--;
    totalCompletions--;
  }

  void resetHabitCompletions() {
    completionsToday = 0;
    if (streak > highestStreak) {
      highestStreak = streak;
    }
    streak = 0;
  }

  Habit(
      {required this.title,
      required this.dateCreated,
      required this.resetPeriod,
      this.streak = 0,
      this.highestStreak = 0,
      this.completionsToday = 0,
      required this.lastSeen,
      this.totalCompletions = 0,
      this.confidenceLevel = 1,
      this.requiredDatesOfCompletion = const [],
      this.requiredCompletions = 1});
}
