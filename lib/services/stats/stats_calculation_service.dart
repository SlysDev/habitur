import 'package:flutter/material.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/habit_interface.dart';
import 'package:habitur/models/stat_point.dart';
import 'dart:math' as math;

import 'package:habitur/util_functions.dart';

class StatsCalculationService {
  /// Calculates the change in a statistic between the last two stat points.
  ///
  /// - `stats`: A list of `StatPoint` objects.
  /// - `statisticName`: The name of the statistic to calculate the change for.
  ///
  /// Returns the difference in the specified statistic as a `double`.
  double calculateStatChange(List<StatPoint> stats, String statisticName) {
    if (stats.length < 2) return 0.0;
    return stats.last.getStatByName(statisticName) -
        stats[stats.length - 2].getStatByName(statisticName);
  }

  /// Calculates the average value of a statistic over a specified period.
  ///
  /// - `stats`: A list of `StatPoint` objects.
  /// - `statisticName`: The name of the statistic to calculate the average for.
  /// - `period`: (Optional) The number of most recent stat points to include (defaults to 7).
  ///
  /// Returns the average value of the specified statistic over the period as a `double`.
  double calculateAverageValueForStat(
      List<StatPoint> stats, String statisticName,
      {int period = 7}) {
    debugPrint(
        '>>>Calculating average for $statisticName with period: $period');
    debugPrint('>>>Here are the stats for reference:');
    stats.forEach((stat) {
      debugPrint('>>>${stat.date}: ${stat.getStatByName('statisticName')}');
    });

    if (stats.isEmpty || period <= 0) {
      debugPrint(
          '>>>Stats are empty or period is less than 1 for calculating average value for $statisticName');
      return 0.0;
    }

    if (stats.length < period) {
      debugPrint(
          '>>>Adjusting period from $period to ${stats.length} due to insufficient data points');
      period = stats.length;
    }

    double sum = 0.0;
    for (int i = stats.length - period; i < stats.length; i++) {
      if (i >= 0) {
        double value = stats[i].getStatByName(statisticName).toDouble();
        sum += value;
        debugPrint('>>>Adding value: $value at index $i, running sum: $sum');
      }
    }

    double average = sum / period;
    debugPrint('>>>Final calculation: sum($sum) / period($period) = $average');
    return average;
  }

  /// Calculates the percent change of a statistic over a specified period.
  ///
  /// - `statisticName`: The name of the statistic to calculate the percent change for.
  /// - `stats`: A list of `StatPoint` objects.
  /// - `period`: (Optional) The number of most recent stat points to include (defaults to 7).
  ///
  /// Returns the percent change of the specified statistic over the period as a `double`.
  double calculatePercentChangeForStat(
      String statisticName, List<StatPoint> stats,
      {int period = 7}) {
    if (stats.isEmpty || period <= 0) return 0.0;

    if (stats.length < period) {
      period = stats.length;
    }

    int startIndex = stats.length - period;
    double startValue =
        stats[startIndex].getStatByName(statisticName).toDouble();
    double endValue =
        stats[stats.length - 1].getStatByName(statisticName).toDouble();

    if (startValue == 0.0) return 0.0;

    return ((endValue - startValue) / startValue) * 100.0;
  }

  /// Calculates the consistency factor over a specified period.
  ///
  /// - `stats`: A list of `StatPoint` objects.
  /// - `targetGoal`: The target goal for completions.
  /// - `period`: (Optional) The number of most recent stat points to include (defaults to 7).
  ///
  /// Returns the consistency factor as a `double` between 0.0 and 1.0 representing consistency.
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

  /// Calculates the difficulty weight based on past difficulty ratings.
  ///
  /// - `stats`: A list of `StatPoint` objects.
  /// - `decayRate`: (Optional) The rate at which older data is discounted (defaults to 0.8).
  ///
  /// Returns the difficulty weight as a `double` where higher values represent lower difficulty.
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

  /// Calculates the slope (rate of change) of a statistic over a specified period.
  ///
  /// - `statisticName`: The name of the statistic to calculate the slope for.
  /// - `stats`: A list of `StatPoint` objects.
  /// - `period`: (Optional) The number of most recent stat points to include (defaults to 7).
  ///
  /// Returns the slope of the specified statistic as a `double`.
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
            stats[i].getStatByName(statisticName).toDouble();
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

  /// Finds the statistic with the worst (most negative) slope over a specified period.
  ///
  /// - `stats`: A list of `StatPoint` objects.
  /// - `period`: (Optional) The number of most recent stat points to analyze (defaults to 7).
  ///
  /// Returns a `Map` with 'name' of the statistic and 'value' of the slope (`double`).
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

