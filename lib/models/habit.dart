import 'package:flutter/material.dart';
import 'package:habitur/models/data_point.dart';
import 'package:habitur/constants.dart';

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
  Color color = kPrimaryColor;

  List<DateTime> daysCompleted = [];
  List<String> requiredDatesOfCompletion = [];
  List<DataPoint> completionStats = [];
  List<DataPoint> confidenceStats = [];

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
      this.daysCompleted = const [],
      this.confidenceStats = const [],
      this.completionStats = const [],
      this.requiredCompletions = 1});
}
