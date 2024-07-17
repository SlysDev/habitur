import 'package:flutter/material.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/constants.dart';

class Habit {
  String title;
  int proficiencyRating = 0;
  int streak;
  int requiredCompletions;
  int completionsToday;
  int totalCompletions;
  int highestStreak;
  String resetPeriod;
  DateTime dateCreated;
  double confidenceLevel;
  DateTime lastSeen;
  Color color = kPrimaryColor;
  int id;
  bool isCommunityHabit;

  List<DateTime> daysCompleted = [];
  List<String> requiredDatesOfCompletion = [];
  List<StatPoint> stats = [];

  bool get isCompleted {
    return completionsToday == requiredCompletions;
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
      required this.id,
      required this.lastSeen,
      this.streak = 0,
      this.highestStreak = 0,
      this.completionsToday = 0,
      this.totalCompletions = 0,
      this.confidenceLevel = 0,
      this.requiredDatesOfCompletion = const [],
      this.isCommunityHabit = false,
      this.requiredCompletions = 1});
}
