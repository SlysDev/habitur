import 'package:flutter/material.dart';
import 'package:habitur/models/data_point.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/providers/summary_statistics_repository.dart';
import 'package:provider/provider.dart';

class StatisticsManager extends ChangeNotifier {
  int totalHabitsCompleted = 0;
  List<DataPoint> displayedConfidenceStats = [];
  int viewScale = 31;

  void recordConfidenceLevel(context) {
    List<DataPoint> confidenceStats =
        Provider.of<SummaryStatisticsRepository>(context).confidenceStats;
    Function(double) getAverageConfidenceLevel =
        Provider.of<SummaryStatisticsRepository>(context)
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
    initStatsDisplay();
  }

  void initStatsDisplay() {
    List<DataPoint> tempArray = [];
    displayedConfidenceStats = [];
    for (DataPoint dataPoint in confidenceStats) {
      if (DateTime.now().difference(dataPoint.date).inDays <= viewScale) {
        tempArray.add(dataPoint);
      }
    }
    if (viewScale == 365) {
      displayedConfidenceStats = monthlyDataGrouping();
    } else if (viewScale == 31) {
      displayedConfidenceStats = dailyDataGrouping();
    } else {
      displayedConfidenceStats = tempArray;
    }
    notifyListeners();
  }

  void weekConfidenceView() {
    viewScale = 7;
    initStatsDisplay();
  }

  void monthConfidenceView() {
    viewScale = 31;
    initStatsDisplay();
  }

  void yearConfidenceView() {
    viewScale = 365;
    initStatsDisplay();
  }

  List<DataPoint> monthlyDataGrouping() {
    // Create a Map to group data points by month
    Map<int, List<DataPoint>> groupedDataPoints = {};
// Group data points by month
    for (DataPoint dataPoint in confidenceStats) {
      int month = dataPoint.date.month;
      if (!groupedDataPoints.containsKey(month)) {
        groupedDataPoints[month] = [];
      }
      groupedDataPoints[month]!.add(dataPoint);
    }
// Calculate the average for each group
    List<DataPoint> monthlyAverages = [];
    groupedDataPoints.forEach((month, confidenceStats) {
      double averageValue = confidenceStats
              .map((dataPoint) => dataPoint.value)
              .reduce((value1, value2) => value1 + value2) /
          confidenceStats.length;

      DateTime averageDate = DateTime(
        confidenceStats
                .map((dataPoint) => dataPoint.date.year)
                .reduce((year1, year2) => year1 + year2) ~/
            confidenceStats.length,
        month,
        1, // Use 1 as the day, you can modify this based on your requirements
      );

      monthlyAverages.add(DataPoint(date: averageDate, value: averageValue));
    });
    return monthlyAverages;
  }

  List<DataPoint> dailyDataGrouping() {
    // Create a Map to group data points by day
    Map<int, List<DataPoint>> groupedDataPoints = {};
// Group data points by day
    for (DataPoint dataPoint in confidenceStats) {
      int day = dataPoint.date.day;
      if (!groupedDataPoints.containsKey(day)) {
        groupedDataPoints[day] = [];
      }
      groupedDataPoints[day]!.add(dataPoint);
    }
// Calculate the average for each group
    List<DataPoint> dailyAverages = [];
    groupedDataPoints.forEach((day, confidenceStats) {
      double averageValue = confidenceStats
              .map((dataPoint) => dataPoint.value)
              .reduce((value1, value2) => value1 + value2) /
          confidenceStats.length;

      DateTime averageDate = DateTime(
        confidenceStats
                .map((dataPoint) => dataPoint.date.month)
                .reduce((month1, month2) => month1 + month2) ~/
            confidenceStats.length,
        day,
        1, // Use 1 as the day, you can modify this based on your requirements
      );

      dailyAverages.add(DataPoint(date: averageDate, value: averageValue));
    });
    return dailyAverages;
  }
}
