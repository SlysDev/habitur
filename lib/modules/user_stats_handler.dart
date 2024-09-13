import 'package:flutter/material.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/modules/summary_stats_calculator.dart';
import 'package:habitur/modules/user_stats_calculator.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:provider/provider.dart';

class UserStatsHandler {
  Database db = Database();
  SummaryStatsCalculator summaryStatsCalculator = SummaryStatsCalculator();
  Future<void> logHabitCompletion(BuildContext context) async {
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
      // If there's an entry for the current day, update
      print('updating current day');
      Provider.of<UserLocalStorage>(context, listen: false)
          .updateUserStat('date', DateTime.now(), context);
      Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
          'completions', user.stats[currentDayIndex].completions + 1, context);
      Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
          'confidenceLevel',
          userStatsCalculator.calculateTodaysStatAverage('confidenceLevel'),
          context);
      Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
          'streak',
          userStatsCalculator.calculateTodaysStatAverage('streak').toInt(),
          context);
      Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
          'consistencyFactor',
          userStatsCalculator.calculateTodaysStatAverage('consistencyFactor'),
          context);
      Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
          'difficultyRating',
          userStatsCalculator.calculateTodaysStatAverage('difficultyRating'),
          context);
      Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
          'slopeCompletions',
          userStatsCalculator.calculateOverallSlope('completions'),
          context);
      Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
          'slopeConsistency',
          userStatsCalculator.calculateOverallSlope('consistencyFactor'),
          context);
      Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
          'slopeConfidenceLevel',
          userStatsCalculator.calculateOverallSlope('confidenceLevel'),
          context);
    } else {
      print('adding new day stat point');
      StatPoint newEntry = StatPoint(
        date: DateTime.now(),
        completions: 1,
        confidenceLevel:
            userStatsCalculator.calculateTodaysStatAverage('confidenceLevel'),
        streak:
            userStatsCalculator.calculateTodaysStatAverage('streak').toInt(),
        consistencyFactor:
            userStatsCalculator.calculateTodaysStatAverage('consistencyFactor'),
        difficultyRating:
            userStatsCalculator.calculateTodaysStatAverage('difficultyRating'),
        slopeCompletions:
            userStatsCalculator.calculateOverallSlope('completions'),
        slopeConsistency:
            userStatsCalculator.calculateOverallSlope('consistencyFactor'),
        slopeConfidenceLevel:
            userStatsCalculator.calculateOverallSlope('confidenceLevel'),
        slopeDifficultyRating:
            userStatsCalculator.calculateOverallSlope('difficultyRating'),
      );
      Provider.of<UserLocalStorage>(context, listen: false)
          .addUserStatPoint(newEntry, context);
    }

    // Notify the display manager to update
    recordAverageConfidenceLevel(context);
    print('Date: ' +
        user.stats.last.date.toString() +
        " Completions: " +
        user.stats.last.completions.toString());
    await db.statsDatabase.uploadStatistics(context);
  }

  Future<void> unlogHabitCompletion(BuildContext context) async {
    UserModel user =
        Provider.of<UserLocalStorage>(context, listen: false).currentUser;
    UserStatsCalculator userStatsCalculator = UserStatsCalculator(
        Provider.of<HabitManager>(context, listen: false).habits);
    fillInMissingDays(context);

    int currentDayIndex = user.stats.indexWhere((stat) =>
        stat.date.year == DateTime.now().year &&
        stat.date.month == DateTime.now().month &&
        stat.date.day == DateTime.now().day);

    if (currentDayIndex != -1) {
      print('updating current day');
      // Decrement completion count if it's positive
      if (user.stats[currentDayIndex].completions > 0) {
        Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
            'completions',
            user.stats[currentDayIndex].completions - 1,
            context);
        Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
            'confidenceLevel',
            userStatsCalculator.calculateTodaysStatAverage('confidenceLevel'),
            context);
        Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
            'streak',
            userStatsCalculator.calculateTodaysStatAverage('streak').toInt(),
            context);
        Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
            'consistencyFactor',
            userStatsCalculator.calculateTodaysStatAverage('consistencyFactor'),
            context);
        Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
            'difficultyRating',
            userStatsCalculator.calculateTodaysStatAverage('difficultyRating'),
            context);
        Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
            'slopeCompletions',
            userStatsCalculator.calculateOverallSlope('completions'),
            context);
        Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
            'slopeConsistency',
            userStatsCalculator.calculateOverallSlope('consistencyFactor'),
            context);
        Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
            'slopeConfidenceLevel',
            userStatsCalculator.calculateOverallSlope('confidenceLevel'),
            context);
      }
    } else {
      // No need to undo anything if there's no entry for the current day
      print('No entry found for unlogging habit completion.');
    }

    recordAverageConfidenceLevel(context);
    await db.statsDatabase.uploadStatistics(context);
  }

  void recordAverageConfidenceLevel(context) {
    UserModel user =
        Provider.of<UserLocalStorage>(context, listen: false).currentUser;
    double Function(BuildContext) getAverageConfidenceLevel =
        summaryStatsCalculator.getAverageConfidenceLevel;
    int currentDayIndex = user.stats.indexWhere(
      (stat) =>
          stat.date.year == DateTime.now().year &&
          stat.date.month == DateTime.now().month &&
          stat.date.day == DateTime.now().day,
    );
    // If the two dates are more than a minute apart
    if (user.stats.isEmpty) {
      Provider.of<UserLocalStorage>(context, listen: false).addUserStatPoint(
          context,
          StatPoint(
              date: DateTime.now(),
              completions: 0,
              confidenceLevel: 1,
              streak: 0));
    } else if (currentDayIndex == -1) {
      StatPoint newEntry = user.stats.last;
      newEntry.date = DateTime.now();
      newEntry.confidenceLevel = getAverageConfidenceLevel(context);
      Provider.of<UserLocalStorage>(context, listen: false)
          .addUserStatPoint(context, newEntry);
    } else {
      user.stats[currentDayIndex].confidenceLevel =
          getAverageConfidenceLevel(context);
    }
  }

  void fillInMissingDays(context) {
    print('filling in missing days...');
    UserModel user =
        Provider.of<UserLocalStorage>(context, listen: false).currentUser;
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
        day.isBefore(DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day));
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
        Provider.of<UserLocalStorage>(context, listen: false)
            .addUserStatPoint(context, newStatPoint);
      }
    }
  }

  void sortStats(context) {
    UserModel user =
        Provider.of<UserLocalStorage>(context, listen: false).currentUser;
    List<StatPoint> userStats =
        user.stats.map((stat) => stat).toList(); // make a copy
    userStats.sort((a, b) => a.date.compareTo(b.date));
    Provider.of<UserLocalStorage>(context, listen: false)
        .updateUserProperty('stats', userStats);
  }
}
