import 'package:flutter/material.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/habit_interface.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:habitur/services/stats/habit_stats_service.dart';
import 'package:habitur/services/stats/user_stats_service.dart';

/// Coordinates updates between different stats services to maintain consistency
/// and proper order of operations when habits are modified.
class StatsOrchestrationService {
  final _habitStatsService = locator<HabitStatsService>();
  final _userStatsService = locator<UserStatsService>();

  /// Processes all stats updates when a habit is incremented
  Future<HabitInterface> processHabitIncrement({
    required HabitInterface habit,
    required int amount,
    required double difficultyRating,
  }) async {
    debugPrint('Processing habit increment for: \n'
        'Habit: ${habit.title}\n'
        'ID: ${habit.id}\n'
        'Amount: $amount\n'
        'Difficulty Rating: $difficultyRating');
    // First process habit-specific stats
    final HabitInterface updatedHabit =
        await _habitStatsService.processHabitIncrement(
      habit,
      amount: amount,
      difficultyRating: difficultyRating,
    );

    debugPrint('Habit-specific stats processed.');

    // Then update user-level stats
    final habitService = locator<HabitService>();
    final habits = await habitService.getUserHabits();
    debugPrint('Fetched user habits: ${habits.map((h) => h.title).join(', ')}');
    await _userStatsService.logHabitIncrement(habits,
        isCompletion: updatedHabit.isCompleted);
    debugPrint('User stats updated after habit increment.');
    return updatedHabit;
  }

  /// Processes all stats updates when a habit is decremented
  Future<HabitInterface> processHabitDecrement({
    required HabitInterface habit,
    required int amount,
  }) async {
    debugPrint('Processing habit decrement for: \n'
        'Habit: ${habit.title}\n'
        'ID: ${habit.id}\n'
        'Amount: $amount');

    // First process habit-specific stats
    final HabitInterface updatedHabit =
        await _habitStatsService.processHabitDecrement(habit, amount: amount);

    debugPrint('Habit-specific stats processed.');

    // Then update user-level stats
    final habitService = locator<HabitService>();
    final habits = await habitService.getUserHabits();
    debugPrint('Fetched user habits: ${habits.map((h) => h.title).join(', ')}');
    await _userStatsService.unlogHabitIncrement(habits);
    debugPrint('User stats updated after habit decrement.');
    return updatedHabit;
  }
}