  /// Filters the list of stats to include only those within a specific time range.
  ///
  /// - `stats`: A list of `StatPoint` objects.
  /// - `start`: The start `DateTime` of the range.
  /// - `end`: The end `DateTime` of the range.
  ///
  /// Returns a list of `StatPoint` objects within the specified time range.
  List<StatPoint> filterStatsByTimeRange(
      List<StatPoint> stats, DateTime start, DateTime end) {
    return stats
        .where((stat) => stat.date.isAfter(start) && stat.date.isBefore(end))
        .toList();
  }

  /// Calculates the moving average of a statistic over a specified window size.
  ///
  /// - `stats`: A list of `StatPoint` objects.
  /// - `statisticName`: The name of the statistic to calculate the moving average for.
  /// - `windowSize`: (Optional) The number of stat points to include in each average (defaults to 7).
  ///
  /// Returns the most recent moving average as a `double`.
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

  /// Calculates the standard deviation of a statistic.
  ///
  /// - `stats`: A list of `StatPoint` objects.
  /// - `statisticName`: The name of the statistic to calculate the standard deviation for.
  ///
  /// Returns the standard deviation as a `double`.
  double calculateStandardDeviation(
      List<StatPoint> stats, String statisticName) {
    if (stats.isEmpty) return 0.0;

    double mean = calculateAverageValueForStat(stats, statisticName);
    double sumSquaredDiff = stats.fold(0.0, (sum, stat) {
      double diff = stat.getStatByName(statisticName) - mean;
      return sum + (diff * diff);
    });

    return math.sqrt(sumSquaredDiff / stats.length);
  }

  /// Detects outliers in a statistic using the Z-score method.
  ///
  /// - `stats`: A list of `StatPoint` objects.
  /// - `statisticName`: The name of the statistic to analyze.
  /// - `threshold`: (Optional) The Z-score threshold to identify outliers (defaults to 2.0).
  ///
  /// Returns a list of `StatPoint` objects identified as outliers.
  List<StatPoint> detectOutliers(List<StatPoint> stats, String statisticName,
      {double threshold = 2.0}) {
    double mean = calculateAverageValueForStat(stats, statisticName);
    double stdDev = calculateStandardDeviation(stats, statisticName);

    return stats.where((stat) {
      double value = stat.getStatByName(statisticName);
      double zScore = (value - mean) / (stdDev == 0 ? 1 : stdDev);
      return zScore.abs() > threshold;
    }).toList();
  }

  /// Normalizes a value within the range of a statistic using Min-Max scaling.
  ///
  /// - `value`: The value to normalize.
  /// - `stats`: A list of `StatPoint` objects.
  /// - `statisticName`: The name of the statistic.
  ///
  /// Returns the normalized value as a `double` between 0.0 and 1.0.
  double normalizeValue(
      double value, List<StatPoint> stats, String statisticName) {
    if (stats.isEmpty) return 0.0;

    // go through and get all the stats values for statName; convert from dynamic to double (and handle ints there as well)
    var values = stats
        .map((s) => s.getStatByName(statisticName) is double
            ? s.getStatByName(statisticName) as double
            : (s.getStatByName(statisticName) as int).toDouble())
        .toList();
    double min = values.reduce(math.min);
    double max = values.reduce(math.max);

    if (max == min) return 0.0;
    return (value - min) / (max - min);
  }

  /// Gets the longest streak since the last lapse (missed completion).
  ///
  /// - `habit`: A `HabitInterface` object representing the habit.
  ///
  /// Returns the longest streak as an `int`.
  int getLongestStreakSinceLastLapse(HabitInterface habit) {
    if (habit.stats.isEmpty) return 0;
    return math.max(habit.highestStreak, habit.streak);
  }

  /// Calculates the confidence level for continuing the habit.
  ///
  /// - `habit`: A `HabitInterface` object representing the habit.
  ///
  /// Returns the confidence level as a `double`.
  double calculateConfidenceLevel(HabitInterface habit) {
    double baseConfidence = 1;
    double consistencyFactor =
        calculateConsistencyFactor(habit.stats, habit.targetGoal);
    double successStreakBonus = 1.0;
    double difficultyWeight = calculateDifficultyWeight(habit.stats);

    if (habit.streak > 0) {
      successStreakBonus = math.pow(1.1, habit.streak) as double;
    }

    return baseConfidence *
        consistencyFactor *
        successStreakBonus *
        difficultyWeight;
  }

  /// Calculates the average completions per week for a habit.
  ///
  /// - `habit`: A `HabitInterface` object representing the habit.
  ///
  /// Returns the average completions per week as a `double`.
  double calculateAverageCompletionsPerWeek(HabitInterface habit) {
    if (habit.stats.isEmpty) return 0.0;
    int totalWeeks = (habit.stats.length / 7).ceil();
    int totalProgress =
        habit.stats.fold(0, (sum, stat) => sum + stat.completions);
    return totalProgress / totalWeeks;
  }

