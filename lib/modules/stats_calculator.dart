import 'package:flutter/material.dart';
import 'package:habitur/models/data_point.dart';
import 'package:habitur/models/habit.dart';
import 'dart:math' as math;

import 'package:habitur/models/stat_point.dart';

class StatsCalculator {
  StatsCalculator();

  double calculateStatChange(List<StatPoint> stats, String statisticName) {
    if (stats.length < 2) return 0.0;
    return getStatisticValue(stats.last, statisticName) -
        getStatisticValue(stats[stats.length - 2], statisticName).toDouble();
  }

  double calculateAverageValueForStat(
      String statisticName, List<StatPoint> stats,
      {int period = 7}) {
    if (stats.isEmpty || period <= 0) {
      return 0.0; // Handle empty data or invalid period
    }

    double sum = 0.0;
    for (int i = stats.length - period; i < stats.length; i++) {
      if (i >= 0) {
        double statisticValue = getStatisticValue(stats[i], statisticName);
        sum += statisticValue;
      }
    }
    return sum / period;
  }

  double calculatePercentChangeForStat(
      String statisticName, List<StatPoint> stats,
      {int period = 7}) {
    if (stats.isEmpty || period <= 0) {
      return 0.0; // Handle empty data or invalid period
    }

    if (stats.length < period) {
      period = stats.length; // Limit period to available data
    }

    int startIndex = stats.length - period;
    double startValue =
        getStatisticValue(stats[startIndex], statisticName).toDouble();
    double endValue =
        getStatisticValue(stats[stats.length - 1], statisticName).toDouble();

    if (startValue == 0.0) {
      // Avoid division by zero (consider handling very small start values)
      return 0.0;
    }
    debugPrint("startValue: $startValue, endValue: $endValue");

    return ((endValue - startValue) / startValue) * 100.0;
  }

  double calculateAverageCompletionsPerWeek(List<StatPoint> stats) {
    if (stats.isEmpty) return 0.0;
    int totalWeeks = (stats.length / 7).ceil(); // Assuming 7 days in a week
    int totalCompletions = 0;
    for (StatPoint statPoint in stats) {
      totalCompletions += statPoint.completions;
    }
    return totalCompletions / totalWeeks;
  }

  String formatAverage(double value) => value.toStringAsFixed(1);

  double calculateConsistencyFactor(
      List<StatPoint> stats, int requiredCompletions,
      {int period = 7}) {
    if (stats.isEmpty || period <= 0) {
      return 1;
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
            (stats[i].completions / requiredCompletions).floor() * weights[i];
        totalWeight += weights[i];
      }
    }

    // Avoid division by zero
    return totalWeight > 0.0 ? weightedCompletionsSum / totalWeight : 0.0;
  }

  double calculateDifficultyWeight(List<StatPoint> stats,
      {double decayRate = 0.8}) {
    double weightSum = 0;
    double ratingSum = 0;

    if (stats.isEmpty) {
      return 1;
    }

    for (int i = 0; i < stats.length; i++) {
      double weight = math.pow(decayRate, i) as double;
      ratingSum += stats[i].difficultyRating * weight;
      weightSum += weight;
    }

    if (weightSum == 0) {
      return 1; // Handle empty stats
    }

    return 1 - (ratingSum / weightSum) / 10;
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

  double calculateRecentCompletionTrend(List<StatPoint> stats) {
    if (stats.length < 14) return 0.0;
    double recentAverage =
        calculateAverageCompletionsPerWeek(stats.sublist(stats.length - 7));
    double previousAverage =
        calculateAverageCompletionsPerWeek(stats.sublist(0, stats.length - 7));
    return recentAverage - previousAverage;
  }

  // Slope Calculations

  double calculateStatSlope(String statisticName, List<StatPoint> stats,
      {int period = 7}) {
    if (stats.isEmpty || period <= 0) {
      return 0.0; // Handle empty data or invalid period
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
      case 'streak':
        return statPoint.streak;
      default:
        throw Exception('Invalid statistic name: $statisticName');
    }
  }

  Map<String, dynamic> findWorstSlope(List<StatPoint> stats, {int period = 7}) {
    if (stats.isEmpty) {
      return {'name': '', 'value': null}; // No data for slope calculation
    }

    String worstSlopeName = '';
    double worstSlopeValue =
        double.infinity; // Initialize with positive infinity
    bool isZeroChange = true;

    for (String statisticName in [
      'completions',
      'confidenceLevel',
      'difficultyRating',
      'consistencyFactor'
    ]) {
      double slope = calculateStatSlope(statisticName, stats, period: period);
      if (statisticName == 'difficultyRating') {
        slope = slope * -1;
      }
      if (slope < worstSlopeValue) {
        worstSlopeName = statisticName;
        worstSlopeValue = slope;
      }
      if (slope != 0.0) {
        isZeroChange = false;
      }
    }
    return {
      'name': worstSlopeName,
      'value': isZeroChange ? null : worstSlopeValue
    };
  }
}
