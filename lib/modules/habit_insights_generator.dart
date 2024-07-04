import 'package:habitur/models/habit.dart';
import 'package:habitur/modules/habit_stats_calculator.dart';

class HabitInsightsGenerator {
  Habit habit;
  HabitStatisticsCalculator statsCalculator;

  HabitInsightsGenerator(this.habit, this.statsCalculator);

  /// Generates a message highlighting an area for improvement in the user's habit.
  // String generateImprovementTip() {
  //   String improvementArea = '';
  //   double weightedDeviation = double.negativeInfinity;
  //   String improvementPeriod = '';

  //   // Consider multiple statistics with weights
  //   List<HabitStat> statsToConsider = [
  //     HabitStat(
  //         statName: 'Completion Rate',
  //         value: habit.completionRate,
  //         minValue: 0.0,
  //         maxValue: 1.0,
  //         weight: 0.5),
  //     HabitStat(
  //         statName: 'Recent Completion Trend',
  //         value: statsCalculator.calculateRecentCompletionTrend(),
  //         minValue: double.negativeInfinity,
  //         maxValue: double.infinity,
  //         weight: 0.3),
  //     // Add other statistics with weights
  //   ];

  //   // Calculate average for each stat over a configurable period (assuming you have a function for this)
  //   Map<String, double> statAverages = calculateStatAverages(
  //       averagingPeriod: 7); // Replace 7 with your desired period

  //   for (HabitStat stat in statsToConsider) {
  //     double deviation =
  //         (stat.value - statAverages[stat.statName]!) * stat.weight;
  //     if (deviation < weightedDeviation) {
  //       improvementArea = stat.statName;
  //       weightedDeviation = deviation;
  //       improvementPeriod = stat.getImprovementPeriod();
  //     }
  //   }

  //   return improvementArea.isEmpty
  //       ? 'You\'re on track! Keep up the good work.'
  //       : 'Your $improvementArea needs some work. It\'s off by ${weightedDeviation.toStringAsFixed(1)} ${improvementPeriod}.';
}

  // /// Calculates the average for each statistic over a specified period (replace with your implementation)
  // Map<String, double> calculateStatAverages({int averagingPeriod = 7}) {
  //   // Implement your logic to calculate averages based on your data persistence strategy
  //   // This is a placeholder, replace with your actual calculation
  //   Map<String, double> statAverages = {};
  //   for (HabitStat stat in statsToConsider) {
  //     statAverages[stat.statName] =
  //         0.5; // Placeholder value, replace with calculation
  //   }
  //   return statAverages;
  // }

  // /// Generates a message highlighting a success aspect of the user's habit.
  // String generateSuccessHighlight() {
  //   // Implement logic to identify a success metric (e.g., longest streak)
  //   // Here's a placeholder example using longest streak
  //   int longestStreak = statsCalculator.getLongestStreak();
  //   if (longestStreak >= 7) {
  //     return "Congratulations! You've reached a streak of at least 7 days.";
  //   } else {
  //     return "";
  //   }
  // }
// }

// class HabitStat {
  // final String statName;
  // final double value;
  // final double minValue;
  // final double maxValue;
  // final double weight;

  // HabitStat(
  //     {required this.statName,
  //     required this.value,
  //     required this.minValue,
  //     required this.maxValue,
  //     required this.weight});

  // String getImprovementPeriod() {
  //   if (statName == 'Completion Rate') {
  //     return '%';
  //   } else if (statName == 'Recent Completion Trend') {
  //     return improvementValue >= 0 ? 'this week' : 'recently';
  //   } else {
  //     // Add logic for other statistics' improvement periods
  //     return '';
  //   }
  // }
// }
