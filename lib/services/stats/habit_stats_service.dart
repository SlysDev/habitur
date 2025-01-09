import 'package:flutter/material.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/enums/activity_type.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/habit_interface.dart';
import 'package:habitur/models/progress.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/services/activity_service.dart';
import 'package:habitur/services/auth_service.dart';
import 'package:habitur/services/database_service.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:habitur/services/local_storage_service.dart';
import 'package:habitur/services/stats/stats_calculation_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:habitur/util_functions.dart';
import 'dart:math' as math;

import 'package:intl/intl.dart';

class HabitStatsService {
  final _localStorageService = locator<LocalStorageService>();
  final _databaseService = locator<DatabaseService>();
  final _authService = locator<AuthService>();
  final _statsCalculationService = locator<StatsCalculationService>();
  final _activityService = locator<ActivityService>();
  final _userService = locator<UserService>();

  /// Processes the increment of a habit's progress.
  ///
  /// Updates the habit's progress and stats, even if the habit is not yet completed.
  /// Only updates streak-related stats when the habit is completed.
  Future<HabitInterface> processHabitIncrement(
    HabitInterface habit, {
    required int amount,
    required double difficultyRating,
  }) async {
    // Increment the habit's current progress by the specified amount.
    habit.incrementProgress(amount);
    habit.daysCompleted.add(simplifyDateIntoDays(DateTime.now()));
    debugPrint('REALLY QUICK: ${habit.currentProgress}');

    // Find the index of today's stat point, if it exists.
    final existingStatIndex = habit.stats.indexWhere(
      (stat) => isSameDay(stat.date, DateTime.now()),
    );

    StatPoint statPoint;

    if (existingStatIndex != -1) {
      // If a stat point for today exists, update its completions and difficulty rating.
      statPoint = habit.stats[existingStatIndex];
      statPoint.completions += amount;
      statPoint.difficultyRating = difficultyRating;
    } else {
      // If no stat point for today exists, create a new one with initial values.
      statPoint = StatPoint(
        date: DateTime.now(),
        completions: amount,
        difficultyRating: difficultyRating,
        streak: habit.streak,
        // Initialize other fields to default or zero values.
      );
      habit.stats.add(statPoint);
    }

    // calculate confidence level, consistency factor, and slopes after the fact
    habit.confidenceLevel =
        _statsCalculationService.calculateConfidenceLevel(habit);
    habit.stats.last.confidenceLevel =
        _statsCalculationService.calculateConfidenceLevel(habit);
    habit.stats.last.consistencyFactor = _statsCalculationService
        .calculateConsistencyFactor(habit.stats, habit.targetGoal);
    habit.stats.last.slopeCompletions =
        _statsCalculationService.calculateStatSlope('completions', habit.stats);
    habit.stats.last.slopeConfidenceLevel = _statsCalculationService
        .calculateStatSlope('confidenceLevel', habit.stats);
    habit.stats.last.slopeConsistency = _statsCalculationService
        .calculateStatSlope('consistencyFactor', habit.stats);
    habit.stats.last.slopeDifficultyRating = _statsCalculationService
        .calculateStatSlope('difficultyRating', habit.stats);

    if (habit.isCompleted) {
      // If the habit has reached its target and is now completed.

      // Update streak-related stats.
      habit.streak = math.max(0, habit.streak + 1);
      habit.highestStreak = math.max(habit.streak, habit.highestStreak);

      // Check for streak milestones and create activities if necessary.
      if (habit.streak % 5 == 0 && habit.streak != 0) {
        await _activityService.createActivityForEvent(
          _userService.currentUser!.uid,
          _userService.currentUser!.username,
          ActivityType.streakMilestone,
          habit.id.toString(),
          habit.title,
          metadata: {'streakDays': habit.streak},
        );
      }

      // Update the stat point's streak value.
      habit.stats.last.streak = habit.streak;
    }
    habit.lastSeen = DateTime.now();

    // Save changes to local storage and remote database.
    return habit;
  }

