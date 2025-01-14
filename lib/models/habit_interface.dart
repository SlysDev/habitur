import 'dart:ui';

import 'package:habitur/models/progress.dart';
import 'package:habitur/models/stat_point.dart';

abstract class HabitInterface {
  // Core Identification Properties
  int get id;
  String get title;
  String get description;
  DateTime get dateCreated;
  DateTime get lastSeen;

  // Progress and Performance Tracking
  int get streak;
  int get highestStreak;
  int get currentProgress;
  int get totalProgress;
  int get targetGoal;
  double get confidenceLevel;
  Progress get progress;
  bool get isCompleted;
  double get completionPercentage;

  // Temporal and Scheduling Properties
  String get resetPeriod;
  List<DateTime> get daysCompleted;
  List<String> get requiredDatesOfCompletion;
  List<StatPoint> get stats;

  // Habit Metadata and Configuration
  Color get color;
  bool get smartNotifsEnabled;
  bool get isVisible;
  bool get isCommunityHabit;
  bool get isShared;
  bool get usesMeasurement;
  String get measurementUnit;

  // All Setters

  set lastSeen(DateTime lastSeen);
  set streak(int streak);
  set highestStreak(int highestStreak);
  set currentProgress(int currentProgress);
  set totalProgress(int totalProgress);
  set targetGoal(int targetGoal);
  set confidenceLevel(double confidenceLevel);
  set daysCompleted(List<DateTime> daysCompleted);
  set stats(List<StatPoint> stats);
  set requiredDatesOfCompletion(List<String> requiredDatesOfCompletion);
  set color(Color color);
  set smartNotifsEnabled(bool smartNotifsEnabled);
  set isVisible(bool isVisible);
  set isCommunityHabit(bool isCommunityHabit);
  set isShared(bool isShared);
  set usesMeasurement(bool usesMeasurement);
  set measurementUnit(String measurementUnit);

  // Core Functional Methods
  void incrementProgress([int amount]);
  void decrementProgress([int amount]);
  void resetProgress();

  // Serialization Methods
  Map<String, dynamic> toMap();

  // Optional: Add a custom toString method for debugging
  @override
  String toString();
}
