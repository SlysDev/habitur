import 'package:flutter/foundation.dart';
import 'package:habitur/models/stat_point.dart';
import 'dart:math' as math;

/// Base service class for all stats-related calculations
class BaseStatsService with ChangeNotifier {
  double calculateStatChange(List<StatPoint> stats, String statisticName) {
    if (stats.length < 2) return 0.0;
    return getStatisticValue(stats.last, statisticName) -
        getStatisticValue(stats[stats.length - 2], statisticName).toDouble();
  }

  double calculateAverageValueForStat(
      List<StatPoint> stats, String statisticName,
      {int period = 7}) {
    if (stats.isEmpty || period <= 0) return 0.0;

    if (stats.length < period) {
      period = stats.length;
    }

    double sum = 0.0;
    for (int i = stats.length - period; i < stats.length; i++) {
      if (i >= 0) {
        sum += getStatisticValue(stats[i], statisticName).toDouble();
      }
    }
    return sum / period;
  }

  double calculatePercentChangeForStat(
      String statisticName, List<StatPoint> stats,
      {int period = 7}) {
    if (stats.isEmpty || period <= 0) return 0.0;

    if (stats.length < period) {
      period = stats.length;
    }

    int startIndex = stats.length - period;
    double startValue =
        getStatisticValue(stats[startIndex], statisticName).toDouble();
    double endValue =
        getStatisticValue(stats[stats.length - 1], statisticName).toDouble();

    if (startValue == 0.0) return 0.0;

    return ((endValue - startValue) / startValue) * 100.0;
  }

  double calculateConsistencyFactor(List<StatPoint> stats, int targetGoal,
      {int period = 7}) {
    if (stats.isEmpty || period <= 0) return 1;

    double totalWeight = 0.0;
    double weightedCompletionsSum = 0.0;
    List<double> weights =
        List.generate(period, (i) => math.pow(0.75, i) as double);

    for (int i = 0; i < period; i++) {
      if (i < stats.length) {
        weightedCompletionsSum +=
            (stats[i].completions / targetGoal).floor() * weights[i];
        totalWeight += weights[i];
      }
    }

    return totalWeight > 0.0 ? weightedCompletionsSum / totalWeight : 0.0;
  }

  double calculateDifficultyWeight(List<StatPoint> stats,
      {double decayRate = 0.8}) {
    if (stats.isEmpty) return 1;

    double weightSum = 0;
    double ratingSum = 0;

    for (int i = 0; i < stats.length; i++) {
      double weight = math.pow(decayRate, i) as double;
      ratingSum += stats[i].difficultyRating * weight;
      weightSum += weight;
    }

    return weightSum > 0 ? 1 - (ratingSum / weightSum) / 10 : 1;
  }

  double calculateStatSlope(String statisticName, List<StatPoint> stats,
      {int period = 7}) {
    if (stats.isEmpty || period <= 0) return 0.0;

    if (stats.length < period) {
      period = stats.length;
    }

    double sumX = 0.0;
    double sumY = 0.0;
    double sumXY = 0.0;
    double sumX2 = 0.0;

    for (int i = stats.length - period; i < stats.length; i++) {
      if (i >= 0) {
        int dayIndex = i + 1 - (stats.length - period);
        double statisticValue =
            getStatisticValue(stats[i], statisticName).toDouble();
        sumX += dayIndex;
        sumY += statisticValue;
        sumXY += dayIndex * statisticValue;
        sumX2 += dayIndex * dayIndex;
      }
    }

    int n = period;
    double denominator = n * sumX2 - sumX * sumX;

    if (denominator.abs() < 1e-6) return 0.0;

    return (n * sumXY - sumX * sumY) / denominator;
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

  double getStatisticValue(StatPoint point, String statisticName) {
    switch (statisticName) {
      case 'completions':
        return point.completions.toDouble();
      case 'difficulty':
        return point.difficultyRating.toDouble();
      default:
        return 0.0;
    }
  }

  // New time-based filtering methods
  List<StatPoint> filterStatsByTimeRange(
      List<StatPoint> stats, DateTime start, DateTime end) {
    return stats
        .where((stat) => stat.date.isAfter(start) && stat.date.isBefore(end))
        .toList();
  }

  // Moving average calculation
  double calculateMovingAverage(List<StatPoint> stats, String statisticName,
      {int windowSize = 7}) {
    if (stats.length < windowSize)
      return calculateAverageValueForStat(stats, statisticName);

    List<double> movingAverages = [];
    for (int i = windowSize; i <= stats.length; i++) {
      var window = stats.sublist(i - windowSize, i);
      movingAverages.add(calculateAverageValueForStat(window, statisticName));
    }

    return movingAverages.isEmpty ? 0.0 : movingAverages.last;
  }

  // Standard deviation calculation
  double calculateStandardDeviation(
      List<StatPoint> stats, String statisticName) {
    if (stats.isEmpty) return 0.0;

    double mean = calculateAverageValueForStat(stats, statisticName);
    double sumSquaredDiff = stats.fold(0.0, (sum, stat) {
      double diff = getStatisticValue(stat, statisticName) - mean;
      return sum + (diff * diff);
    });

    return math.sqrt(sumSquaredDiff / stats.length);
  }

  // Outlier detection using Z-score
  List<StatPoint> detectOutliers(List<StatPoint> stats, String statisticName,
      {double threshold = 2.0}) {
    double mean = calculateAverageValueForStat(stats, statisticName);
    double stdDev = calculateStandardDeviation(stats, statisticName);

    return stats.where((stat) {
      double value = getStatisticValue(stat, statisticName);
      double zScore = (value - mean) / (stdDev == 0 ? 1 : stdDev);
      return zScore.abs() > threshold;
    }).toList();
  }

  // Data normalization (Min-Max scaling)
  double normalizeValue(
      double value, List<StatPoint> stats, String statisticName) {
    if (stats.isEmpty) return 0.0;

    var values = stats.map((s) => getStatisticValue(s, statisticName)).toList();
    double min = values.reduce(math.min);
    double max = values.reduce(math.max);

    if (max == min) return 0.0;
    return (value - min) / (max - min);
  }
}
