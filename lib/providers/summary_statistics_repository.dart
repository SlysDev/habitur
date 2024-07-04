import 'package:flutter/material.dart';
import 'package:habitur/models/data_point.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:provider/provider.dart';

class SummaryStatisticsRepository extends ChangeNotifier {
  List<StatPoint> statPoints = [];
  List<DataPoint> confidenceStats = [];
  int totalHabitsCompleted = 0;

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

  double getLongestStreak(context) {
    var longestStreakHabit;
    for (Habit habit
        in Provider.of<HabitManager>(context, listen: false).habits) {
      if (longestStreakHabit ??= null) {
        longestStreakHabit = habit;
      } else if (habit.streak > longestStreakHabit.streak) {
        longestStreakHabit = habit;
      }
    }
    return longestStreakHabit.streak;
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
