import 'package:flutter/material.dart';
import 'package:habitur/components/habit_difficulty_popup.dart';
import 'package:habitur/data/data_manager.dart';
import 'package:habitur/data/local/habits_local_storage.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/data_point.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/modules/habit_stats_calculator.dart';
import 'package:habitur/modules/user_stats_handler.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class HabitStatsHandler {
  Habit habit;
  HabitStatsHandler(this.habit);
  Database db = Database();

  Future<void> incrementCompletion(context,
      {double recordedDifficulty = 5}) async {
    UserStatsHandler userStatsHandler = UserStatsHandler();
    if (Provider.of<UserLocalStorage>(context, listen: false)
        .currentUser
        .stats
        .isEmpty) {
      debugPrint('user stats hasn\'t been loaded in yet; doing it now');
      await DataManager().loadStatsData(context);
    }
    await Provider.of<HabitManager>(context, listen: false)
        .resetHabits(context);
    habit.completionsToday++;
    habit.totalCompletions++;
    if (habit.completionsToday == habit.requiredCompletions) {
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
      habit.stats[currentDayIndex].streak = habit.streak;
      habit.stats[currentDayIndex].consistencyFactor =
          HabitStatsCalculator(habit).calculateConsistencyFactor(
              habit.stats, habit.requiredCompletions);
      habit.stats[currentDayIndex].difficultyRating = recordedDifficulty;
      habit.stats[currentDayIndex].slopeCompletions =
          HabitStatsCalculator(habit)
              .calculateStatSlope('completions', habit.stats);
      habit.stats[currentDayIndex].slopeConsistency =
          HabitStatsCalculator(habit)
              .calculateStatSlope('consistencyFactor', habit.stats);
      habit.stats[currentDayIndex].slopeConfidenceLevel =
          HabitStatsCalculator(habit)
              .calculateStatSlope('confidenceLevel', habit.stats);
      habit.stats[currentDayIndex].slopeDifficultyRating =
          HabitStatsCalculator(habit)
              .calculateStatSlope('difficultyRating', habit.stats);
      habit.stats[currentDayIndex].confidenceLevel =
          HabitStatsCalculator(habit).calculateConfidenceLevel();
    } else {
      // If there's no entry for the current day, add a new entry
      StatPoint newStatPoint = StatPoint(
        date: DateTime.now(),
        completions: 1,
        streak: habit.streak,
        consistencyFactor: HabitStatsCalculator(habit)
            .calculateConsistencyFactor(habit.stats, habit.requiredCompletions),
        difficultyRating: recordedDifficulty,
        slopeCompletions: HabitStatsCalculator(habit)
            .calculateStatSlope('completions', habit.stats),
        slopeConsistency: HabitStatsCalculator(habit)
            .calculateStatSlope('consistencyFactor', habit.stats),
        slopeConfidenceLevel: HabitStatsCalculator(habit)
            .calculateStatSlope('confidenceLevel', habit.stats),
        slopeDifficultyRating: HabitStatsCalculator(habit)
            .calculateStatSlope('difficultyRating', habit.stats),
      );
      habit.stats.add(newStatPoint);
      habit.stats.last.confidenceLevel =
          HabitStatsCalculator(habit).calculateConfidenceLevel();
    }
    debugPrint('slope: ' +
        HabitStatsCalculator(habit)
            .calculateStatSlope('completions', habit.stats)
            .toString());
    debugPrint('setting confidence level: ' +
        HabitStatsCalculator(habit).calculateConfidenceLevel().toString());
    habit.confidenceLevel =
        HabitStatsCalculator(habit).calculateConfidenceLevel();
    // has to be static because the habit has been updated
    await userStatsHandler.logHabitCompletion(context);
  }

  Future<void> decrementCompletion(context) async {
    UserStatsHandler userStatsHandler = UserStatsHandler();
    if (habit.completionsToday == 0) {
      return;
    }

    // Check if decrementing completion would change habit completion status
    if (habit.completionsToday == habit.requiredCompletions) {
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
    habit.completionsToday--;
    habit.totalCompletions--;

    if (habit.isCommunityHabit) {
      await db.statsDatabase.uploadStatistics(context);
      return;
    }

    fillInMissingDays(context);
    sortHabitStats();

    if (habit.completionsToday == 0) {
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
            HabitStatsCalculator(habit).calculateConsistencyFactor(
                habit.stats, habit.requiredCompletions);
        habit.stats[currentDayIndex].difficultyRating = 0;
        habit.stats[currentDayIndex].slopeCompletions =
            HabitStatsCalculator(habit)
                .calculateStatSlope('completions', habit.stats);
        habit.stats[currentDayIndex].slopeConsistency =
            HabitStatsCalculator(habit)
                .calculateStatSlope('consistencyFactor', habit.stats);
        habit.stats[currentDayIndex].slopeConfidenceLevel =
            HabitStatsCalculator(habit)
                .calculateStatSlope('confidenceLevel', habit.stats);
        habit.stats[currentDayIndex].slopeDifficultyRating =
            HabitStatsCalculator(habit)
                .calculateStatSlope('difficultyRating', habit.stats);
      } else {
        // Shouldn't reach here ideally (log a message?)
        debugPrint(
            'No entry found for decrementing habit completion in stats.');
      }
      // Update confidence level based on updated stats
      habit.confidenceLevel =
          HabitStatsCalculator(habit).calculateConfidenceLevel();
    }

    await userStatsHandler.unlogHabitCompletion(context);
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
          HabitStatsCalculator(habit)
              .calculateStatSlope('difficultyRating', habit.stats);
    } else {
      // If there's no entry for the current day, add a new entry
      StatPoint newStatPoint = StatPoint(
        date: DateTime.now(),
        completions: 1,
        confidenceLevel: HabitStatsCalculator(habit).calculateConfidenceLevel(),
        streak: habit.streak,
        consistencyFactor: HabitStatsCalculator(habit)
            .calculateConsistencyFactor(habit.stats, habit.requiredCompletions),
        difficultyRating: newDifficulty,
        slopeCompletions: HabitStatsCalculator(habit)
            .calculateStatSlope('completions', habit.stats),
        slopeConsistency: HabitStatsCalculator(habit)
            .calculateStatSlope('consistencyFactor', habit.stats),
        slopeConfidenceLevel: HabitStatsCalculator(habit)
            .calculateStatSlope('confidenceLevel', habit.stats),
        slopeDifficultyRating: HabitStatsCalculator(habit)
            .calculateStatSlope('difficultyRating', habit.stats),
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
              : HabitStatsCalculator(habit).calculateConfidenceLevel(),
          streak: isOffDay ? 0 : 1,
          consistencyFactor: isOffDay
              ? habit.stats.last.consistencyFactor
              : HabitStatsCalculator(habit).calculateConsistencyFactor(
                  habit.stats, habit.requiredCompletions),
          difficultyRating: isOffDay
              ? habit.stats.last.difficultyRating
              : HabitStatsCalculator(habit).calculateAverageValueForStat(
                  'difficultyRating', habit.stats),
          slopeCompletions: isOffDay
              ? habit.stats.last.slopeCompletions
              : HabitStatsCalculator(habit)
                  .calculateStatSlope('completions', habit.stats),
          slopeConsistency: isOffDay
              ? habit.stats.last.slopeConsistency
              : HabitStatsCalculator(habit)
                  .calculateStatSlope('consistencyFactor', habit.stats),
          slopeConfidenceLevel: isOffDay
              ? habit.stats.last.slopeConfidenceLevel
              : HabitStatsCalculator(habit)
                  .calculateStatSlope('confidenceLevel', habit.stats),
          slopeDifficultyRating: isOffDay
              ? habit.stats.last.slopeDifficultyRating
              : HabitStatsCalculator(habit)
                  .calculateStatSlope('difficultyRating', habit.stats),
        );
        habit.stats.add(newStatPoint);
      }
    }
  }

  void sortHabitStats() {
    habit.stats.sort((a, b) => a.date.compareTo(b.date));
  }
}
