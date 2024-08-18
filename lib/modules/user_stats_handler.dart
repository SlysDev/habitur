import 'package:flutter/material.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/modules/user_stats_calculator.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/providers/summary_statistics_repository.dart';
import 'package:provider/provider.dart';

class UserStatsHandler {
  void logHabitCompletion(BuildContext context) {
    UserModel user =
        Provider.of<UserLocalStorage>(context, listen: false).currentUser;
    UserStatsCalculator userStatsCalculator = UserStatsCalculator(
        Provider.of<HabitManager>(context, listen: false).habits);
    fillInMissingDays(context);
    sortStats(context);

    // Check if there's an entry for the current day
    int currentDayIndex = user.stats.indexWhere(
      (stat) =>
          stat.date.year == DateTime.now().year &&
          stat.date.month == DateTime.now().month &&
          stat.date.day == DateTime.now().day,
    );

    if (currentDayIndex != -1) {
      // If there's an entry for the current day, update the completion count
      Provider.of<UserLocalStorage>(context, listen: false)
          .updateUserStat('date', DateTime.now());
      Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
          'completions', user.stats[currentDayIndex].completions + 1);
      Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
          'confidenceLevel',
          userStatsCalculator.calculateTodaysStatAverage('confidenceLevel'));
      Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
          'streak',
          userStatsCalculator.calculateTodaysStatAverage('streak').toInt());
      Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
          'consistencyFactor',
          userStatsCalculator.calculateTodaysStatAverage('consistencyFactor'));
      Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
          'difficultyRating',
          userStatsCalculator.calculateTodaysStatAverage('difficultyRating'));
      Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
          'slopeCompletions',
          userStatsCalculator.calculateOverallSlope('completions'));
      Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
          'slopeConsistency',
          userStatsCalculator.calculateOverallSlope('consistencyFactor'));
      Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
          'slopeConfidenceLevel',
          userStatsCalculator.calculateOverallSlope('confidenceLevel'));
    } else {
      if (user.stats.isEmpty) {
        StatPoint newStatPoint = StatPoint(
            date: DateTime.now(),
            completions: 1,
            confidenceLevel:
                Provider.of<SummaryStatisticsRepository>(context, listen: false)
                    .getAverageConfidenceLevel(context),
            streak:
                Provider.of<SummaryStatisticsRepository>(context, listen: false)
                    .getAverageStreak(context)
                    .toInt());
        Provider.of<UserLocalStorage>(context, listen: false)
            .addUserStatPoint(newStatPoint);
      } else {
        StatPoint newStatPoint = StatPoint(
            date: DateTime.now(),
            completions: 1,
            confidenceLevel:
                Provider.of<SummaryStatisticsRepository>(context, listen: false)
                    .getAverageConfidenceLevel(context),
            streak:
                Provider.of<SummaryStatisticsRepository>(context, listen: false)
                    .getAverageStreak(context)
                    .toInt());
        // TODO: Add calculations for slopes + consistency factor avg
        Provider.of<UserLocalStorage>(context, listen: false)
            .addUserStatPoint(newStatPoint);
      }
      // If there's no entry for the current day, add a new entry
      StatPoint newEntry = user.stats.last;
      newEntry.date = DateTime.now();
      newEntry.completions = 1;
      Provider.of<UserLocalStorage>(context, listen: false)
          .addUserStatPoint(newEntry);
    }

    // Notify the display manager to update
    recordAverageConfidenceLevel(context);
    print('Date: ' +
        user.stats.last.date.toString() +
        " Completions: " +
        user.stats.last.completions.toString());
    Provider.of<Database>(context, listen: false).uploadStatistics(context);
  }

  void unlogHabitCompletion(BuildContext context) {
    UserModel user =
        Provider.of<UserLocalStorage>(context, listen: false).currentUser;
    UserStatsCalculator summaryStatsCalculator = UserStatsCalculator(
        Provider.of<HabitManager>(context, listen: false).habits);
    fillInMissingDays(context);

    int currentDayIndex = user.stats.indexWhere((stat) =>
        stat.date.year == DateTime.now().year &&
        stat.date.month == DateTime.now().month &&
        stat.date.day == DateTime.now().day);

    if (currentDayIndex != -1) {
      // Decrement completion count if it's positive
      if (user.stats[currentDayIndex].completions > 0) {
        Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
            'completions', user.stats[currentDayIndex].completions - 1);
        Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
            'confidenceLevel',
            summaryStatsCalculator
                .calculateTodaysStatAverage('confidenceLevel'));
        Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
            'streak',
            summaryStatsCalculator
                .calculateTodaysStatAverage('streak')
                .toInt());
        Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
            'consistencyFactor',
            summaryStatsCalculator
                .calculateTodaysStatAverage('consistencyFactor'));
        Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
            'difficultyRating',
            summaryStatsCalculator
                .calculateTodaysStatAverage('difficultyRating'));
        Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
            'slopeCompletions',
            summaryStatsCalculator.calculateOverallSlope('completions'));
        Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
            'slopeConsistency',
            summaryStatsCalculator.calculateOverallSlope('consistencyFactor'));
        Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
            'slopeConfidenceLevel',
            summaryStatsCalculator.calculateOverallSlope('confidenceLevel'));
      }
    } else {
      // No need to undo anything if there's no entry for the current day
      print('No entry found for unlogging habit completion.');
    }

    recordAverageConfidenceLevel(context);
    Provider.of<Database>(context, listen: false).uploadStatistics(context);
  }

  void recordAverageConfidenceLevel(context) {
    double Function(BuildContext) getAverageConfidenceLevel =
        Provider.of<SummaryStatisticsRepository>(context, listen: false)
            .getAverageConfidenceLevel;
    int currentDayIndex = user.stats.indexWhere(
      (stat) =>
          stat.date.year == DateTime.now().year &&
          stat.date.month == DateTime.now().month &&
          stat.date.day == DateTime.now().day,
    );
    // If the two dates are more than a minute apart
    if (user.stats.isEmpty) {
      user.stats.add(StatPoint(
          date: DateTime.now(), completions: 0, confidenceLevel: 1, streak: 0));
    } else if (currentDayIndex == -1) {
      StatPoint newEntry = user.stats.last;
      newEntry.date = DateTime.now();
      newEntry.confidenceLevel = getAverageConfidenceLevel(context);
      user.stats.add(newEntry);
    } else {
      user.stats[currentDayIndex].confidenceLevel =
          getAverageConfidenceLevel(context);
    }
  }

  void fillInMissingDays(context) {
    UserStatsCalculator statsCalculator = UserStatsCalculator(
        Provider.of<HabitManager>(context, listen: false).habits);
    // Create a DateTime object for the start date of the habit
    if (user.stats.isEmpty) {
      return;
    }
    DateTime startDate = user.stats.first.date;

    // Iterate through each day from the start date to the current date
    for (DateTime day =
            DateTime(startDate.year, startDate.month, startDate.day);
        day.isBefore(DateTime.now());
        day = day.add(Duration(days: 1))) {
      // Check if a StatPoint already exists for the current day
      if (user.stats.indexWhere((dataPoint) =>
              DateTime(dataPoint.date.year, dataPoint.date.month,
                  dataPoint.date.day) ==
              day) ==
          -1) {
        // If no StatPoint exists, create a new one with 0 completions
        StatPoint newStatPoint = StatPoint(
          date: day,
          completions: 0,
          confidenceLevel:
              statsCalculator.calculateTodaysStatAverage('confidenceLevel'),
          streak: 0,
          consistencyFactor:
              statsCalculator.calculateTodaysStatAverage('consistencyFactor'),
          difficultyRating:
              statsCalculator.calculateTodaysStatAverage('difficultyRating'),
          slopeCompletions:
              statsCalculator.calculateOverallSlope('completions'),
          slopeConsistency:
              statsCalculator.calculateOverallSlope('consistencyFactor'),
          slopeConfidenceLevel:
              statsCalculator.calculateOverallSlope('confidenceLevel'),
          slopeDifficultyRating:
              statsCalculator.calculateOverallSlope('difficultyRating'),
        );
        user.stats.add(newStatPoint);
      }
    }
  }

  void sortStats(context) {
    user.stats.sort((a, b) => a.date.compareTo(b.date));
  }
}
