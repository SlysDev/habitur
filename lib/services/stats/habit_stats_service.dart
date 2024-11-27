import 'package:habitur/models/habit.dart';
import 'package:habitur/services/stats/base_stats_service.dart';
import 'dart:math' as math;

import '../../models/stat_point.dart';

class HabitStatsService extends BaseStatsService {
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

  @override
  double calculateStatSlope(String statisticName, List<StatPoint> stats,
      {int period = 7}) {
    double slope =
        super.calculateStatSlope(statisticName, stats, period: period);
    if (statisticName == 'completions') {
      return slope * stats.first.completions.toDouble();
    }
    return slope;
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
      String timeSlot = _getTimeSlot(stat.date);
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

  String _getTimeSlot(DateTime time) {
    int hour = time.hour;
    if (hour >= 5 && hour < 11) return 'morning';
    if (hour >= 11 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 23) return 'evening';
    return 'night';
  }
}
