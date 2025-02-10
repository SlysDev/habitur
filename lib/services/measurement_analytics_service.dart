import 'package:habitur/models/stat_point.dart';

class MeasurementAnalyticsService {
  /// Calculates the rolling average for a given period
  double calculateRollingAverage(List<StatPoint> stats, int days) {
    if (stats.isEmpty || days <= 0) return 0;

    final recentStats = stats.take(days).toList();
    final sum = recentStats.fold<double>(
      0,
      (sum, stat) => sum + stat.completions,
    );

    return sum / recentStats.length;
  }

  /// Gets the personal best (highest completion) from stats
  double getPersonalBest(List<StatPoint> stats) {
    if (stats.isEmpty) return 0;
    return stats
        .map((s) => s.completions.toDouble())
        .reduce((a, b) => a > b ? a : b);
  }

  /// Calculates progress towards goal as a percentage
  double calculateGoalProgress(double current, double target) {
    if (target <= 0) return 0;
    return (current / target).clamp(0.0, 1.0);
  }

  /// Analyzes trend direction over the last n days
  /// Returns: 1 for upward trend, -1 for downward trend, 0 for no clear trend
  int analyzeTrend(List<StatPoint> stats, {int days = 7}) {
    if (stats.length < days) return 0;

    final recentStats = stats.take(days).toList();
    double sumX = 0;
    double sumY = 0;
    double sumXY = 0;
    double sumX2 = 0;

    for (int i = 0; i < recentStats.length; i++) {
      final x = i.toDouble();
      final y = recentStats[i].completions;
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }

    final n = recentStats.length.toDouble();
    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);

    if (slope > 0.1) return 1;
    if (slope < -0.1) return -1;
    return 0;
  }

  /// Calculates optimal completion times based on successful completions
  Map<String, int> analyzeOptimalTimes(List<StatPoint> stats) {
    if (stats.isEmpty) return {};

    // Group completions by hour of day
    Map<String, int> hourlyCompletions = {};

    for (var stat in stats) {
      final hour = stat.date.hour;
      final timeBlock = _getTimeBlock(hour);
      hourlyCompletions[timeBlock] = (hourlyCompletions[timeBlock] ?? 0) + 1;
    }

    return hourlyCompletions;
  }

  /// Helper to group hours into time blocks
  String _getTimeBlock(int hour) {
    if (hour >= 5 && hour < 12) return 'Morning';
    if (hour >= 12 && hour < 17) return 'Afternoon';
    if (hour >= 17 && hour < 22) return 'Evening';
    return 'Night';
  }

  /// Calculates consistency score based on regular completion patterns
  double calculateConsistencyScore(List<StatPoint> stats, {int days = 7}) {
    if (stats.isEmpty || days <= 0) return 0;

    final recentStats = stats.take(days).toList();
    final completedDays = recentStats.where((s) => s.completions > 0).length;

    return completedDays / days;
  }

  /// Generates performance insights based on recent stats
  List<String> generateInsights(List<StatPoint> stats, double targetGoal) {
    List<String> insights = [];

    if (stats.isEmpty) return ['Not enough data to generate insights'];

    // Analyze trend
    final trend = analyzeTrend(stats);
    if (trend > 0) {
      insights.add("You're performing better each day! Keep it up! 🎉");
    } else if (trend < 0) {
      insights
          .add("Your numbers have been declining. Need a motivation boost? 💪");
    }

    // Check consistency
    final consistency = calculateConsistencyScore(stats);
    if (consistency >= 0.8) {
      insights.add("You're maintaining great consistency! ⭐");
    } else if (consistency <= 0.5) {
      insights.add("Try to be more consistent to reach your goals faster");
    }

    // Analyze optimal times
    final timeAnalysis = analyzeOptimalTimes(stats);
    if (timeAnalysis.isNotEmpty) {
      final bestTime =
          timeAnalysis.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      insights.add("You perform best during the $bestTime");
    }

    return insights;
  }
}
