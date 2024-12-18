import 'package:flutter/material.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/shared_habit.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/database_service.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:habitur/services/stats/stats_orchestration_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:stacked/stacked.dart';

class SharedHabitsService with ListenableServiceMixin {
  final _databaseService = locator<DatabaseService>();
  final _userService = locator<UserService>();
  final _habitService = locator<HabitService>();
  final _statsOrchestrationService = locator<StatsOrchestrationService>();

  List<SharedHabit> _sharedHabits = [];
  List<SharedHabit> get sharedHabits => _sharedHabits;

  SharedHabitsService() {
    listenToReactiveValues([]);
  }

  Future<List<SharedHabit>> getSharedHabits() async {
    try {
      final userId = _userService.currentUser?.uid;
      if (userId == null) return [];

      // Get shared habits where the current user is a participant
      final sharedHabitsData = await _databaseService.getSharedHabits(userId);
      _sharedHabits = sharedHabitsData;

      notifyListeners();
      return _sharedHabits;
    } catch (e) {
      // Log error and return empty list
      print('Error fetching shared habits: $e');
      return [];
    }
  }

  Future<void> createSharedHabit(SharedHabit sharedHabit) async {
    try {
      // Add current user as a participant if not already included
      final currentUser = _userService.currentUser;
      if (currentUser != null) {
        final isParticipant = sharedHabit.participantData
            .any((participant) => participant.userId == currentUser.uid);

        if (!isParticipant) {
          sharedHabit.participantData.add(
            ParticipantData(
              username: currentUser.username,
              userId: currentUser.uid,
              habit: Habit.fromSharedHabit(sharedHabit),
            ),
          );
        }
        // Set hasSharedHabits to true
        if (currentUser.hasSharedHabits == false) {
          currentUser.hasSharedHabits = true;
          await _userService.updateUser(currentUser);
        }
      }

      await _habitService.addHabit(sharedHabit);
      // Save to database
      await _databaseService.createSharedHabit(sharedHabit);

      // Update local list
      _sharedHabits.add(sharedHabit);
      notifyListeners();
    } catch (e) {
      // Log error and rethrow
      print('Error creating shared habit: $e');
      rethrow;
    }
  }

  Future<void> updateSharedHabit(SharedHabit sharedHabit) async {
    try {
      debugPrint('Updating shared habit in database: ${sharedHabit.toMap()}');
      // Update in database
      await _databaseService.updateSharedHabit(sharedHabit);

      // Update local list
      await _habitService.updateHabit(sharedHabit);
      final index = _sharedHabits.indexWhere((h) => h.id == sharedHabit.id);
      if (index != -1) {
        _sharedHabits[index] = sharedHabit;
        notifyListeners();
        debugPrint('Shared habit updated in local list');
      }
    } catch (e) {
      debugPrint('Error updating shared habit: $e');
      print('Error updating shared habit: $e');
      rethrow;
    }
  }

  Future<void> deleteSharedHabit(String habitId) async {
    try {
      await _habitService.deleteHabit(habitId);
      // Delete from database
      await _databaseService.deleteSharedHabit(habitId);

      // Remove from local list
      _sharedHabits.removeWhere((h) => h.id == habitId);
      notifyListeners();
    } catch (e) {
      print('Error deleting shared habit: $e');
      rethrow;
    }
  }

  Future<void> incrementHabit(String habitId, double difficultyRating,
      {int amount = 1}) async {
    try {
      debugPrint('Incrementing shared habit with ID: $habitId');
      final sharedHabit = await getSharedHabitById(int.parse(habitId));
      if (sharedHabit == null) return;

      final currentUser = _userService.currentUser;
      if (currentUser == null) return;

      final participantIndex = sharedHabit.participantData
          .indexWhere((p) => p.userId == currentUser.uid);
      if (participantIndex == -1) return;

      final participantHabitData =
          sharedHabit.participantData[participantIndex].habit;

      _statsOrchestrationService.processHabitIncrement(
          habit: participantHabitData,
          amount: amount,
          difficultyRating: difficultyRating);
      debugPrint('Habit incremented in stats service');

      // Update participant data
      await updateParticipantProgress(
          sharedHabit, currentUser.uid, participantHabitData);
      debugPrint('Participant progress updated');

      // Save changes
      await updateSharedHabit(sharedHabit);
      debugPrint('Shared habit updated in database');
    } catch (e) {
      debugPrint('Error incrementing habit: $e');
      print('Error incrementing habit: $e');
      rethrow;
    }
  }

