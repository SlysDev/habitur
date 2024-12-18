import 'package:flutter/material.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/enums/activity_type.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/progress.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/services/activity_service.dart';
import 'package:habitur/services/auth_service.dart';
import 'package:habitur/services/database_service.dart';
import 'package:habitur/services/local_storage_service.dart';
import 'package:habitur/services/stats/stats_calculation_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:habitur/util_functions.dart';
import 'dart:math' as math;

class HabitStatsService {
  final _localStorageService = locator<LocalStorageService>();
  final _databaseService = locator<DatabaseService>();
  final _authService = locator<AuthService>();
  final _statsCalculationService = locator<StatsCalculationService>();
  final _activityService = locator<ActivityService>();
  final _userService = locator<UserService>();

  Future<void> processHabitIncrement(
    Habit habit, {
    required int amount,
    required double difficultyRating,
  }) async {
    // Update habit stats
    habit.incrementProgress(amount);

    // If habit is completed, update streak
    if (habit.isCompleted) {
      habit.streak = math.max(0, habit.streak + 1);
      habit.highestStreak = math.max(habit.streak, habit.highestStreak);
      habit.daysCompleted.add(simplifyDateIntoDays(DateTime.now()));

      if (habit.streak % 5 == 0 && habit.streak != 0) {
        await _activityService.createActivityForEvent(
            _userService.currentUser!.uid,
            _userService.currentUser!.username,
            ActivityType.streakMilestone,
            habit.id.toString(),
            habit.title,
            metadata: {'streakDays': habit.streak});
      }

      // Calculate stats
      final confidenceLevel =
          _statsCalculationService.calculateConfidenceLevel(habit);
      final consistencyFactor =
          _statsCalculationService.calculateConsistencyFactor(
        habit.stats,
        habit.targetGoal,
      );

      // Update or create stat point for today
      final existingStatIndex = habit.stats.indexWhere(
        (stat) => isSameDay(stat.date, DateTime.now()),
      );

      if (existingStatIndex != -1) {
        // Update existing stat point
        final existingStatPoint = habit.stats[existingStatIndex];
        existingStatPoint.completions += amount;
        existingStatPoint.confidenceLevel = confidenceLevel;
        existingStatPoint.consistencyFactor = consistencyFactor;
        existingStatPoint.streak = habit.streak;
        existingStatPoint.difficultyRating = difficultyRating;
      } else {
        // Add new stat point
        final statPoint = StatPoint(
          date: DateTime.now(),
          completions: amount,
          streak: habit.streak,
          confidenceLevel: confidenceLevel,
          consistencyFactor: consistencyFactor,
          difficultyRating: difficultyRating,
          slopeCompletions: 0.0,
          slopeConfidenceLevel: 0.0,
          slopeConsistency: 0.0,
          slopeDifficultyRating: 0.0,
        );
        habit.stats.add(statPoint);
      }
    }

    // Save changes
    await _saveHabitStats(habit);
  }

  Future<void> processHabitDecrement(
    Habit habit, {
    required int amount,
  }) async {
    final wasCompleted = habit.isCompleted;

    // Update progress directly
    final newProgress = Progress(
      current: math.max(habit.currentProgress - amount, 0),
      target: habit.targetGoal,
    );
    habit.currentProgress = newProgress.current;
    habit.totalProgress = math.max(0, habit.totalProgress - amount);

    final isNowCompleted = newProgress.isComplete;

    // Update streak and stats if was completed but now isn't
    if (wasCompleted && !isNowCompleted) {
      habit.streak = math.max(0, habit.streak - 1);
      habit.daysCompleted.removeWhere(
        (date) => isSameDay(date, DateTime.now()),
      );
    }

    // Update or create stat point for today
    final existingStatIndex = habit.stats.indexWhere(
      (stat) => isSameDay(stat.date, DateTime.now()),
    );

    // Calculate updated stats
    final confidenceLevel =
        _statsCalculationService.calculateConfidenceLevel(habit);
    final consistencyFactor =
        _statsCalculationService.calculateConsistencyFactor(
      habit.stats,
      habit.targetGoal,
    );

    if (existingStatIndex != -1) {
      // Update existing stat point
      final existingStatPoint = habit.stats[existingStatIndex];
      existingStatPoint.completions = habit.currentProgress;
      existingStatPoint.confidenceLevel = confidenceLevel;
      existingStatPoint.consistencyFactor = consistencyFactor;
      existingStatPoint.streak = habit.streak;
    } else {
      // Add new stat point for the decrement
      final statPoint = StatPoint(
        date: DateTime.now(),
        completions: habit.currentProgress,
        streak: habit.streak,
        confidenceLevel: confidenceLevel,
        consistencyFactor: consistencyFactor,
        difficultyRating: 5.0, // Default difficulty
        slopeCompletions: 0.0,
        slopeConfidenceLevel: 0.0,
        slopeConsistency: 0.0,
        slopeDifficultyRating: 0.0,
      );
      habit.stats.add(statPoint);
    }

    // Save changes
    await _saveHabitStats(habit);
  }

  Future<void> _saveHabitStats(Habit habit) async {
    // Save to local storage
    await _localStorageService.updateHabit(habit);

    // Save to remote database if user is authenticated
    if (_authService.currentUser != null) {
      await _databaseService.updateHabit(
        _authService.currentUser!.uid,
        habit,
      );
    }
  }
}
