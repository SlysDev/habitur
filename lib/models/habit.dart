import 'package:flutter/material.dart';
import 'package:habitur/models/data_point.dart';
import 'package:habitur/providers/leveling_system.dart';
import 'package:habitur/modules/statistics_manager.dart';
import 'package:habitur/providers/summary_statistics_repository.dart';
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
  int requiredCompletions;
  int completionsToday;
  int totalCompletions;
  int highestStreak;
  String resetPeriod;
  DateTime dateCreated;
  double confidenceLevel;
  DateTime lastSeen = DateTime.now();
  Color color = kMainBlue;

  List<DateTime> daysCompleted = [];
  List requiredDatesOfCompletion = [];
  List<DataPoint> confidenceStats = [];
  List<DataPoint> completionStats = [];

  void incrementCompletion(context) {
    StatisticsManager statsManager = StatisticsManager();
    completionsToday++;
    totalCompletions++;
    if (completionsToday == requiredCompletions) {
      isCompleted = true;
      Provider.of<SummaryStatisticsRepository>(context, listen: false)
          .totalHabitsCompleted++;
      Provider.of<LevelingSystem>(context, listen: false).addHabiturRating();
      streak++;
      confidenceLevel = confidenceLevel * pow(1.10, confidenceLevel);
      statsManager.recordConfidenceLevel(context);
    }
    daysCompleted.add(DateTime.now());
  }

  void decrementCompletion(context) {
    StatisticsManager statsManager = StatisticsManager();
    if (completionsToday == 0) {
      return;
    }
    if (completionsToday == requiredCompletions) {
      isCompleted = false;
      Provider.of<SummaryStatisticsRepository>(context, listen: false)
          .totalHabitsCompleted--;
      confidenceLevel = confidenceLevel * pow(0.90, confidenceLevel);
      statsManager.recordConfidenceLevel(context);
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
      this.confidenceStats = const [],
      this.completionStats = const [],
      this.requiredCompletions = 1});
}
