import 'package:flutter/material.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/auth_service.dart';
import 'package:habitur/services/database_service.dart';
import 'package:habitur/services/local_storage_service.dart';
import 'package:habitur/services/stats/aggregate_stats_calculator_service.dart';
import 'package:habitur/services/stats_calculation_service.dart';
import 'package:habitur/services/user_service.dart';
import 'dart:math' as math;

import 'package:habitur/util_functions.dart';

class UserStatsService {
  final _statsCalculationService = locator<StatsCalculationService>();
  final _localStorageService = locator<LocalStorageService>();
  final _databaseService = locator<DatabaseService>();
  final _authService = locator<AuthService>();
  final _userService = locator<UserService>();
  final _aggregateStatsCalculatorService =
      locator<AggregateStatsCalculatorService>();

  // Enhanced user stats
  Map<String, dynamic> getUserStats(List<Habit> habits) {
    if (habits.isEmpty) {
      return {
        'totalHabitsCompleted': 0,
        'longestStreak': 0,
        'weekCompletions': 0,
        'overallProgress': 0.0,
        'goalAchievementRates': <String, double>{},
        'engagement': _statsCalculationService.calculateEngagementMetrics([]),
        'rankedHabits': <String>[],
      };
    }

    return {
      'totalHabitsCompleted':
          _statsCalculationService.getTotalHabitsCompleted(habits),
      'longestStreak': _statsCalculationService.getLongestStreak(habits),
      'weekCompletions': _statsCalculationService.getWeekCompletions(habits),
      'overallProgress':
          _statsCalculationService.calculateOverallProgress(habits),
      'goalAchievementRates':
          _statsCalculationService.calculateGoalAchievementRates(habits),
      'engagement': _statsCalculationService.calculateEngagementMetrics(habits),
      'rankedHabits': _statsCalculationService
          .getBestPerformingHabits(habits)
          .map((h) => h.id.toString())
          .toList(),
    };
  }

  Future<void> updateCompletions({double amount = 1.0}) async {
    final user = _userService.currentUser;
    if (user?.stats == null) return;

    int currentDayIndex =
        user!.stats.indexWhere((stat) => isSameDay(stat.date, DateTime.now()));

    if (currentDayIndex != -1) {
      final newCompletions =
          user.stats[currentDayIndex].completions + amount.toInt();
      await _updateStatValue('completions', newCompletions.toDouble());
    }
  }

  Future<void> undoCompletion({double? amount}) async {
    final user = _userService.currentUser;
    if (user?.stats == null) return;

    int currentDayIndex =
        user!.stats!.indexWhere((stat) => isSameDay(stat.date, DateTime.now()));

    if (currentDayIndex != -1) {
      int currentCompletions = user.stats![currentDayIndex].completions;
      if (currentCompletions > 0) {
        // If amount is null, undo the last recorded amount or default to 1
        int amountToUndo = (amount ?? 1).toInt();
        // Don't let completions go below 0
        int newCompletions = (currentCompletions - amountToUndo)
            .clamp(0, double.infinity)
            .toInt();
        await _updateStatValue('completions', newCompletions.toDouble());
        // converting to double so it works w/ function; will get converted back to an int for completions within the function
      }
    }
  }

  Future<void> updateConfidenceLevel(double newConfidenceLevel) async {
    final user = _userService.currentUser;
    if (user?.stats == null) return;

    int currentDayIndex =
        user!.stats!.indexWhere((stat) => isSameDay(stat.date, DateTime.now()));

    if (currentDayIndex == -1) {
      await _ensureCurrentDayStatExists();
      currentDayIndex = user.stats!
          .indexWhere((stat) => isSameDay(stat.date, DateTime.now()));
    }

    await _updateStatValue('confidenceLevel', newConfidenceLevel);
  }

  Future<void> _ensureCurrentDayStatExists() async {
    final user = _userService.currentUser;
    if (user?.stats == null) return;

    int currentDayIndex =
        user!.stats!.indexWhere((stat) => isSameDay(stat.date, DateTime.now()));

    if (currentDayIndex == -1) {
      StatPoint newStat;
      if (user.stats!.isEmpty) {
        newStat = StatPoint(
          date: DateTime.now(),
          confidenceLevel: 0,
          completions: 0,
          streak: 0,
        );
      } else {
        newStat = StatPoint(
          date: DateTime.now(),
          confidenceLevel: user.stats!.last.confidenceLevel,
          completions: 0,
          streak: user.stats!.last.streak,
        );
      }

      user.stats!.add(newStat);
      await _saveStats(user.stats!);
    }
  }

