import 'package:flutter/material.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:provider/provider.dart';

class StatisticsManager extends ChangeNotifier {
  int totalHabitsCompleted = 0;
  double getAverageStreak(context) {
    int streakCount = 0;
    int streakTotal = 0;
    for (Habit habit in Provider.of<HabitManager>(context).habits) {
      streakCount++;
      streakTotal += habit.streak;
    }
    return (streakTotal / streakCount);
  }

  Habit longestStreak(context) {
    var longestHabitStreak;
    for (Habit habit in Provider.of<HabitManager>(context).habits) {
      if (longestHabitStreak ??= null) {
        longestHabitStreak = habit;
      } else if (habit.streak > longestHabitStreak.streak) {
        longestHabitStreak = habit;
      }
    }
    return longestHabitStreak;
  }

  double getAverageConfidenceLevel(context) {
    int habitNumber = 0;
    double totalHabitConfidence = 0;
    for (Habit habit in Provider.of<HabitManager>(context).habits) {
      totalHabitConfidence += habit.confidenceLevel;
      habitNumber++;
    }
    return totalHabitConfidence / habitNumber;
  }
}
