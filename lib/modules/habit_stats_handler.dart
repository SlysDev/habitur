import 'package:flutter/material.dart';
import 'package:habitur/components/habit_difficulty_popup.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/data_point.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/modules/habit_stats_calculator.dart';
import 'package:habitur/modules/summary_statistics_recorder.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/providers/summary_statistics_repository.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class HabitStatsHandler {
  Habit habit;
  HabitStatsHandler(this.habit);

  void incrementCompletion(context, {double recordedDifficulty = 5}) async {
    SummaryStatisticsRecorder statsRecorder = SummaryStatisticsRecorder();
    HabitStatisticsCalculator statsCalculator =
        HabitStatisticsCalculator(habit);
    int habitIndex =
        Provider.of<HabitManager>(context, listen: false).habits.indexOf(habit);
    habit.completionsToday++;
    habit.totalCompletions++;
    if (habit.completionsToday == habit.requiredCompletions) {
      Provider.of<SummaryStatisticsRepository>(context, listen: false)
          .totalHabitsCompleted++;
      Provider.of<UserLocalStorage>(context, listen: false).addHabiturRating();
      await Provider.of<UserLocalStorage>(context, listen: false)
          .saveData(context);
      Provider.of<Database>(context, listen: false).uploadUserData(context);
      habit.streak++;
      if (habit.streak > habit.highestStreak) {
        habit.highestStreak = habit.streak;
      }
      habit.daysCompleted.add(DateTime.now());
    }
    fillInMissingDays(context);
    sortHabitStats();
    // if (habit.isCommunityHabit) {
    //   Provider.of<Database>(context, listen: false).uploadStatistics(context);
    //   return;
    // }
    int currentDayIndex = habit.stats.indexWhere(
      (dataPoint) =>
          dataPoint.date.year == DateTime.now().year &&
          dataPoint.date.month == DateTime.now().month &&
          dataPoint.date.day == DateTime.now().day,
    );
    if (currentDayIndex != -1) {
      // If there's an entry for the current day, update the completion count
      habit.stats[currentDayIndex].completions++;
      habit.stats[currentDayIndex].confidenceLevel =
          statsCalculator.calculateConfidenceLevel();
      habit.stats[currentDayIndex].streak = habit.streak;
      habit.stats[currentDayIndex].consistencyFactor = statsCalculator
          .calculateConsistencyFactor(habit.stats, habit.requiredCompletions);
      habit.stats[currentDayIndex].difficultyRating = recordedDifficulty;
      habit.stats[currentDayIndex].slopeCompletions =
          statsCalculator.calculateStatSlope('completions', habit.stats);
      habit.stats[currentDayIndex].slopeConsistency =
          statsCalculator.calculateStatSlope('consistencyFactor', habit.stats);
      habit.stats[currentDayIndex].slopeConfidenceLevel =
          statsCalculator.calculateStatSlope('confidenceLevel', habit.stats);
      habit.stats[currentDayIndex].slopeDifficultyRating =
          statsCalculator.calculateStatSlope('difficultyRating', habit.stats);
      statsRecorder.logHabitCompletion(context);
    } else {
      // If there's no entry for the current day, add a new entry
      StatPoint newStatPoint = StatPoint(
        date: DateTime.now(),
        completions: 1,
        confidenceLevel: statsCalculator.calculateConfidenceLevel(),
        streak: habit.streak,
        consistencyFactor: statsCalculator.calculateConsistencyFactor(
            habit.stats, habit.requiredCompletions),
        difficultyRating: recordedDifficulty,
        slopeCompletions:
            statsCalculator.calculateStatSlope('completions', habit.stats),
        slopeConsistency: statsCalculator.calculateStatSlope(
            'consistencyFactor', habit.stats),
        slopeConfidenceLevel:
            statsCalculator.calculateStatSlope('confidenceLevel', habit.stats),
        slopeDifficultyRating:
            statsCalculator.calculateStatSlope('difficultyRating', habit.stats),
        // TODO: Add calculations for slopes
      );
      habit.stats.add(newStatPoint);
      statsRecorder.logHabitCompletion(context);
    }
    print('slope: ' +
        statsCalculator
            .calculateStatSlope('completions', habit.stats)
            .toString());
    habit.confidenceLevel = statsCalculator.calculateConfidenceLevel();
  }

  void decrementCompletion(context) {
    SummaryStatisticsRecorder statsRecorder = SummaryStatisticsRecorder();
    HabitStatisticsCalculator statsCalculator =
        HabitStatisticsCalculator(habit);

    if (habit.completionsToday == 0) {
      return;
    }

    // Check if decrementing completion would change habit completion status
    if (habit.completionsToday == habit.requiredCompletions) {
      Provider.of<SummaryStatisticsRepository>(context, listen: false)
          .totalHabitsCompleted--;
      statsRecorder.recordAverageConfidenceLevel(context);

      if (habit.daysCompleted.isNotEmpty) {
        habit.daysCompleted.removeLast();
      }

      Provider.of<UserLocalStorage>(context, listen: false)
          .removeHabiturRating();
      Provider.of<Database>(context, listen: false).uploadUserData(context);
    }

    // Decrement completions and potentially update streak
    if (habit.streak > 0) {
      habit.streak--;
    }
    habit.completionsToday--;
    habit.totalCompletions--;

    if (habit.isCommunityHabit) {
      Provider.of<Database>(context, listen: false).uploadStatistics(context);
      return;
    }

    fillInMissingDays(context);
    sortHabitStats();

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

      habit.stats[currentDayIndex].consistencyFactor = statsCalculator
          .calculateConsistencyFactor(habit.stats, habit.requiredCompletions);
      habit.stats[currentDayIndex].difficultyRating = 0;
      habit.stats[currentDayIndex].slopeCompletions =
          statsCalculator.calculateStatSlope('completions', habit.stats);
      habit.stats[currentDayIndex].slopeConsistency =
          statsCalculator.calculateStatSlope('consistencyFactor', habit.stats);
      habit.stats[currentDayIndex].slopeConfidenceLevel =
          statsCalculator.calculateStatSlope('confidenceLevel', habit.stats);
      habit.stats[currentDayIndex].slopeDifficultyRating =
          statsCalculator.calculateStatSlope('difficultyRating', habit.stats);
    } else {
      // Shouldn't reach here ideally (log a message?)
      print('No entry found for decrementing habit completion in stats.');
    }
    // Update confidence level based on updated stats
    habit.confidenceLevel = statsCalculator.calculateConfidenceLevel();

    statsRecorder.unlogHabitCompletion(context);
    // TODO: Refactor into inc/dec habit + stats functions (separate)
  }

  void resetHabitCompletions() {
    if (!habit.isCompleted) {
      habit.streak = 0;
    }
    habit.completionsToday = 0;
    if (habit.streak > habit.highestStreak) {
      habit.highestStreak = habit.streak;
    }
  }

  void setDifficulty(double newDifficulty, context) {
    HabitStatisticsCalculator statsCalculator =
        HabitStatisticsCalculator(habit);
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
          statsCalculator.calculateStatSlope('difficultyRating', habit.stats);
    } else {
      // If there's no entry for the current day, add a new entry
      StatPoint newStatPoint = StatPoint(
        date: DateTime.now(),
        completions: 1,
        confidenceLevel: statsCalculator.calculateConfidenceLevel(),
        streak: habit.streak,
        consistencyFactor: statsCalculator.calculateConsistencyFactor(
            habit.stats, habit.requiredCompletions),
        difficultyRating: newDifficulty,
        slopeCompletions:
            statsCalculator.calculateStatSlope('completions', habit.stats),
        slopeConsistency: statsCalculator.calculateStatSlope(
            'consistencyFactor', habit.stats),
        slopeConfidenceLevel:
            statsCalculator.calculateStatSlope('confidenceLevel', habit.stats),
        slopeDifficultyRating:
            statsCalculator.calculateStatSlope('difficultyRating', habit.stats),
        // TODO: Add calculations for slopes
      );
      habit.stats.add(newStatPoint);
    }
    Provider.of<Database>(context, listen: false).uploadStatistics(context);
  }

  void fillInMissingDays(context) {
    HabitStatisticsCalculator statsCalculator =
        HabitStatisticsCalculator(habit);
    // Create a DateTime object for the start date of the habit
    DateTime startDate = habit.dateCreated;

    // Iterate through each day from the start date to the current date
    for (DateTime day =
            DateTime(startDate.year, startDate.month, startDate.day);
        day.isBefore(DateTime.now());
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
        // If no StatPoint exists, create a new one with 0 completions
        StatPoint newStatPoint = StatPoint(
          date: day,
          completions: 0,
          confidenceLevel: statsCalculator.calculateConfidenceLevel(),
          streak: 0,
          consistencyFactor: statsCalculator.calculateConsistencyFactor(
              habit.stats, habit.requiredCompletions),
          difficultyRating: statsCalculator.calculateAverageValueForStat(
              'difficultyRating', habit.stats),
          slopeCompletions: 0,
          slopeConsistency: 0,
          slopeConfidenceLevel: 0,
          slopeDifficultyRating: 0,
        );
        habit.stats.add(newStatPoint);
      }
    }
  }

  void sortHabitStats() {
    habit.stats.sort((a, b) => a.date.compareTo(b.date));
  }
}
