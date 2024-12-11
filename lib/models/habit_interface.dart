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
