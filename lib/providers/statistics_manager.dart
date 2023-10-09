import 'package:flutter/material.dart';
import 'package:habitur/models/data_point.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:provider/provider.dart';

class StatisticsManager extends ChangeNotifier {
  int totalHabitsCompleted = 0;
  List<DataPoint> confidenceStats = [];
  double getAverageStreak(context) {
    int streakCount = 0;
    int streakTotal = 0;
    for (Habit habit
        in Provider.of<HabitManager>(context, listen: false).habits) {
      streakCount++;
      streakTotal += habit.streak;
    }
    return (streakTotal / streakCount);
  }

  Habit longestStreak(context) {
    var longestHabitStreak;
    for (Habit habit
        in Provider.of<HabitManager>(context, listen: false).habits) {
      if (longestHabitStreak ??= null) {
        longestHabitStreak = habit;
      } else if (habit.streak > longestHabitStreak.streak) {
        longestHabitStreak = habit;
      }
    }
    return longestHabitStreak;
  }

  void recordConfidenceLevel(context) {
    // If the two dates are more than a minute apart
    if (confidenceStats.isEmpty) {
      confidenceStats.add(DataPoint(
          date: DateTime.now(), value: getAverageConfidenceLevel(context)));
    } else if (DateTime.now().hour >
        confidenceStats[confidenceStats.length - 1].date.hour) {
      confidenceStats.add(DataPoint(
          date: DateTime.now(), value: getAverageConfidenceLevel(context)));
    }
    // Otherwise, update the most recent entry
    else {
      confidenceStats[confidenceStats.length - 1] = DataPoint(
          date: DateTime.now(), value: getAverageConfidenceLevel(context));
    }
  }

  double getAverageConfidenceLevel(context) {
    int habitNumber = 0;
    double totalHabitConfidence = 0;
    for (Habit habit
        in Provider.of<HabitManager>(context, listen: false).habits) {
      totalHabitConfidence += habit.confidenceLevel;
      habitNumber++;
    }
    return totalHabitConfidence / habitNumber;
  }
}
