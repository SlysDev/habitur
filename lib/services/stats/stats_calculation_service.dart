import 'package:habitur/models/habit.dart';
import 'package:habitur/models/stat_point.dart';
import 'dart:math' as math;

import 'package:habitur/util_functions.dart';

class StatsCalculationService {
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

  int getLongestStreakSinceLastLapse(Habit habit) {
    if (habit.stats.isEmpty) return 0;
    return math.max(habit.highestStreak, habit.streak);
  }

  double calculateConfidenceLevel(Habit habit) {
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

  double calculateAverageCompletionsPerWeek(Habit habit) {
    if (habit.stats.isEmpty) return 0.0;
    int totalWeeks = (habit.stats.length / 7).ceil();
    int totalProgress =
        habit.stats.fold(0, (sum, stat) => sum + stat.completions);
    return totalProgress / totalWeeks;
  }

  double calculateRecentCompletionTrend(Habit habit) {
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

  // Habit comparison
  double compareHabitPerformance(Habit habit1, Habit habit2) {
    double score1 = calculateConfidenceLevel(habit1);
    double score2 = calculateConfidenceLevel(habit2);
    return score1 - score2;
  }

  // Time of day analysis
  Map<String, double> getSuccessRateByTimeOfDay(Habit habit) {
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

  // Streak prediction
  double predictStreakContinuation(Habit habit) {
    if (habit.stats.isEmpty) return 0.5;

    double confidence = calculateConfidenceLevel(habit);
    double recentTrend = calculateRecentCompletionTrend(habit);
    double consistencyFactor =
        calculateConsistencyFactor(habit.stats, habit.targetGoal);

    return (confidence + math.max(0, recentTrend) + consistencyFactor) / 3;
  }

  // Recovery analysis
  double calculateRecoveryRate(Habit habit) {
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

  /// Calculates the overall progress ratio across all habits
  ///
  /// Returns a value between 0.0 and 1.0 representing the average completion rate of all habits:
  /// - 0.0 means no habits have any completions
  /// - 1.0 means all habits have met their target goals
  /// - 0.5 means habits are, on average, halfway to their goals
  ///
  /// For example:
  /// - If you have 2 habits:
  ///   1. Habit with 3/5 completions (60% complete)
  ///   2. Habit with 2/4 completions (50% complete)
  /// The overall progress would be (0.6 + 0.5) / 2 = 0.55 or 55%
  ///
  /// Note: Habits with no stats are counted as 0% complete in the average
  double calculateOverallProgress(List<Habit> habits) {
    if (habits.isEmpty) return 0.0;

    return habits.fold(0.0, (total, habit) {
          if (habit.stats.isEmpty) return total;
          return total + (habit.stats.last.completions / habit.targetGoal);
        }) /
        habits.length;
  }

  // Goal achievement analysis
  Map<String, double> calculateGoalAchievementRates(List<Habit> habits) {
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

  // Best/worst performing habits
  List<Habit> getBestPerformingHabits(List<Habit> habits) {
    return List.from(habits)
      ..sort((a, b) {
        double rateA = calculateGoalAchievementRates([a])[a.id] ?? 0.0;
        double rateB = calculateGoalAchievementRates([b])[b.id] ?? 0.0;
        return rateB.compareTo(rateA);
      });
  }

  // // Category performance TODO: Think about implementing habit categories
  // Map<String, double> getCategoryPerformance(List<Habit> habits) {
  //   var categoryStats = <String, Map<String, int>>{};

  //   for (var habit in habits) {
  //     if (habit.category == null) continue;

  //     categoryStats.putIfAbsent(habit.category!, () => {
  //       'completed': 0,
  //       'total': 0
  //     });

  //     for (var stat in habit.stats) {
  //       categoryStats[habit.category]!['total'] =
  //         (categoryStats[habit.category]!['total'] ?? 0) + 1;
  //       if (stat.completions >= habit.targetGoal) {
  //         categoryStats[habit.category]!['completed'] =
  //           (categoryStats[habit.category]!['completed'] ?? 0) + 1;
  //       }
  //     }
  //   }

  //   var performance = <String, double>{};
  //   categoryStats.forEach((category, stats) {
  //     if (stats['total']! > 0) {
  //       performance[category] = stats['completed']! / stats['total']!;
  //     }
  //   });

  //   return performance;
  // }

  // User engagement metrics
  Map<String, dynamic> calculateEngagementMetrics(List<Habit> habits) {
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

  double calculateStatAverage(String statisticName, List<Habit> habits) {
    if (habits.isEmpty) return 0.0;

    double sum = 0.0;
    for (Habit habit in habits) {
      if (habit.stats.isEmpty) {
        sum += 0;
      } else {
        sum += calculateAverageValueForStat(habit.stats, statisticName);
      }
    }
    return sum / habits.length;
  }

  double calculateOverallSlope(String statisticName, List<Habit> habits) {
    if (habits.isEmpty) return 0.0;

    double sum = 0.0;
    for (Habit habit in habits) {
      if (habit.stats.isEmpty) {
        sum += 0;
      } else {
        sum += calculateStatSlope(statisticName, habit.stats);
      }
    }
    return sum / habits.length;
  }

  int getTotalHabitsCompleted(List<Habit> habits) {
    return habits.fold(0, (total, habit) => total + habit.daysCompleted.length);
  }

  int getLongestStreak(List<Habit> habits) {
    if (habits.isEmpty) return 0;

    return habits
        .map((habit) => habit.streak)
        .reduce((max, streak) => streak > max ? streak : max);
  }

  int getWeekCompletions(List<Habit> habits) {
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
}
