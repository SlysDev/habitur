import 'package:flutter/material.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/constants.dart';
import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit {
  @HiveField(0)
  String title;
  @HiveField(1)
  int proficiencyRating = 0;
  @HiveField(2)
  int streak;
  @HiveField(3)
  int requiredCompletions;
  @HiveField(4)
  int completionsToday;
  @HiveField(5)
  int totalCompletions;
  @HiveField(6)
  int highestStreak;
  @HiveField(7)
  String resetPeriod;
  @HiveField(8)
  DateTime dateCreated;
  @HiveField(9)
  double confidenceLevel;
  @HiveField(10)
  DateTime lastSeen;
  Color color = kPrimaryColor;
  @HiveField(11)
  int id;
  bool isCommunityHabit;

  @HiveField(12)
  List<DateTime> daysCompleted = [];
  @HiveField(13)
  List<String> requiredDatesOfCompletion = [];
  @HiveField(14)
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
