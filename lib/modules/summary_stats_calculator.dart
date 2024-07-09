import 'package:habitur/models/habit.dart';
import 'package:habitur/modules/stats_calculator.dart';

class SummaryStatisticsCalculator extends StatisticsCalculator {
  List<Habit> habits;
  SummaryStatisticsCalculator(this.habits);

  double calculateTodaysStatAverage(String statisticName) {
    if (habits.isEmpty) return 0.0;
    double sum = 0.0;
    for (Habit habit in habits) {
      sum = getStatisticValue(habit.stats.last, statisticName).toDouble();
    }
    return sum / habits.length;
  }

  double calculateOverallSlope(String statisticName) {
    if (habits.isEmpty) return 0.0;
    double sum = 0.0;
    for (Habit habit in habits) {
      sum += calculateStatSlope(statisticName, habit.stats);
    }
    return sum / habits.length;
  }
}