  /// Calculates the recent completion trend comparing recent week to previous weeks.
  ///
  /// - `habit`: A `HabitInterface` object representing the habit.
  ///
  /// Returns the difference in average completions as a `double`.
  double calculateRecentCompletionTrend(HabitInterface habit) {
    if (habit.stats.length < 14) return 0.0;

    var recentStats = habit.stats.sublist(habit.stats.length - 7);
    var previousStats = habit.stats.sublist(0, habit.stats.length - 7);

    double recentAverage = calculateAverageCompletionsPerWeek(
      habit..stats = recentStats,
    );

    double previousAverage = calculateAverageCompletionsPerWeek(
      habit..stats = previousStats,
    );

    return recentAverage - previousAverage;
  }

  /// Compares the performance between two habits.
  ///
  /// - `habit1`: The first `HabitInterface` object.
  /// - `habit2`: The second `HabitInterface` object.
  ///
  /// Returns the difference in performance scores as a `double`.
  double compareHabitPerformance(HabitInterface habit1, HabitInterface habit2) {
    double score1 = calculateConfidenceLevel(habit1);
    double score2 = calculateConfidenceLevel(habit2);
    return score1 - score2;
  }

  /// Calculates success rates by time of day for habit completions.
  ///
  /// - `habit`: A `HabitInterface` object representing the habit.
  ///
  /// Returns a `Map` with time slots as keys and success rates as `double` values.
  Map<String, double> getSuccessRateByTimeOfDay(HabitInterface habit) {
    var timeSlots = {
      'morning': 0.0, // 5-11
      'afternoon': 0.0, // 11-17
      'evening': 0.0, // 17-23
      'night': 0.0 // 23-5
    };

    var completions = {'morning': 0, 'afternoon': 0, 'evening': 0, 'night': 0};

    var attempts = {'morning': 0, 'afternoon': 0, 'evening': 0, 'night': 0};

    for (var stat in habit.stats) {
      String timeSlot = getTimeSlot(stat.date);
      attempts[timeSlot] = (attempts[timeSlot] ?? 0) + 1;
      if (stat.completions > 0) {
        completions[timeSlot] = (completions[timeSlot] ?? 0) + 1;
      }
    }

    timeSlots.forEach((slot, _) {
      if (attempts[slot]! > 0) {
        timeSlots[slot] = completions[slot]! / attempts[slot]!;
      }
    });

    return timeSlots;
  }

  /// Predicts the probability of continuing the current streak.
  ///
  /// - `habit`: A `HabitInterface` object representing the habit.
  ///
  /// Returns the predicted probability as a `double` between 0.0 and 1.0.
  double predictStreakContinuation(HabitInterface habit) {
    if (habit.stats.isEmpty) return 0.5;

    double confidence = calculateConfidenceLevel(habit);
    double recentTrend = calculateRecentCompletionTrend(habit);
    double consistencyFactor =
        calculateConsistencyFactor(habit.stats, habit.targetGoal);

    return (confidence + math.max(0, recentTrend) + consistencyFactor) / 3;
  }

  /// Calculates the recovery rate after lapses.
  ///
  /// - `habit`: A `HabitInterface` object representing the habit.
  ///
  /// Returns the recovery rate as a `double` between 0.0 and 1.0.
  double calculateRecoveryRate(HabitInterface habit) {
    if (habit.stats.length < 2) return 1.0;

    int breakCount = 0;
    int recoveryCount = 0;
    bool wasCompleted = habit.stats.first.completions > 0;

    for (var stat in habit.stats.skip(1)) {
      bool isCompleted = stat.completions > 0;
      if (!isCompleted && wasCompleted) {
        breakCount++;
      } else if (isCompleted && !wasCompleted) {
        recoveryCount++;
      }
      wasCompleted = isCompleted;
    }

    return breakCount > 0 ? recoveryCount / breakCount : 1.0;
  }

  /// Calculates the overall progress ratio across all habits.
  ///
  /// - `habits`: A list of `HabitInterface` objects.
  ///
  /// Returns the average completion rate as a `double` between 0.0 and 1.0.
  double calculateOverallProgress(List<HabitInterface> habits) {
    if (habits.isEmpty) return 0.0;

    return habits.fold(0.0, (total, habit) {
          if (habit.stats.isEmpty) return total;
          return total + (habit.stats.last.completions / habit.targetGoal);
        }) /
        habits.length;
  }