  /// Processes the decrement of a habit's progress.
  ///
  /// Updates the habit's progress and stats, even if the habit is not yet completed.
  /// Only updates streak-related stats when the habit moves from completed to not completed.
  Future<HabitInterface> processHabitDecrement(
    HabitInterface habit, {
    required int amount,
  }) async {
    final wasCompleted = habit.isCompleted;

    // Decrement the habit's current progress by the specified amount, ensuring it doesn't go negative.
    habit.decrementProgress(amount);
    habit.daysCompleted.removeWhere((date) => isSameDay(date, DateTime.now()));

    // Find the index of today's stat point, if it exists.
    final existingStatIndex = habit.stats.indexWhere(
      (stat) => isSameDay(stat.date, DateTime.now()),
    );

    StatPoint statPoint;

    if (existingStatIndex != -1) {
      // If a stat point for today exists, update its completions.
      statPoint = habit.stats[existingStatIndex];
      statPoint.completions = habit.currentProgress;
    } else {
      // If no stat point for today exists, create a new one with initial values.
      statPoint = StatPoint(
        date: DateTime.now(),
        completions: habit.currentProgress,
        streak: habit.streak,
        // Initialize other fields to default or zero values.
        confidenceLevel: 0.0,
        consistencyFactor: 0.0,
        difficultyRating: 5.0, // Default difficulty rating.
        slopeCompletions: 0.0,
        slopeConfidenceLevel: 0.0,
        slopeConsistency: 0.0,
        slopeDifficultyRating: 0.0,
      );
      habit.stats.add(statPoint);
    }

    // Calculate stats that are always updated, even if the habit is not completed.
    final confidenceLevel =
        _statsCalculationService.calculateConfidenceLevel(habit);
    final consistencyFactor =
        _statsCalculationService.calculateConsistencyFactor(
      habit.stats,
      habit.targetGoal,
    );

    // Update the stat point with the newly calculated values.
    statPoint.confidenceLevel = confidenceLevel;
    statPoint.consistencyFactor = consistencyFactor;

    if (wasCompleted && !habit.isCompleted) {
      // If the habit was completed but is no longer completed after decrementing.

      // Update streak-related stats.
      habit.streak = math.max(0, habit.streak - 1);

      // Update the stat point's streak value.
      statPoint.streak = habit.streak;
    }

    habit.lastSeen = DateTime.now();
    return habit;
  }

  /// Saves the habit's stats to local storage and remote database if authenticated.
  Future<void> _saveHabitStats(HabitInterface habit) async {
    debugPrint("saving habit stats (habit stats service)");
    final habitService = locator<HabitService>();
    await habitService.updateHabit(habit);
    // Update habit in local storage.
    await _localStorageService.updateHabit(habit);

    // If the user is authenticated, update the remote database.
    if (_authService.currentUser != null) {
      await _databaseService.updateInterfaceHabit(
        _authService.currentUser!.uid,
        habit,
      );
    }
  }

  void fillInMissingDays(HabitInterface habit) {
    // Create a DateTime object for the start date of the habit
    DateTime startDate = habit.dateCreated;

    if (habit.stats.isEmpty) {
      StatPoint newStatPoint = StatPoint(
        date: startDate,
        completions: 0,
        confidenceLevel: 0,
        streak: 0,
        consistencyFactor: 0,
        difficultyRating: 0,
        slopeCompletions: 0,
        slopeConsistency: 0,
        slopeConfidenceLevel: 0,
        slopeDifficultyRating: 0,
      );
      habit.stats.add(newStatPoint);
    }

    // Iterate through each day from the start date to the current date
    for (DateTime day =
            DateTime(startDate.year, startDate.month, startDate.day);
        day.isBefore(DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day));
        day = day.add(habit.resetPeriod == 'Monthly'
            ? const Duration(days: 31)
            : (habit.resetPeriod == 'Weekly'
                ? const Duration(days: 7)
                : const Duration(days: 1)))) {
      // Check if a StatPoint already exists for the current day
      if (habit.stats.indexWhere((dataPoint) =>
              DateTime(dataPoint.date.year, dataPoint.date.month,
                  dataPoint.date.day) ==
              day) ==
          -1) {
        String currentDayOfWeek = DateFormat("EEEE").format(day);
        bool isOffDay =
            !habit.requiredDatesOfCompletion.contains(currentDayOfWeek);
        // If no StatPoint exists, create a new one with 0 completions
        StatPoint newStatPoint = StatPoint(
          date: day,
          completions: isOffDay ? habit.stats.last.completions : 0,
          confidenceLevel: isOffDay
              ? habit.stats.last.confidenceLevel
              : _statsCalculationService.calculateConfidenceLevel(habit),
          streak: isOffDay ? 0 : 1,
          consistencyFactor: isOffDay
              ? habit.stats.last.consistencyFactor
              : _statsCalculationService.calculateConsistencyFactor(
                  habit.stats, habit.targetGoal),
          difficultyRating: isOffDay
              ? habit.stats.last.difficultyRating
              : _statsCalculationService.calculateAverageValueForStat(
                  'difficultyRating', habit.stats),
          slopeCompletions: isOffDay
              ? habit.stats.last.slopeCompletions
              : _statsCalculationService.calculateStatSlope(
                  'completions', habit.stats),
          slopeConsistency: isOffDay
              ? habit.stats.last.slopeConsistency
              : _statsCalculationService.calculateStatSlope(
                  'consistencyFactor', habit.stats),
          slopeConfidenceLevel: isOffDay
              ? habit.stats.last.slopeConfidenceLevel
              : _statsCalculationService.calculateStatSlope(
                  'confidenceLevel', habit.stats),
          slopeDifficultyRating: isOffDay
              ? habit.stats.last.slopeDifficultyRating
              : _statsCalculationService.calculateStatSlope(
                  'difficultyRating', habit.stats),
        );
        habit.stats.add(newStatPoint);
      }
    }
  }
}
