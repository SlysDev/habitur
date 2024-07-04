import 'package:habitur/models/habit.dart';
import 'package:habitur/models/data_point.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/modules/habit_stats_calculator.dart';
import 'package:habitur/modules/summary_statistics_recorder.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/summary_statistics_repository.dart';
import 'package:habitur/providers/user_data.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class HabitStatsHandler {
  Habit habit;
  HabitStatsHandler(this.habit);

  void incrementCompletion(context) {
    SummaryStatisticsRecorder statsRecorder = SummaryStatisticsRecorder();
    HabitStatisticsCalculator statsCalculator =
        HabitStatisticsCalculator(habit);
    habit.completionsToday++;
    habit.totalCompletions++;
    if (habit.completionsToday == habit.requiredCompletions) {
      habit.isCompleted = true;
      Provider.of<SummaryStatisticsRepository>(context, listen: false)
          .totalHabitsCompleted++;
      Provider.of<UserData>(context, listen: false).addHabiturRating();
      Provider.of<Database>(context, listen: false).uploadUserData(context);
      habit.streak++;
      if (habit.streak > habit.highestStreak) {
        habit.highestStreak = habit.streak;
      }
      habit.daysCompleted.add(DateTime.now());
    }
    int currentDayIndex = habit.stats.indexWhere(
      (dataPoint) =>
          dataPoint.date.year == DateTime.now().year &&
          dataPoint.date.month == DateTime.now().month &&
          dataPoint.date.day == DateTime.now().day,
    );
    if (currentDayIndex != -1) {
      // If there's an entry for the current day, update the completion count
      habit.stats[currentDayIndex].completions++;
      habit.stats[currentDayIndex].confidenceLevel =
          statsCalculator.calculateConfidenceLevel();
      habit.stats[currentDayIndex].streak = habit.streak;
      statsRecorder.logHabitCompletion(context);
    } else {
      // If there's no entry for the current day, add a new entry
      if (habit.stats.isEmpty) {
        StatPoint newStatPoint = StatPoint(
            date: DateTime.now(),
            completions: 1,
            confidenceLevel: statsCalculator.calculateConfidenceLevel(),
            streak: habit.streak);
        habit.stats.add(newStatPoint);
      } else {
        StatPoint newStatPoint = habit.stats.last;
        newStatPoint.date = DateTime.now();
        newStatPoint.completions = 1;
        newStatPoint.confidenceLevel =
            statsCalculator.calculateConfidenceLevel();
        habit.stats.add(newStatPoint);
      }
      statsRecorder.logHabitCompletion(context);
    }
    habit.confidenceLevel = statsCalculator.calculateConfidenceLevel();
  }

  void decrementCompletion(context) {
    SummaryStatisticsRecorder statsRecorder = SummaryStatisticsRecorder();
    HabitStatisticsCalculator statsCalculator =
        HabitStatisticsCalculator(habit);

    if (habit.completionsToday == 0) {
      return;
    }

    // Check if decrementing completion would change habit completion status
    if (habit.completionsToday == habit.requiredCompletions) {
      habit.isCompleted = false;
      Provider.of<SummaryStatisticsRepository>(context, listen: false)
          .totalHabitsCompleted--;
      statsRecorder.recordAverageConfidenceLevel(context);

      if (habit.daysCompleted.isNotEmpty) {
        habit.daysCompleted.removeLast();
      }

      Provider.of<UserData>(context, listen: false).removeHabiturRating();
      Provider.of<Database>(context, listen: false).uploadUserData(context);
    }

    // Decrement completions and potentially update streak
    if (habit.streak > 0) {
      habit.streak--;
    }
    habit.completionsToday--;
    habit.totalCompletions--;

    // Update confidence level based on updated stats
    habit.confidenceLevel = statsCalculator.calculateConfidenceLevel();

    // Find the StatPoint entry for the current day
    int currentDayIndex = habit.stats.indexWhere((dataPoint) =>
        dataPoint.date.year == DateTime.now().year &&
        dataPoint.date.month == DateTime.now().month &&
        dataPoint.date.day == DateTime.now().day);

    if (currentDayIndex != -1) {
      // Decrement completions in the StatPoint for the current day
      if (habit.stats[currentDayIndex].completions > 0) {
        habit.stats[currentDayIndex].completions--;
      }

      // Update streak in the StatPoint if necessary
      if (habit.streak > 0) {
        habit.stats[currentDayIndex].streak--;
      }

      habit.stats[currentDayIndex].confidenceLevel =
          statsCalculator.calculateConfidenceLevel();
    } else {
      // Shouldn't reach here ideally (log a message?)
      print('No entry found for decrementing habit completion in stats.');
    }

    statsRecorder.unlogHabitCompletion(context);
  }

  void resetHabitCompletions() {
    if (!habit.isCompleted) {
      habit.streak = 0;
    }
    habit.completionsToday = 0;
    if (habit.streak > habit.highestStreak) {
      habit.highestStreak = habit.streak;
    }
  }
}
