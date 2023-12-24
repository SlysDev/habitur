import 'package:flutter/material.dart';
import 'package:habitur/models/data_point.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/providers/statistics_display_manager.dart';
import 'package:habitur/providers/summary_statistics_repository.dart';
import 'package:provider/provider.dart';

class StatisticsRecorder {
  void logHabitCompletion(BuildContext context) {
    List<DataPoint> completionStats =
        Provider.of<SummaryStatisticsRepository>(context, listen: false)
            .completionStats;

    // Check if there's an entry for the current day
    int currentDayIndex = completionStats.indexWhere(
      (dataPoint) =>
          dataPoint.date.year == DateTime.now().year &&
          dataPoint.date.month == DateTime.now().month &&
          dataPoint.date.day == DateTime.now().day,
    );

    if (currentDayIndex != -1) {
      // If there's an entry for the current day, update the completion count
      completionStats[currentDayIndex] = DataPoint(
        date: DateTime.now(),
        value: completionStats[currentDayIndex].value + 1,
      );
    } else {
      // If there's no entry for the current day, add a new entry
      completionStats.add(DataPoint(
        date: DateTime.now(),
        value: 1,
      ));
    }

    // Notify the display manager to update
    recordAverageConfidenceLevel(context);
    Provider.of<StatisticsDisplayManager>(context, listen: false)
        .initStatsDisplay(context);
    print('Date: ' +
        completionStats.last.date.toString() +
        " Value: " +
        completionStats.last.value.toString());
  }

  void recordAverageConfidenceLevel(context) {
    List<DataPoint> confidenceStats =
        Provider.of<SummaryStatisticsRepository>(context, listen: false)
            .confidenceStats;
    double Function(BuildContext) getAverageConfidenceLevel =
        Provider.of<SummaryStatisticsRepository>(context, listen: false)
            .getAverageConfidenceLevel;
    // If the two dates are more than a minute apart
    if (confidenceStats.isEmpty) {
      confidenceStats.add(DataPoint(
          date: DateTime.now(), value: getAverageConfidenceLevel(context)));
    } else if (DateTime.now().second >
        confidenceStats[confidenceStats.length - 1].date.second) {
      confidenceStats.add(DataPoint(
          date: DateTime.now(), value: getAverageConfidenceLevel(context)));
    }
    // Otherwise, update the most recent entry
    else {
      confidenceStats[confidenceStats.length - 1] = DataPoint(
          date: DateTime.now(), value: getAverageConfidenceLevel(context));
    }
    Provider.of<StatisticsDisplayManager>(context, listen: false)
        .initStatsDisplay(context);
  }
}
