import 'dart:math';

import 'package:flutter/material.dart';
import 'package:habitur/models/data_point.dart';
import 'package:habitur/modules/statistics_recorder.dart';
import 'package:habitur/providers/summary_statistics_repository.dart';
import 'package:provider/provider.dart';
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
  DateTime lastSeen;
  Color color = kPrimaryColor;
  int id;

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

  double get confidenceChange {
    if (confidenceStats.length < 2) return 0.0;
    return confidenceStats.last.value -
        confidenceStats[confidenceStats.length - 2].value;
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
      this.confidenceLevel = 1,
      this.requiredDatesOfCompletion = const [],
      this.requiredCompletions = 1});
}
