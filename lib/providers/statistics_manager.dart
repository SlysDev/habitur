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
    confidenceStats.add(DataPoint(
        date: DateTime.now(), value: getAverageConfidenceLevel(context)));
    print(confidenceStats);
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
