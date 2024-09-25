import 'package:habitur/models/habit.dart';
import 'package:habitur/modules/stats_calculator.dart';

class UserStatsCalculator extends StatsCalculator {
  List<Habit> habits;
  UserStatsCalculator(this.habits);

  double calculateTodaysStatAverage(String statisticName) {
    if (habits.isEmpty) return 0.0;
    double sum = 0.0;
    for (Habit habit in habits) {
      if (habit.stats.isEmpty) {
        sum += 0;
      } else {
        sum += getStatisticValue(habit.stats.last, statisticName).toDouble();
      }
    }
    return sum / habits.length;
  }

  double calculateOverallSlope(String statisticName) {
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
}
