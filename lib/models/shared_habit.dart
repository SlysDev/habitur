import 'package:habitur/models/stat_point.dart';
import 'package:hive/hive.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/models/habit_interface.dart';

part 'shared_habit.g.dart';

@HiveType(typeId: 2)
class SharedHabit extends Habit implements HabitInterface {
  @HiveField(19)
  List<ParticipantData> participantData = [];

  @HiveField(20)
  UserModel? author;

  SharedHabit({
    required super.title,
    required super.id,
    String? description,
    int? targetGoal,
    this.author,
    List<ParticipantData>? participantData,
    // Inherit all other Habit constructor parameters
    int streak = 0,
    int currentProgress = 0,
    int totalProgress = 0,
    int highestStreak = 0,
    String resetPeriod = 'daily',
    DateTime? dateCreated,
    double confidenceLevel = 0,
    DateTime? lastSeen,
    List<DateTime>? daysCompleted,
    List<String>? requiredDatesOfCompletion,
    bool smartNotifsEnabled = false,
  })  : participantData = participantData ?? [],
        super(
          description: description ?? '',
          targetGoal: targetGoal ?? 1,
          streak: streak,
          currentProgress: currentProgress,
          totalProgress: totalProgress,
          highestStreak: highestStreak,
          resetPeriod: resetPeriod,
          dateCreated: dateCreated ?? DateTime.now(),
          confidenceLevel: confidenceLevel,
          lastSeen: lastSeen ?? DateTime.now(),
          requiredDatesOfCompletion: requiredDatesOfCompletion ?? [],
          smartNotifsEnabled: smartNotifsEnabled,
          isShared: true,
        );

  factory SharedHabit.fromMap(Map<String, dynamic> map) {
    // Convert the map to a Habit first, then create a SharedHabit
    final habit = Habit.fromMap(map);
    return SharedHabit(
      title: habit.title,
      id: habit.id,
      description: habit.description,
      targetGoal: habit.targetGoal,
      streak: habit.streak,
      currentProgress: habit.currentProgress,
      totalProgress: habit.totalProgress,
      highestStreak: habit.highestStreak,
      resetPeriod: habit.resetPeriod,
      dateCreated: habit.dateCreated,
      confidenceLevel: habit.confidenceLevel,
      lastSeen: habit.lastSeen,
      daysCompleted: habit.daysCompleted,
      requiredDatesOfCompletion: habit.requiredDatesOfCompletion,
      smartNotifsEnabled: habit.smartNotifsEnabled,
      participantData: (map['participantData'] as List?)
              ?.map((e) => ParticipantData.fromMap(e))
              .toList() ??
          [],
      author: map['author'] != null ? UserModel.fromMap(map['author']) : null,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    // Get the base Habit map and add SharedHabit-specific fields
    final habitMap = super.toMap();
    habitMap.addAll({
      'participantData': participantData.map((e) => e.toMap()).toList(),
      'author': author?.toMap(),
    });
    return habitMap;
  }

  // Additional methods specific to SharedHabit
  int get totalGroupCompletions => participantData.fold(
      0, (sum, participant) => sum + participant.habit.totalProgress);

  int get highestGroupStreak => participantData.fold(
      0,
      (max, participant) => participant.habit.totalProgress > max
          ? participant.habit.totalProgress
          : max);

  int get totalActiveDays => participantData.fold(
      0, (sum, participant) => sum + participant.habit.totalProgress);

  // Method to add a new participant
  void addParticipant(UserModel user) {
    if (!participantData.any((p) => p.user.uid == user.uid)) {
      participantData
          .add(ParticipantData(user: user, habit: Habit.fromSharedHabit(this)));
    }
  }

  // Method to remove a participant
  void removeParticipant(UserModel user) {
    participantData.removeWhere((p) => p.user.uid == user.uid);
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

    return '-SharedHabit{\n'
        '--- title: $title,\n'
        '--- dateCreated: $dateCreated,\n'
        '--- resetPeriod: $resetPeriod,\n'
        '--- id: $id,\n'
        '--- lastSeen: $lastSeen,\n'
        '--- streak: $streak,\n'
        '--- highestStreak: $highestStreak,\n'
        '--- currentProgress: $currentProgress,\n'
        '--- totalProgress: $totalProgress,\n'
        '--- confidenceLevel: $confidenceLevel,\n'
        '--- requiredDatesOfCompletion: $requiredDatesOfCompletion,\n'
        '--- isCommunityHabit: $isCommunityHabit,\n'
        '--- smartNotifsEnabled: $smartNotifsEnabled,\n'
        '--- isVisible: $isVisible,\n'
        '--- targetGoal: $targetGoal,\n'
        '--- color: $color,\n'
        '--- daysCompleted: $daysCompleted,\n'
        '--- stats: $statsBuffer\n'
        '}';
  }
}
