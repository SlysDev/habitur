import 'package:flutter/material.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/shared_habit.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/database_service.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:stacked/stacked.dart';

class SharedHabitsService with ListenableServiceMixin {
  final _databaseService = locator<DatabaseService>();
  final _userService = locator<UserService>();
  final _habitService = locator<HabitService>();

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
            .any((participant) => participant.user.uid == currentUser.uid);

        if (!isParticipant) {
          sharedHabit.participantData.add(
            ParticipantData(
              user: currentUser,
              fullCompletionCount: 0,
              lastSeen: DateTime.now(),
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
      // Update in database
      await _databaseService.updateSharedHabit(sharedHabit);

      // Update local list
      final index = _sharedHabits.indexWhere((h) => h.id == sharedHabit.id);
      if (index != -1) {
        _sharedHabits[index] = sharedHabit;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating shared habit: $e');
      rethrow;
    }
  }

  Future<void> deleteSharedHabit(String habitId) async {
    try {
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

  Future<void> updateParticipantProgress(
    SharedHabit sharedHabit,
    String userId,
    int completions,
  ) async {
    try {
      final participantIndex =
          sharedHabit.participantData.indexWhere((p) => p.user.uid == userId);

      if (participantIndex != -1) {
        // Update participant data
        sharedHabit.participantData[participantIndex].currentCompletions =
            completions;
        sharedHabit.participantData[participantIndex].lastSeen = DateTime.now();

        if (completions >= sharedHabit.targetGoal) {
          sharedHabit.participantData[participantIndex].fullCompletionCount++;
        }

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

      // Create participant data for all selected participants
      final participantData = participants
          .map((user) => ParticipantData(
                user: user,
                fullCompletionCount: 0,
                lastSeen: DateTime.now(),
                habit: habit
              ))
          .toList();

      // Add current user as a participant if not already included
      final isCurrentUserIncluded = participantData
          .any((participant) => participant.user.uid == currentUser.uid);
      if (!isCurrentUserIncluded) {
        participantData.add(
          ParticipantData(
            user: currentUser,
            fullCompletionCount: 0,
            lastSeen: DateTime.now(),
            habit: habit
          ),
        );
      }

      // Create a shared habit from the existing habit
      final sharedHabit = SharedHabit(
        title: habit.title,
        description: habit.description,
        participantData: participantData,
        author: currentUser,
        id: DateTime.now().millisecondsSinceEpoch,
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
