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
    double difficultyWeight = 1 - (habit.stats.last.difficultyRating / 10);

    if (habit.streak > 0) {
      successStreakBonus =
          math.pow(1.1, habit.streak) as double; // Increase bonus with streak
    }

    print(
        'Confidence level: base: $baseConfidence * consistency: $consistencyFactor * streak bonus: $successStreakBonus}');
    return baseConfidence *
        consistencyFactor *
        successStreakBonus *
        difficultyWeight;
  }

  @override
  double calculateStatSlope(String statisticName, List<StatPoint> stats,
      {int period = 7}) {
    if (stats.isEmpty || period <= 0) {
      return 0.0; // Handle empty data or invalid period
    }

    double slopeCorrection = 0.0; // corrects for high required completions
    if (statisticName == 'completions') {
      slopeCorrection = habit.requiredCompletions.toDouble();
    }

    if (stats.length < period) {
      period = stats.length; // Limit period to available data
    }

    double sumX = 0.0;
    double sumY = 0.0;
    double sumXY = 0.0;
    double sumX2 = 0.0;

    for (int i = stats.length - period; i < stats.length; i++) {
      if (i >= 0) {
        int dayIndex =
            i + 1 - (stats.length - period); // Adjust day index based on period
        double statisticValue =
            getStatisticValue(stats[i], statisticName).toDouble();
        sumX += dayIndex;
        sumY += statisticValue;
        sumXY += dayIndex * statisticValue;
        sumX2 += dayIndex * dayIndex;
      }
    }

    int n = period; // Number of data points in the specified period
    double denominator = n * sumX2 - sumX * sumX;

    // Check for colinearity or potential numerical errors
    if (denominator.abs() < 1e-6) {
      return 0.0; // Handle colinearity or very small denominator
    }

    double slope = (n * sumXY - sumX * sumY) / denominator * slopeCorrection;
    return slope;
  }
}