  /// Calculates goal achievement rates for a list of habits.
  ///
  /// - `habits`: A list of `HabitInterface` objects.
  ///
  /// Returns a `Map` with habit IDs as keys and achievement rates as `double` values.
  Map<String, double> calculateGoalAchievementRates(
      List<HabitInterface> habits) {
    if (habits.isEmpty) return {};

    var rates = <String, double>{};
    for (var habit in habits) {
      if (habit.stats.isEmpty) continue;
      rates[habit.id.toString()] =
          habit.stats.where((s) => s.completions >= habit.targetGoal).length /
              habit.stats.length;
    }
    return rates;
  }

  /// Retrieves the best-performing habits based on goal achievement rates.
  ///
  /// - `habits`: A list of `HabitInterface` objects.
  ///
  /// Returns a sorted list of `HabitInterface`, best-performing first.
  List<HabitInterface> getBestPerformingHabits(List<HabitInterface> habits) {
    return List.from(habits)
      ..sort((a, b) {
        double rateA = calculateGoalAchievementRates([a])[a.id] ?? 0.0;
        double rateB = calculateGoalAchievementRates([b])[b.id] ?? 0.0;
        return rateB.compareTo(rateA);
      });
  }

  /// Calculates user engagement metrics over the past 30 days.
  ///
  /// - `habits`: A list of `HabitInterface` objects.
  ///
  /// Returns a `Map` with metrics such as total actions, days active, engagement rate, and average actions per day.
  Map<String, dynamic> calculateEngagementMetrics(List<HabitInterface> habits) {
    if (habits.isEmpty) return {};

    var now = DateTime.now();
    var thirtyDaysAgo = now.subtract(Duration(days: 30));

    int totalActions = 0;
    int daysActive = 0;
    Set<DateTime> activeDays = {};

    for (var habit in habits) {
      for (var stat in habit.stats) {
        if (stat.date.isAfter(thirtyDaysAgo)) {
          totalActions += stat.completions;
          if (stat.completions > 0) {
            activeDays
                .add(DateTime(stat.date.year, stat.date.month, stat.date.day));
          }
        }
      }
    }

    daysActive = activeDays.length;

    return {
      'totalActions': totalActions,
      'daysActive': daysActive,
      'engagementRate': daysActive / 30,
      'averageActionsPerDay': totalActions / 30,
    };
  }

  /// Calculates the average value of a statistic across all habits.
  ///
  /// - `statisticName`: The name of the statistic to average.
  /// - `habits`: A list of `HabitInterface` objects.
  ///
  /// Returns the average value as a `double`.
  double calculateStatAverage(
      String statisticName, List<HabitInterface> habits) {
    if (habits.isEmpty) return 0.0;

    double sum = 0.0;
    for (HabitInterface habit in habits) {
      if (habit.stats.isEmpty) {
        sum += 0;
      } else {
        sum += calculateAverageValueForStat(habit.stats, statisticName);
      }
    }
    return sum / habits.length;
  }

  /// Calculates the overall slope (rate of change) of a statistic across all habits.
  ///
  /// - `statisticName`: The name of the statistic to calculate the slope for.
  /// - `habits`: A list of `HabitInterface` objects.
  ///
  /// Returns the average slope as a `double`.
  double calculateOverallSlope(
      String statisticName, List<HabitInterface> habits) {
    if (habits.isEmpty) return 0.0;

    double sum = 0.0;
    for (HabitInterface habit in habits) {
      if (habit.stats.isEmpty) {
        sum += 0;
      } else {
        sum += calculateStatSlope(statisticName, habit.stats);
      }
    }
    return sum / habits.length;
  }

  /// Gets the total number of habit completions.
  ///
  /// - `habits`: A list of `HabitInterface` objects.
  ///
  /// Returns the total completions as an `int`.
  int getTotalHabitsCompleted(List<HabitInterface> habits) {
    return habits.fold(0, (total, habit) => total + habit.daysCompleted.length);
  }

  /// Gets the longest streak among all habits.
  ///
  /// - `habits`: A list of `HabitInterface` objects.
  ///
  /// Returns the longest streak as an `int`.
  int getLongestStreak(List<HabitInterface> habits) {
    if (habits.isEmpty) return 0;

    return habits
        .map((habit) => habit.streak)
        .reduce((max, streak) => streak > max ? streak : max);
  }

  /// Calculates the total number of completions for the current week.
  ///
  /// - `habits`: A list of `HabitInterface` objects.
  ///
  /// Returns the total completions for the week as an `int`.
  int getWeekCompletions(List<HabitInterface> habits) {
    if (habits.isEmpty) return 0;

    final startOfWeek =
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

    return habits.fold(0, (total, habit) {
      return total +
          habit.daysCompleted
              .where((date) =>
                  date.isAfter(startOfWeek) &&
                  date.isBefore(startOfWeek.add(Duration(days: 7))))
              .length;
    });
  }

  bool isStreakMilestone(int streak) {
    return streak > 0 && (streak % 7 == 0 || streak % 30 == 0 || streak == 1);
  }
}