  Future<void> _updateStatValue(String statName, double value) async {
    final user = _userService.currentUser;
    if (user?.stats == null) return;

    int currentDayIndex =
        user!.stats!.indexWhere((stat) => isSameDay(stat.date, DateTime.now()));

    if (currentDayIndex != -1) {
      switch (statName) {
        case 'completions':
          user.stats![currentDayIndex].completions = value.toInt();
          break;
        case 'confidenceLevel':
          user.stats![currentDayIndex].confidenceLevel = value;
          break;
        case 'streak':
          user.stats![currentDayIndex].streak = value.toInt();
          break;
      }
      await _saveStats(user.stats!);
    }
  }

  Future<void> _saveStats(List<StatPoint> stats) async {
    // Save to local storage
    await _localStorageService.updateAllStats(stats);

    // Save to remote database
    if (_authService.currentUser != null) {
      await _databaseService.updateUserStats(
          _authService.currentUser!.uid, stats);
    }
  }

  List<StatPoint> getStatsForDateRange(DateTime startDate, DateTime endDate) {
    final user = _userService.currentUser;
    if (user?.stats == null || user!.stats!.isEmpty) {
      return [];
    }

    DateTime firstDate = user.stats!.first.date;
    List<StatPoint> statsInRange = [];

    for (DateTime date = startDate;
        date.isBefore(endDate.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      if (user.stats!
              .indexWhere((dataPoint) => isSameDay(dataPoint.date, date)) !=
          -1) {
        statsInRange.add(user.stats!
            .firstWhere((dataPoint) => isSameDay(dataPoint.date, date)));
      } else if (date.isAfter(firstDate)) {
        statsInRange.add(StatPoint(
          date: date,
          confidenceLevel: 0,
          completions: 0,
          streak: 0,
        ));
      }
    }
    return statsInRange;
  }

  Future<void> logHabitIncrement(List<Habit> habits) async {
    final user = _userService.currentUser;
    if (user == null) return;

    final now = DateTime.now();

    final Map<String, dynamic> statsUpdates = {
      'date': now,
      'completions': _aggregateStatsCalculatorService
          .calculateSingleDayStatSum('completions', habits)
          .toInt(),
      'confidenceLevel': _aggregateStatsCalculatorService.calculateStatAverage(
          'confidenceLevel', habits),
      'streak': _aggregateStatsCalculatorService
          .calculateStatAverage('streak', habits)
          .toInt(),
      'consistencyFactor': _aggregateStatsCalculatorService
          .calculateStatAverage('consistencyFactor', habits),
      'difficultyRating': _aggregateStatsCalculatorService.calculateStatAverage(
          'difficultyRating', habits),
      'slopeCompletions': _aggregateStatsCalculatorService
          .calculateOverallSlope('completions', habits),
      'slopeConsistency': _aggregateStatsCalculatorService
          .calculateOverallSlope('consistencyFactor', habits),
      'slopeConfidenceLevel': _aggregateStatsCalculatorService
          .calculateOverallSlope('confidenceLevel', habits),
      'slopeDifficultyRating': _aggregateStatsCalculatorService
          .calculateOverallSlope('difficultyRating', habits),
    };

    bool needsNewPoint =
        user.stats!.indexWhere((dataPoint) => isSameDay(dataPoint.date, now)) ==
            -1;

    if (needsNewPoint) {
      user.stats!.add(StatPoint.fromMap(statsUpdates));
    } else {
      final currentDayIndex = user.stats!
          .indexWhere((stat) => isSameDay(stat.date, DateTime.now()));
      user.stats![currentDayIndex] = StatPoint.fromMap(statsUpdates);
    }

    await _localStorageService.updateUserStats(user.stats!);
    if (_authService.currentUser != null) {
      await _databaseService.updateUserStats(
          _authService.currentUser!.uid, user.stats!);
    }
  }

  Future<void> unlogHabitIncrement(List<Habit> habits) async {
    final user = _userService.currentUser;
    if (user == null || user.stats.isEmpty) return;

    int currentDayIndex =
        user.stats.indexWhere((stat) => isSameDay(stat.date, DateTime.now()));

    if (currentDayIndex != -1) {
      StatPoint currentStat = user.stats[currentDayIndex];

      // Reverse the stats updates using habit-based calculations
      currentStat.completions = math.max(0, currentStat.completions - 1);
      currentStat.confidenceLevel =
          math.max(0.0, currentStat.confidenceLevel - 0.1);
      currentStat.streak = math.max(0, currentStat.streak - 1);

      // Update local storage and database
      await _localStorageService.updateMostRecentStat(currentStat);
      if (_authService.currentUser != null) {
        await _databaseService.updateUserStats(
            _authService.currentUser!.uid, user.stats);
      }
    }
  }

  List<StatPoint> getStats(UserModel user) {
    if (user.stats == null) return [];
    return user.stats!.map((stat) => stat).toList(); // make a copy
  }
}
