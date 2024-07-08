import 'package:habitur/models/data_point.dart';
import 'package:habitur/models/habit.dart';
import 'dart:math' as math;

import 'package:habitur/models/stat_point.dart';
import 'package:habitur/modules/stats_calculator.dart';

class HabitStatisticsCalculator extends StatisticsCalculator {
  final Habit habit;

  HabitStatisticsCalculator(this.habit);

  int getLongestStreakSinceLastLapse(List<StatPoint> stats) {
    if (stats.isEmpty) return 0;
    int currentStreak = 0;
    return math.max(habit.highestStreak,
        currentStreak); // Account for potential streak at the end
  }

  double calculateConfidenceLevel() {
    double baseConfidence = 1;
    double consistencyFactor =
        calculateConsistencyFactor(habit.stats, habit.requiredCompletions);
    double successStreakBonus = 1.0;

    if (habit.streak > 0) {
      successStreakBonus =
          math.pow(1.1, habit.streak) as double; // Increase bonus with streak
    }

    print(
        'Confidence level: base: $baseConfidence * consistency: $consistencyFactor * streak bonus: $successStreakBonus}');
    return baseConfidence * consistencyFactor * successStreakBonus;
  }
}
