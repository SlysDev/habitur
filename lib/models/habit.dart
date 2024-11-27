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
  int targetGoal;
  @HiveField(4)
  int currentProgress;
  @HiveField(5)
  int totalProgress;
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
  List<StatPoint> stats = [];
  @HiveField(14)
  bool smartNotifsEnabled;

  @HiveField(15)
  bool isVisible;

  bool get isCompleted {
    return currentProgress == targetGoal;
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

  Habit({
    required this.title,
    required this.dateCreated,
    required this.resetPeriod,
    required this.id,
    required this.lastSeen,
    this.streak = 0,
    this.highestStreak = 0,
    this.currentProgress = 0,
    this.totalProgress = 0,
    this.confidenceLevel = 0,
    this.requiredDatesOfCompletion = const [],
    this.isCommunityHabit = false,
    this.smartNotifsEnabled = false,
    this.isVisible = true, // Default to true for backward compatibility
    this.targetGoal = 1,
  }) {
    daysCompleted = [];
    stats = [];
    color = kPrimaryColor;
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dateCreated': dateCreated,
      'resetPeriod': resetPeriod,
      'id': id,
      'lastSeen': lastSeen,
      'streak': streak,
      'highestStreak': highestStreak,
      'currentProgress': currentProgress,
      'totalProgress': totalProgress,
      'confidenceLevel': confidenceLevel,
      'requiredDatesOfCompletion': requiredDatesOfCompletion,
      'isCommunityHabit': isCommunityHabit,
      'smartNotifsEnabled': smartNotifsEnabled,
      'isVisible': isVisible,
      'targetGoal': targetGoal,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      title: map['title'] as String? ?? '',
      dateCreated: (map['dateCreated'] as DateTime?) ?? DateTime.now(),
      resetPeriod: (map['resetPeriod'] as String?)?.toLowerCase() ?? 'daily',
      id: map['id'] as int? ?? 0,
      lastSeen: (map['lastSeen'] as DateTime?) ?? DateTime.now(),
      streak: map['streak'] as int? ?? 0,
      highestStreak: map['highestStreak'] as int? ?? 0,
      currentProgress: map['currentProgress'] as int? ?? 0,
      totalProgress: map['totalProgress'] as int? ?? 0,
      confidenceLevel: (map['confidenceLevel'] as num?)?.toDouble() ?? 0.0,
      requiredDatesOfCompletion:
          (map['requiredDatesOfCompletion'] as List<String>?) ?? [],
      isCommunityHabit: map['isCommunityHabit'] as bool? ?? false,
      smartNotifsEnabled: map['smartNotifsEnabled'] as bool? ?? false,
      isVisible: map['isVisible'] as bool? ??
          true, // Default to true for backward compatibility
      targetGoal: map['targetGoal'] as int? ?? 1,
    );
  }

  Habit copyWith({
    String? title,
    int? proficiencyRating,
    int? streak,
    int? targetGoal,
    int? currentProgress,
    int? totalProgress,
    int? highestStreak,
    String? resetPeriod,
    DateTime? dateCreated,
    double? confidenceLevel,
    DateTime? lastSeen,
    Color? color,
    int? id,
    bool? isCommunityHabit,
    bool? smartNotifsEnabled,
    bool? isVisible,
    List<DateTime>? daysCompleted,
    List<String>? requiredDatesOfCompletion,
    List<StatPoint>? stats,
  }) {
    return Habit(
      title: title ?? this.title,
      dateCreated: dateCreated ?? this.dateCreated,
      resetPeriod: resetPeriod ?? this.resetPeriod,
      id: id ?? this.id,
      lastSeen: lastSeen ?? this.lastSeen,
      streak: streak ?? this.streak,
      highestStreak: highestStreak ?? this.highestStreak,
      currentProgress: currentProgress ?? this.currentProgress,
      totalProgress: totalProgress ?? this.totalProgress,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      requiredDatesOfCompletion:
          requiredDatesOfCompletion ?? this.requiredDatesOfCompletion,
      isCommunityHabit: isCommunityHabit ?? this.isCommunityHabit,
      smartNotifsEnabled: smartNotifsEnabled ?? this.smartNotifsEnabled,
      isVisible: isVisible ?? this.isVisible,
      targetGoal: targetGoal ?? this.targetGoal,
    )
      ..color = color ?? this.color
      ..daysCompleted = daysCompleted ?? this.daysCompleted
      ..stats = stats ?? this.stats;
  }
}
