import 'package:flutter/material.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/habit_interface.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/services/stats/stats_calculation_service.dart';

class AggregateStatsCalculatorService {
  final _statsCalculationService = locator<StatsCalculationService>();

  void _log(String message) {
    var current = StackTrace.current;
    var frames = current.toString().split('\n');
    if (frames.length > 2) {
      var frame = frames[2]; // Adjust index if necessary
      var match =
          RegExp(r'#\d+\s+(\S+)\s+\(([^:]+):(\d+):\d+\)').firstMatch(frame);
      if (match != null) {
        var functionName = match.group(1);
        var fileName = match.group(2)?.split('/').last;
        var lineNumber = match.group(3);
        debugPrint('[$functionName] ($fileName:$lineNumber) $message');
      } else {
        debugPrint('[Unknown] $message');
      }
    } else {
      debugPrint('[Unknown] $message');
    }
  }

  double calculateSingleDayStatSum(
      String statisticName, List<HabitInterface> habits) {
    _log('Calculating sum for $statisticName with ${habits.length} habits');
    if (habits.isEmpty) return 0.0;
    double sum = 0.0;
    for (HabitInterface habit in habits) {
      if (habit.stats.isEmpty) {
        _log('Habit ${habit.id} has no stats');
        _log('Adding 0 to sum');
        sum += 0;
      } else {
        double statValue = habit.stats.last.getStatByName(statisticName) is int
            ? habit.stats.last.getStatByName(statisticName).toDouble()
            : habit.stats.last.getStatByName(statisticName);
        _log(
            'Habit ${habit.id} last stat value for $statisticName: $statValue');
        _log('Adding $statValue to sum');
        sum += statValue;
      }
      _log('Current sum: $sum');
    }
    _log('Total sum for $statisticName: $sum');
    return sum;
  }

  double calculateStatAverage(
      String statisticName, List<HabitInterface> habits) {
    _log('Calculating average for $statisticName with ${habits.length} habits');
    if (habits.isEmpty) return 0.0;
    double sum = 0.0;
    for (HabitInterface habit in habits) {
      if (habit.stats.isEmpty) {
        _log('Habit ${habit.id} has no stats');
        _log('Adding 0 to sum');
        sum += 0;
      } else {
        double averageValue = _statsCalculationService
            .calculateAverageValueForStat(habit.stats, statisticName);
        _log(
            'Habit ${habit.id} average value for $statisticName: $averageValue');
        _log('Adding $averageValue to sum');
        sum += averageValue;
      }
      _log('Current sum: $sum');
    }
    double average = sum / habits.length;
    _log('Total sum: $sum');
    _log('Calculated average: $average');
    return average;
  }

  double calculateOverallSlope(
      String statisticName, List<HabitInterface> habits) {
    _log(
        'Calculating overall slope for $statisticName with ${habits.length} habits');
    if (habits.isEmpty) return 0.0;
    double sum = 0.0;
    for (HabitInterface habit in habits) {
      if (habit.stats.isEmpty) {
        _log('Habit ${habit.id} has no stats');
        _log('Adding 0 to sum');
        sum += 0;
      } else {
        double slopeValue = _statsCalculationService.calculateStatSlope(
            statisticName, habit.stats);
        _log('Habit ${habit.id} slope value for $statisticName: $slopeValue');
        _log('Adding $slopeValue to sum');
        sum += slopeValue;
      }
      _log('Current sum: $sum');
    }
    double slope = sum / habits.length;
    _log('Total sum: $sum');
    _log('Overall slope for $statisticName: $slope');
    return slope;
  }
}
