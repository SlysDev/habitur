import 'package:habitur/models/data_point.dart';
import 'package:habitur/models/habit.dart';
import 'dart:math' as math;

class HabitStatisticsCalculator {
  final Habit habit;

  HabitStatisticsCalculator(this.habit);

  double calculateConfidenceChange(List<DataPoint> stats) {
    if (stats.length < 2) return 0.0;
    return stats.last.value - stats[stats.length - 2].value;
  }

  double calculateAverageCompletionsPerWeek({List<DataPoint>? stats}) {
    if (stats == null) {
      stats = habit.completionStats;
    }
    if (stats.isEmpty) return 0.0;
    int totalWeeks = (stats.length / 7).ceil(); // Assuming 7 days in a week
    return habit.totalCompletions / totalWeeks;
  }

  String formatAverage(double value) => value.toStringAsFixed(1);

  double calculateCompletionConsistency({int periodInDays = -1}) {
    if (periodInDays == -1) {
      periodInDays = DateTime.now().difference(habit.dateCreated).inDays;
    }
    if (habit.completionStats.isEmpty || periodInDays <= 0) return 0.0;

    int completedDays = 0;
    int i = habit.completionStats.length - 1;
    int j = i - periodInDays;
    while (i >= 0) {
      if (i == j) {
        break;
      }
      DataPoint dataPoint = habit.completionStats[i];
      if (dataPoint.value == habit.requiredCompletions) {
        completedDays++;
      }
      i--;
    }

    // Check if there are any completions before dividing
    return completedDays > 0 ? (completedDays / periodInDays) : 0.0;
  }

  double calculateRecentCompletionTrend() {
    if (habit.completionStats.length < 14) return 0.0;
    double recentAverage = calculateAverageCompletionsPerWeek(
        stats: habit.completionStats.sublist(habit.completionStats.length - 7));
    double previousAverage = calculateAverageCompletionsPerWeek(
        stats:
            habit.completionStats.sublist(0, habit.completionStats.length - 7));
    return recentAverage - previousAverage;
  }

  int getLongestStreakSinceLastLapse() {
    if (habit.completionStats.isEmpty) return 0;
    int currentStreak = 0;
    return math.max(habit.highestStreak,
        currentStreak); // Account for potential streak at the end
  }

  double calculateConfidenceLevel() {
    double completionRateWeight = 0.5;
    double streakWeight = 0.3;
    double consistencyWeight = 0.2;
    double score = 0.0;
    score += habit.completionRate * completionRateWeight;
    score += habit.highestStreak * streakWeight;
    score += calculateCompletionConsistency(periodInDays: 7) *
        consistencyWeight; // Weekly consistency
    return score;
  }
}
