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
      Provider.of<StatisticsManager>(context, listen: false)
          .recordConfidenceLevel(context);
      print('habit incremented');
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
          .totalHabitsCompleted--;
      confidenceLevel = confidenceLevel * pow(0.90, confidenceLevel);
      Provider.of<StatisticsManager>(context, listen: false)
          .recordConfidenceLevel(context);
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

  double get completionRate {
    if (daysCompleted.isEmpty) {
      return 0.0;
    }

    double rate =
        daysCompleted.length / DateTime.now().difference(dateCreated).inDays;

    // Handle the case where the completion rate is greater than 1 (100%)
    return rate > 1.0 ? 1.0 : rate;
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
