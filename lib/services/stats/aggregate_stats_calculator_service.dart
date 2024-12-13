import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/habit_interface.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/services/stats/stats_calculation_service.dart';

class AggregateStatsCalculatorService {
  final _statsCalculationService = locator<StatsCalculationService>();

  double calculateSingleDayStatSum(String statisticName, List<HabitInterface> habits) {
    if (habits.isEmpty) return 0.0;
    double sum = 0.0;
    for (HabitInterface habit in habits) {
      if (habit.stats.isEmpty) {
        sum += 0;
      } else {
        sum += habit.stats.last.getStatByName(statisticName);
      }
    }
    return sum;
  }

  double calculateStatAverage(String statisticName, List<HabitInterface> habits) {
    if (habits.isEmpty) return 0.0;
    double sum = 0.0;
    for (HabitInterface habit in habits) {
      if (habit.stats.isEmpty) {
        sum += 0;
      } else {
        sum += _statsCalculationService.calculateAverageValueForStat(
            habit.stats, statisticName);
      }
    }
    return sum / habits.length;
  }

  double calculateOverallSlope(String statisticName, List<HabitInterface> habits) {
    if (habits.isEmpty) return 0.0;
    double sum = 0.0;
    for (HabitInterface habit in habits) {
      if (habit.stats.isEmpty) {
        sum += 0;
      } else {
        sum += _statsCalculationService.calculateStatSlope(
            statisticName, habit.stats);
      }
    }
    return sum / habits.length;
  }
}
