import 'package:habitur/models/data_point.dart';
import 'package:habitur/models/habit.dart';
import 'dart:math' as math;

import 'package:habitur/models/stat_point.dart';

class HabitStatisticsCalculator {
  final Habit habit;

  HabitStatisticsCalculator(this.habit);

  double calculateConfidenceChange({List<StatPoint>? stats}) {
    if (stats == null) {
      stats = habit.stats;
    }
    if (stats.length < 2) return 0.0;
    return stats.last.confidenceLevel - stats[stats.length - 2].confidenceLevel;
  }

  double calculateAverageValueForStat(String statisticName, {int period = 7}) {
    if (habit.stats.isEmpty || period <= 0) {
      return 0.0; // Handle empty data or invalid period
    }

    double sum = 0.0;
    for (int i = habit.stats.length - period; i < habit.stats.length; i++) {
      if (i >= 0) {
        double statisticValue =
            getStatisticValue(habit.stats[i], statisticName);
        sum += statisticValue;
      }
    }
    return sum / period;
  }

  double calculatePercentChangeForStat(String statisticName, {int period = 7}) {
    if (habit.stats.isEmpty || period <= 0) {
      return 0.0; // Handle empty data or invalid period
    }

    if (habit.stats.length < period) {
      period = habit.stats.length; // Limit period to available data
    }

    int startIndex = habit.stats.length - period;
    double startValue =
        getStatisticValue(habit.stats[startIndex], statisticName).toDouble();
    double endValue =
        getStatisticValue(habit.stats[habit.stats.length - 1], statisticName)
            .toDouble();

    if (startValue == 0.0) {
      // Avoid division by zero (consider handling very small start values)
      return 0.0;
    }

    return ((endValue - startValue) / startValue) * 100.0;
  }

  double calculateAverageCompletionsPerWeek({List<StatPoint>? stats}) {
    if (stats == null) {
      stats = habit.stats;
    }
    if (stats.isEmpty) return 0.0;
    int totalWeeks = (stats.length / 7).ceil(); // Assuming 7 days in a week
    return habit.totalCompletions / totalWeeks;
  }

  String formatAverage(double value) => value.toStringAsFixed(1);

  double calculateConsistencyFactor({List<StatPoint>? stats, int period = 7}) {
    if (stats == null) {
      stats = habit.stats;
    }
    if (stats.isEmpty || period <= 0) {
      return 0.0;
    }

    double totalWeight = 0.0;
    double weightedCompletionsSum = 0.0;

    // Define weighting scheme (prioritizing recent days)
    List<double> weights = List.generate(
        period,
        (i) => math.pow(0.75, i)
            as double); // Weights decrease exponentially with older days (0.75 is the decay factor)

    for (int i = 0; i < period; i++) {
      if (i < stats.length) {
        weightedCompletionsSum +=
            (stats[i].completions / habit.requiredCompletions).floor() *
                weights[i];
        totalWeight += weights[i];
      }
    }

    // Avoid division by zero
    return totalWeight > 0.0 ? weightedCompletionsSum / totalWeight : 0.0;
  }

  // double calculateCompletionConsistency({int periodInDays = -1}) {
  //   if (periodInDays == -1) {
  //     periodInDays = DateTime.now().difference(habit.dateCreated).inDays;
  //   }
  //   if (habit.stats.isEmpty || periodInDays <= 0) return 0.0;

  //   int completedDays = 0;
  //   int i = habit.stats.length - 1;
  //   int j = i - periodInDays;
  //   while (i >= 0) {
  //     if (i == j) {
  //       break;
  //     }
  //     StatPoint statPoint = habit.stats[i];
  //     if (statPoint.completions == habit.requiredCompletions) {
  //       completedDays++;
  //     }
  //     i--;
  //   }

  //   // Check if there are any completions before dividing
  //   return completedDays > 0 ? (completedDays / periodInDays) : 0.0;
  // }

  double calculateRecentCompletionTrend() {
    if (habit.stats.length < 14) return 0.0;
    double recentAverage = calculateAverageCompletionsPerWeek(
        stats: habit.stats.sublist(habit.stats.length - 7));
    double previousAverage = calculateAverageCompletionsPerWeek(
        stats: habit.stats.sublist(0, habit.stats.length - 7));
    return recentAverage - previousAverage;
  }

  int getLongestStreakSinceLastLapse() {
    if (habit.stats.isEmpty) return 0;
    int currentStreak = 0;
    return math.max(habit.highestStreak,
        currentStreak); // Account for potential streak at the end
  }

  double calculateConfidenceLevel() {
    double baseConfidence = 1;
    double consistencyFactor = calculateConsistencyFactor();
    double successStreakBonus = 1.0;

    if (habit.streak > 0) {
      successStreakBonus =
          math.pow(1.1, habit.streak) as double; // Increase bonus with streak
    }

    print(
        'Confidence level: base: $baseConfidence * consistency: $consistencyFactor * streak bonus: $successStreakBonus}');
    return baseConfidence * consistencyFactor * successStreakBonus;
  }

  // Slope Calculations

  double calculateStatSlope(String statisticName, {int period = 7}) {
    if (habit.stats.isEmpty || period <= 0) {
      return 0.0; // Handle empty data or invalid period
    }

    if (habit.stats.length < period) {
      period = habit.stats.length; // Limit period to available data
    }

    double sumX = 0.0;
    double sumY = 0.0;
    double sumXY = 0.0;
    double sumX2 = 0.0;

    for (int i = habit.stats.length - period; i < habit.stats.length; i++) {
      if (i >= 0) {
        int dayIndex = i +
            1 -
            (habit.stats.length - period); // Adjust day index based on period
        double statisticValue =
            getStatisticValue(habit.stats[i], statisticName).toDouble();
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

    double slope = (n * sumXY - sumX * sumY) / denominator;
    return slope;
  }

  dynamic getStatisticValue(StatPoint statPoint, String statisticName) {
    switch (statisticName) {
      case 'completions':
        return statPoint.completions;
      case 'confidenceLevel':
        return statPoint.confidenceLevel;
      case 'consistencyFactor':
        return statPoint.consistencyFactor;
      case 'difficultyRating':
        return statPoint.difficultyRating;
      default:
        throw Exception('Invalid statistic name: $statisticName');
    }
  }

  Map<String, dynamic> findWorstSlope({int period = 7}) {
    if (habit.stats.isEmpty) {
      return {'name': '', 'value': 0.0}; // No data for slope calculation
    }

    String worstSlopeName = '';
    double worstSlopeValue =
        double.infinity; // Initialize with positive infinity

    for (String statisticName in [
      'completions',
      'confidenceLevel',
      'difficultyRating',
      'consistencyFactor'
    ]) {
      double slope = calculateStatSlope(statisticName, period: period);
      if (slope < worstSlopeValue) {
        worstSlopeName = statisticName;
        worstSlopeValue = slope;
      }
    }

    return {'name': worstSlopeName, 'value': worstSlopeValue};
  }
}
