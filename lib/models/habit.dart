import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/models/progress.dart';
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
  @HiveField(16, defaultValue: [])
  List<StatPoint> stats = [];
  @HiveField(14)
  bool smartNotifsEnabled;

  @HiveField(15)
  bool isVisible;

  /// Gets the current progress state of the habit
  Progress get progress =>
      Progress(current: currentProgress, target: targetGoal);

  /// Updates the current progress state of the habit
  set progress(Progress newProgress) {
    currentProgress = newProgress.current;
    targetGoal = newProgress.target;
  }

  bool get isCompleted => progress.isComplete;

  /// Gets the completion percentage of the habit (0.0 to 1.0)
  double get completionPercentage => progress.percentage;

  /// Increments the habit's progress by the specified amount
  void incrementProgress([int amount = 1]) {
    progress = progress.increment(amount: amount);
  }

  /// Decrements the habit's progress by the specified amount
  void decrementProgress([int amount = 1]) {
    progress = progress.decrement(amount: amount);
  }

  /// Resets the habit's progress to zero
  void resetProgress() {
    progress = progress.reset();
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
      'stats': stats.map((stat) => stat.toMap()).toList(),
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
    List<String> parseRequiredDates(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((item) => item.toString()).toList();
      }
      return [];
    }

    Habit habit = Habit(
      title: map['title'] as String? ?? '',
      dateCreated: map['dateCreated'] is Timestamp
          ? (map['dateCreated'] as Timestamp).toDate()
          : (map['dateCreated'] as DateTime?) ?? DateTime.now(),
      resetPeriod: (map['resetPeriod'] as String?)?.toLowerCase() ?? 'daily',
      id: map['id'] as int? ?? 0,
      lastSeen: map['lastSeen'] is Timestamp
          ? (map['lastSeen'] as Timestamp).toDate()
          : (map['lastSeen'] as DateTime?) ?? DateTime.now(),
      streak: map['streak'] as int? ?? 0,
      highestStreak: map['highestStreak'] as int? ?? 0,
      currentProgress: map['currentProgress'] as int? ?? 0,
      totalProgress: map['totalProgress'] as int? ?? 0,
      confidenceLevel: (map['confidenceLevel'] as num?)?.toDouble() ?? 0.0,
      requiredDatesOfCompletion:
          parseRequiredDates(map['requiredDatesOfCompletion']),
      isCommunityHabit: map['isCommunityHabit'] as bool? ?? false,
      smartNotifsEnabled: map['smartNotifsEnabled'] as bool? ?? false,
      isVisible: map['isVisible'] as bool? ?? true,
      targetGoal: map['targetGoal'] as int? ?? 1,
    );
    habit.stats = (map['stats'] as List?)
            ?.map((stat) => StatPoint.fromMap(stat))
            .toList() ??
        [];
    habit.daysCompleted = (map['daysCompleted'] as List<DateTime>);

    return habit;
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

  @override
  String toString() {
    StringBuffer statsBuffer = StringBuffer();
    for (var stat in stats) {
      statsBuffer.writeln('${stat.date}: {');
      statsBuffer.writeln('  completions: ${stat.completions}');
      statsBuffer.writeln('  consistencyFactor: ${stat.consistencyFactor}');
      statsBuffer.writeln('  confidenceLevel: ${stat.confidenceLevel}');
      statsBuffer.writeln('  streak: ${stat.streak}');
      statsBuffer.writeln('  difficultyRating: ${stat.difficultyRating}');
      statsBuffer.writeln('  slopeCompletions: ${stat.slopeCompletions}');
      statsBuffer
          .writeln('  slopeConfidenceLevel: ${stat.slopeConfidenceLevel}');
      statsBuffer.writeln('  slopeConsistency: ${stat.slopeConsistency}');
      statsBuffer
          .writeln('  slopeDifficultyRating: ${stat.slopeDifficultyRating}');
      statsBuffer.writeln('}');
    }

    return 'Habit{\n'
        'title: $title,\n'
        'dateCreated: $dateCreated,\n'
        'resetPeriod: $resetPeriod,\n'
        'id: $id,\n'
        'lastSeen: $lastSeen,\n'
        'streak: $streak,\n'
        'highestStreak: $highestStreak,\n'
        'currentProgress: $currentProgress,\n'
        'totalProgress: $totalProgress,\n'
        'confidenceLevel: $confidenceLevel,\n'
        'requiredDatesOfCompletion: $requiredDatesOfCompletion,\n'
        'isCommunityHabit: $isCommunityHabit,\n'
        'smartNotifsEnabled: $smartNotifsEnabled,\n'
        'isVisible: $isVisible,\n'
        'targetGoal: $targetGoal,\n'
        'color: $color,\n'
        'daysCompleted: $daysCompleted,\n'
        'stats: $statsBuffer\n'
        '}';
  }
}
