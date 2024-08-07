import 'package:flutter/material.dart';
import 'package:habitur/models/data_point.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/modules/summary_stats_calculator.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/providers/statistics_display_manager.dart';
import 'package:habitur/providers/summary_statistics_repository.dart';
import 'package:provider/provider.dart';

class SummaryStatisticsRecorder {
  void logHabitCompletion(BuildContext context) {
    List<StatPoint> statPoints =
        Provider.of<SummaryStatisticsRepository>(context, listen: false)
            .statPoints;
    SummaryStatisticsCalculator summaryStatsCalculator =
        SummaryStatisticsCalculator(
            Provider.of<HabitManager>(context, listen: false).habits);
    fillInMissingDays(context);
    sortStats(context);

    // Check if there's an entry for the current day
    int currentDayIndex = statPoints.indexWhere(
      (stat) =>
          stat.date.year == DateTime.now().year &&
          stat.date.month == DateTime.now().month &&
          stat.date.day == DateTime.now().day,
    );

    if (currentDayIndex != -1) {
      // If there's an entry for the current day, update the completion count
      statPoints[currentDayIndex].date = DateTime.now();
      statPoints[currentDayIndex].completions += 1;
      statPoints[currentDayIndex].confidenceLevel =
          summaryStatsCalculator.calculateTodaysStatAverage('confidenceLevel');
      statPoints[currentDayIndex].streak =
          summaryStatsCalculator.calculateTodaysStatAverage('streak').toInt();
      statPoints[currentDayIndex].consistencyFactor = summaryStatsCalculator
          .calculateTodaysStatAverage('consistencyFactor');
      statPoints[currentDayIndex].difficultyRating =
          summaryStatsCalculator.calculateTodaysStatAverage('difficultyRating');
      statPoints[currentDayIndex].slopeCompletions =
          summaryStatsCalculator.calculateOverallSlope('completions');
      statPoints[currentDayIndex].slopeConsistency =
          summaryStatsCalculator.calculateOverallSlope('consistencyFactor');
      statPoints[currentDayIndex].slopeConfidenceLevel =
          summaryStatsCalculator.calculateOverallSlope('confidenceLevel');
    } else {
      if (statPoints.isEmpty) {
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
        statPoints.add(newStatPoint);
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
        statPoints.add(newStatPoint);
      }
      // If there's no entry for the current day, add a new entry
      StatPoint newEntry = statPoints.last;
      newEntry.date = DateTime.now();
      newEntry.completions = 1;
      statPoints.add(newEntry);
    }

    // Notify the display manager to update
    recordAverageConfidenceLevel(context);
    print('Date: ' +
        statPoints.last.date.toString() +
        " Completions: " +
        statPoints.last.completions.toString());
    Provider.of<Database>(context, listen: false).uploadStatistics(context);
  }

  void unlogHabitCompletion(BuildContext context) {
    List<StatPoint> statPoints =
        Provider.of<SummaryStatisticsRepository>(context, listen: false)
            .statPoints;
    SummaryStatisticsCalculator summaryStatsCalculator =
        SummaryStatisticsCalculator(
            Provider.of<HabitManager>(context, listen: false).habits);
    fillInMissingDays(context);

    // Check if there's an entry for the current day
    int currentDayIndex = statPoints.indexWhere((stat) =>
        stat.date.year == DateTime.now().year &&
        stat.date.month == DateTime.now().month &&
        stat.date.day == DateTime.now().day);

    if (currentDayIndex != -1) {
      // If there's an entry for the current day, decrement the completion count
      if (statPoints[currentDayIndex].completions > 0) {
        statPoints[currentDayIndex].completions--;
        statPoints[currentDayIndex].confidenceLevel = summaryStatsCalculator
            .calculateTodaysStatAverage('confidenceLevel');
        statPoints[currentDayIndex].streak =
            summaryStatsCalculator.calculateTodaysStatAverage('streak').toInt();
        statPoints[currentDayIndex].consistencyFactor = summaryStatsCalculator
            .calculateTodaysStatAverage('consistencyFactor');
        statPoints[currentDayIndex].difficultyRating = summaryStatsCalculator
            .calculateTodaysStatAverage('difficultyRating');
        statPoints[currentDayIndex].slopeCompletions =
            summaryStatsCalculator.calculateOverallSlope('completions');
        statPoints[currentDayIndex].slopeConsistency =
            summaryStatsCalculator.calculateOverallSlope('consistencyFactor');
        statPoints[currentDayIndex].slopeConfidenceLevel =
            summaryStatsCalculator.calculateOverallSlope('confidenceLevel');
      }
    } else {
      // If there's no entry for the current day, no need to undo anything
      print('No entry found for unlogging habit completion.');
    }

    // Notify the display manager to update (optional)
    recordAverageConfidenceLevel(context);

    // Update statistics in database (optional)
    Provider.of<Database>(context, listen: false).uploadStatistics(context);
  }

  void recordAverageConfidenceLevel(context) {
    List<StatPoint> statPoints =
        Provider.of<SummaryStatisticsRepository>(context, listen: false)
            .statPoints;
    double Function(BuildContext) getAverageConfidenceLevel =
        Provider.of<SummaryStatisticsRepository>(context, listen: false)
            .getAverageConfidenceLevel;
    int currentDayIndex = statPoints.indexWhere(
      (stat) =>
          stat.date.year == DateTime.now().year &&
          stat.date.month == DateTime.now().month &&
          stat.date.day == DateTime.now().day,
    );
    // If the two dates are more than a minute apart
    if (statPoints.isEmpty) {
      statPoints.add(StatPoint(
          date: DateTime.now(), completions: 0, confidenceLevel: 1, streak: 0));
    } else if (currentDayIndex == -1) {
      StatPoint newEntry = statPoints.last;
      newEntry.date = DateTime.now();
      newEntry.confidenceLevel = getAverageConfidenceLevel(context);
      statPoints.add(newEntry);
    } else {
      statPoints[currentDayIndex].confidenceLevel =
          getAverageConfidenceLevel(context);
    }
  }

  void fillInMissingDays(context) {
    SummaryStatisticsCalculator statsCalculator = SummaryStatisticsCalculator(
        Provider.of<HabitManager>(context, listen: false).habits);
    List<StatPoint> statPoints =
        Provider.of<SummaryStatisticsRepository>(context, listen: false)
            .statPoints;
    // Create a DateTime object for the start date of the habit
    if (statPoints.isEmpty) {
      return;
    }
    DateTime startDate = statPoints.first.date;

    // Iterate through each day from the start date to the current date
    for (DateTime day =
            DateTime(startDate.year, startDate.month, startDate.day);
        day.isBefore(DateTime.now());
        day = day.add(Duration(days: 1))) {
      // Check if a StatPoint already exists for the current day
      if (statPoints.indexWhere((dataPoint) =>
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
        statPoints.add(newStatPoint);
      }
    }
  }

  void sortStats(context) {
    List<StatPoint> statPoints =
        Provider.of<SummaryStatisticsRepository>(context, listen: false)
            .statPoints;
    statPoints.sort((a, b) => a.date.compareTo(b.date));
  }
}
