import 'package:flutter/material.dart';
import 'package:habitur/components/habit_difficulty_popup.dart';
import 'package:habitur/data/data_manager.dart';
import 'package:habitur/data/local/habits_local_storage.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/data_point.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/models/activity_event.dart';
import 'package:habitur/modules/habit_stats_calculator.dart';
import 'package:habitur/modules/user_stats_handler.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/providers/activity_provider.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class HabitStatsHandler {
  final Habit habit;
  final Database db = Database();
  late final HabitStatsCalculator _calculator;

  HabitStatsHandler(this.habit) {
    _calculator = HabitStatsCalculator(habit);
  }

  Future<void> incrementCompletion(context, {double recordedDifficulty = 5}) async {
    final stopwatch = Stopwatch()..start();

    try {
      final userStorage = Provider.of<UserLocalStorage>(context, listen: false);
      final habitManager = Provider.of<HabitManager>(context, listen: false);
      final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
      final userStatsHandler = UserStatsHandler();
      final now = DateTime.now();

      debugPrint('Starting habit completion at: ${stopwatch.elapsedMilliseconds}ms');

      // Batch all initialization operations
      await Future.wait([
        Future(() async {
          if (userStorage.currentUser.stats.isEmpty) {
            final loadStart = stopwatch.elapsedMilliseconds;
            await DataManager().loadStatsData(context);
            debugPrint('Stats loading took: ${stopwatch.elapsedMilliseconds - loadStart}ms');
          }
        }),
        habitManager.resetHabits(context),
      ]);

      // Update local state
      habit.currentProgress++;
      habit.totalProgress++;

      // Prepare all update operations
      final List<Future> updateOperations = [];

      // Handle completion if needed
      if (habit.currentProgress == habit.targetGoal) {
        final completionStart = stopwatch.elapsedMilliseconds;
        
        // Update local state
        habit.streak++;
        habit.highestStreak = max(habit.streak, habit.highestStreak);
        habit.daysCompleted.add(now);

        // Prepare activity events
        final user = userStorage.currentUser;
        final activities = [
          ActivityEvent(
            userId: user.uid,
            username: user.username,
            type: ActivityType.habitCompletion,
            habitId: habit.id.toString(),
            habitTitle: habit.title,
            metadata: {'difficulty': recordedDifficulty},
          ),
        ];

        if (habit.streak == 7 || habit.streak == 30 || habit.streak == 100) {
          activities.add(ActivityEvent(
            userId: user.uid,
            username: user.username,
            type: ActivityType.streakMilestone,
            habitId: habit.id.toString(),
            habitTitle: habit.title,
            metadata: {'streakDays': habit.streak},
          ));
        }

        // Add activity creation to update operations
        updateOperations.addAll(
          activities.map((activity) => activityProvider.createActivity(activity))
        );

        debugPrint('Completion preparation took: ${stopwatch.elapsedMilliseconds - completionStart}ms');
      }

      // Prepare stats update
      final statsStart = stopwatch.elapsedMilliseconds;
      _updateStats(recordedDifficulty, context);
      debugPrint('Local stats update took: ${stopwatch.elapsedMilliseconds - statsStart}ms');

      // Add stats logging to update operations
      updateOperations.add(userStatsHandler.logHabitCompletion(context));

      // Execute all updates in parallel
      final updateStart = stopwatch.elapsedMilliseconds;
      await Future.wait(updateOperations);
      debugPrint('Remote updates took: ${stopwatch.elapsedMilliseconds - updateStart}ms');

    } finally {
      debugPrint('Total habit completion took: ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.stop();
    }
  }

  void _updateStats(double recordedDifficulty, BuildContext context) {
    final now = DateTime.now();
    
    // Only fill and sort if needed (when creating new stat point)
    bool needsNewPoint = !habit.stats.any((dataPoint) =>
        dataPoint.date.year == now.year &&
        dataPoint.date.month == now.month &&
        dataPoint.date.day == now.day);
        
    if (needsNewPoint) {
      fillInMissingDays(context);
      sortHabitStats();
    }

    // Cache slope calculations
    final slopes = _calculateAllSlopes();
    
    final currentDayIndex = habit.stats.indexWhere((dataPoint) =>
        dataPoint.date.year == now.year &&
        dataPoint.date.month == now.month &&
        dataPoint.date.day == now.day);

    if (currentDayIndex != -1) {
      _updateExistingStatPoint(currentDayIndex, recordedDifficulty, slopes);
    } else {
      _createNewStatPoint(recordedDifficulty, slopes);
    }

    // Calculate confidence level once at the end
    habit.confidenceLevel = _calculator.calculateConfidenceLevel();
  }

  Map<String, double> _calculateAllSlopes() {
    return {
      'completions': _calculator.calculateStatSlope('completions', habit.stats),
      'consistencyFactor': _calculator.calculateStatSlope('consistencyFactor', habit.stats),
      'confidenceLevel': _calculator.calculateStatSlope('confidenceLevel', habit.stats),
      'difficultyRating': _calculator.calculateStatSlope('difficultyRating', habit.stats),
    };
  }

  void _updateExistingStatPoint(int index, double recordedDifficulty, Map<String, double> slopes) {
    final statPoint = habit.stats[index];
    statPoint.completions++;
    statPoint.streak = habit.streak;
    statPoint.consistencyFactor = _calculator.calculateConsistencyFactor(habit.stats, habit.targetGoal);
    statPoint.difficultyRating = recordedDifficulty;
    
    // Use cached slopes
    statPoint.slopeCompletions = slopes['completions']!;
    statPoint.slopeConsistency = slopes['consistencyFactor']!;
    statPoint.slopeConfidenceLevel = slopes['confidenceLevel']!;
    statPoint.slopeDifficultyRating = slopes['difficultyRating']!;
    statPoint.confidenceLevel = _calculator.calculateConfidenceLevel();
  }

  void _createNewStatPoint(double recordedDifficulty, Map<String, double> slopes) {
    final newStatPoint = StatPoint(
      date: DateTime.now(),
      completions: 1,
      streak: habit.streak,
      consistencyFactor: _calculator.calculateConsistencyFactor(habit.stats, habit.targetGoal),
      difficultyRating: recordedDifficulty,
      
      // Use cached slopes
      slopeCompletions: slopes['completions']!,
      slopeConsistency: slopes['consistencyFactor']!,
      slopeConfidenceLevel: slopes['confidenceLevel']!,
      slopeDifficultyRating: slopes['difficultyRating']!,
    );
    newStatPoint.confidenceLevel = _calculator.calculateConfidenceLevel();
    habit.stats.add(newStatPoint);
  }

  Future<void> decrementCompletion(context) async {
    UserStatsHandler userStatsHandler = UserStatsHandler();
    if (habit.currentProgress == 0) {
      return;
    }

    // Check if decrementing completion would change habit completion status
    if (habit.currentProgress == habit.targetGoal) {
      userStatsHandler.recordAverageConfidenceLevel(context);

      if (habit.daysCompleted.isNotEmpty) {
        habit.daysCompleted.removeLast();
      }

      Provider.of<UserLocalStorage>(context, listen: false)
          .removeHabiturRating();
      db.userDatabase.uploadUserData(context);
    }

    // Decrement completions and potentially update streak
    String currentDayOfWeek = DateFormat('EEEE').format(DateTime.now());
    if (habit.streak > 0) {
      habit.streak--;
    }
    habit.currentProgress--;
    habit.totalProgress--;

    if (habit.isCommunityHabit) {
      await db.statsDatabase.uploadStatistics(context);
      return;
    }

    fillInMissingDays(context);
    sortHabitStats();

    if (habit.currentProgress == 0) {
      habit.stats.removeLast();
    } else {
      // Find the StatPoint entry for the current day
      int currentDayIndex = habit.stats.indexWhere((dataPoint) =>
          dataPoint.date.year == DateTime.now().year &&
          dataPoint.date.month == DateTime.now().month &&
          dataPoint.date.day == DateTime.now().day);

      if (currentDayIndex != -1) {
        // Decrement completions in the StatPoint for the current day
        if (habit.stats[currentDayIndex].completions > 0) {
          habit.stats[currentDayIndex].completions--;
        }

        // Update streak in the StatPoint if necessary
        if (habit.streak > 0) {
          habit.stats[currentDayIndex].streak--;
        }

        habit.stats[currentDayIndex].consistencyFactor =
            _calculator.calculateConsistencyFactor(habit.stats, habit.targetGoal);
        habit.stats[currentDayIndex].difficultyRating = 0;
        habit.stats[currentDayIndex].slopeCompletions =
            _calculator.calculateStatSlope('completions', habit.stats);
        habit.stats[currentDayIndex].slopeConsistency =
            _calculator.calculateStatSlope('consistencyFactor', habit.stats);
        habit.stats[currentDayIndex].slopeConfidenceLevel =
            _calculator.calculateStatSlope('confidenceLevel', habit.stats);
        habit.stats[currentDayIndex].slopeDifficultyRating =
            _calculator.calculateStatSlope('difficultyRating', habit.stats);
      } else {
        // Shouldn't reach here ideally (log a message?)
        debugPrint(
            'No entry found for decrementing habit completion in stats.');
      }
      // Update confidence level based on updated stats
      habit.confidenceLevel =
          _calculator.calculateConfidenceLevel();
    }

    await userStatsHandler.unlogHabitCompletion(context);
  }

  void resetHabitCompletions() {
    habit.currentProgress = 0;
    if (habit.streak > habit.highestStreak) {
      habit.highestStreak = habit.streak;
    }
  }

  void setDifficulty(double newDifficulty, context) {
    int currentDayIndex = habit.stats.indexWhere(
      (dataPoint) =>
          dataPoint.date.year == DateTime.now().year &&
          dataPoint.date.month == DateTime.now().month &&
          dataPoint.date.day == DateTime.now().day,
    );
    if (currentDayIndex != -1) {
      // If there's an entry for the current day, update the completion count
      habit.stats[currentDayIndex].completions++;
      habit.stats[currentDayIndex].slopeDifficultyRating =
          _calculator.calculateStatSlope('difficultyRating', habit.stats);
    } else {
      // If there's no entry for the current day, add a new entry
      StatPoint newStatPoint = StatPoint(
        date: DateTime.now(),
        completions: 1,
        confidenceLevel: _calculator.calculateConfidenceLevel(),
        streak: habit.streak,
        consistencyFactor: _calculator.calculateConsistencyFactor(habit.stats, habit.targetGoal),
        difficultyRating: newDifficulty,
        slopeCompletions: _calculator.calculateStatSlope('completions', habit.stats),
        slopeConsistency: _calculator.calculateStatSlope('consistencyFactor', habit.stats),
        slopeConfidenceLevel: _calculator.calculateStatSlope('confidenceLevel', habit.stats),
        slopeDifficultyRating: _calculator.calculateStatSlope('difficultyRating', habit.stats),
      );
      habit.stats.add(newStatPoint);
    }
    db.statsDatabase.uploadStatistics(context);
  }

  void fillInMissingDays(context) {
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
            ? Duration(days: 31)
            : (habit.resetPeriod == 'Weekly'
                ? Duration(days: 7)
                : Duration(days: 1)))) {
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
              : _calculator.calculateConfidenceLevel(),
          streak: isOffDay ? 0 : 1,
          consistencyFactor: isOffDay
              ? habit.stats.last.consistencyFactor
              : _calculator.calculateConsistencyFactor(habit.stats, habit.targetGoal),
          difficultyRating: isOffDay
              ? habit.stats.last.difficultyRating
              : _calculator.calculateAverageValueForStat(
                  'difficultyRating', habit.stats),
          slopeCompletions: isOffDay
              ? habit.stats.last.slopeCompletions
              : _calculator.calculateStatSlope('completions', habit.stats),
          slopeConsistency: isOffDay
              ? habit.stats.last.slopeConsistency
              : _calculator.calculateStatSlope('consistencyFactor', habit.stats),
          slopeConfidenceLevel: isOffDay
              ? habit.stats.last.slopeConfidenceLevel
              : _calculator.calculateStatSlope('confidenceLevel', habit.stats),
          slopeDifficultyRating: isOffDay
              ? habit.stats.last.slopeDifficultyRating
              : _calculator.calculateStatSlope('difficultyRating', habit.stats),
        );
        habit.stats.add(newStatPoint);
      }
    }
  }

  void sortHabitStats() {
    habit.stats.sort((a, b) => a.date.compareTo(b.date));
  }
}