  Future<void> decrementHabit(String habitId, {int amount = 1}) async {
    try {
      final sharedHabit = await getSharedHabitById(int.parse(habitId));
      if (sharedHabit == null) return;

      final currentUser = _userService.currentUser;
      if (currentUser == null) return;

      final participantIndex = sharedHabit.participantData
          .indexWhere((p) => p.userId == currentUser.uid);
      if (participantIndex == -1) return;

      final participantHabitData =
          sharedHabit.participantData[participantIndex].habit;

      // Use HabitStatsService to handle the decrement
      _statsOrchestrationService.processHabitDecrement(
          habit: participantHabitData, amount: amount);

      // Update participant data
      await updateParticipantProgress(
          sharedHabit, currentUser.uid, participantHabitData);

      // Save changes
      await updateSharedHabit(sharedHabit);
    } catch (e) {
      print('Error decrementing shared habit: $e');
      rethrow;
    }
  }

  Future<void> updateParticipantProgress(
    SharedHabit sharedHabit,
    String userId,
    Habit participantHabitData,
  ) async {
    try {
      final participantIndex =
          sharedHabit.participantData.indexWhere((p) => p.userId == userId);

      if (participantIndex != -1) {
        // Update participant data
        sharedHabit.participantData[participantIndex].habit =
            participantHabitData;

        // Save changes
        await updateSharedHabit(sharedHabit);
      }
    } catch (e) {
      print('Error updating participant progress: $e');
      rethrow;
    }
  }

  Future<SharedHabit?> getSharedHabitById(int habitId) async {
    try {
      // First check local list
      final localHabit = _sharedHabits.firstWhere(
        (h) => h.id == habitId,
        orElse: () => throw StateError('Not found in local cache'),
      );
      return localHabit;
    } catch (_) {
      // If not in local list, fetch from database
      try {
        final habit =
            await _databaseService.getSharedHabitById(habitId.toString());
        if (habit != null) {
          // Update local list if found
          final index = _sharedHabits.indexWhere((h) => h.id == habitId);
          if (index != -1) {
            _sharedHabits[index] = habit;
          } else {
            _sharedHabits.add(habit);
          }
          notifyListeners();
        }
        return habit;
      } catch (e) {
        print('Error fetching shared habit by id: $e');
        return null;
      }
    }
  }

  Future<SharedHabit?> convertHabitToSharedHabit(
      Habit habit, List<UserModel> participants) async {
    try {
      final currentUser = _userService.currentUser;
      if (currentUser == null) return null;

      // update last seen just in case
      habit.lastSeen = DateTime.now();

      // Create participant data for all selected participants
      final participantData = participants
          .map((user) => ParticipantData(
              username: user.username, userId: user.uid, habit: habit))
          .toList();

      // Add current user as a participant if not already included
      final isCurrentUserIncluded = participantData
          .any((participant) => participant.userId == currentUser.uid);
      if (!isCurrentUserIncluded) {
        participantData.add(
          ParticipantData(
              username: currentUser.username,
              userId: currentUser.uid,
              habit: habit),
        );
      }

      // Create a shared habit from the existing habit
      final sharedHabit = SharedHabit(
        title: habit.title,
        description: habit.description,
        participantData: participantData,
        author: currentUser,
        id: habit.id,
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

      await _habitService.updateHabit(sharedHabit);
      // Save the shared habit to the database
      await _databaseService.createSharedHabit(sharedHabit);

      // Optionally, you might want to mark the original habit as a community habit
      habit.isShared = true;

      habit = sharedHabit;

      // Set hasSharedHabits to true
      if (currentUser.hasSharedHabits == false) {
        currentUser.hasSharedHabits = true;
        await _userService.updateUser(currentUser);
      }
      return sharedHabit;
    } catch (e, s) {
      debugPrint('Error converting habit to shared habit: $e');
      debugPrint('$s');
      return null;
    }
  }
}
