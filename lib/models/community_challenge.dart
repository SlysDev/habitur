import 'dart:collection';

import 'package:habitur/models/data_point.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/models/shared_habit.dart';
import 'package:habitur/models/user.dart';

class CommunityChallenge extends SharedHabit {
  String description;
  int id;
  DateTime startDate;
  DateTime endDate;
  int requiredFullCompletions;
  int currentFullCompletions = 0;

  CommunityChallenge({
    required this.description,
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.requiredFullCompletions,
    this.currentFullCompletions = 0,
    required Habit habit,
    List<ParticipantData>? participants,
  }) : super(
          title: habit.title,
          description: description,
          id: id,
          participantData: participants ?? [], // Empty list for participants
          author: null, // Empty list for creators
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
        );
}
