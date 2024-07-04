import 'package:flutter/material.dart';
import 'package:habitur/models/data_point.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/stat_point.dart';
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
                    .getAverageStreak(context) as int);
        statPoints.add(newStatPoint);
      } else {
        StatPoint newStatPoint = statPoints.last;
        newStatPoint.date = DateTime.now();
        newStatPoint.completions = 1;
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

    // Check if there's an entry for the current day
    int currentDayIndex = statPoints.indexWhere((stat) =>
        stat.date.year == DateTime.now().year &&
        stat.date.month == DateTime.now().month &&
        stat.date.day == DateTime.now().day);

    if (currentDayIndex != -1) {
      // If there's an entry for the current day, decrement the completion count
      if (statPoints[currentDayIndex].completions > 0) {
        statPoints[currentDayIndex].completions--;
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
}
