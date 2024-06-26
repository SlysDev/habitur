import 'package:habitur/models/habit.dart';
import 'package:habitur/models/data_point.dart';
import 'package:habitur/modules/statistics_recorder.dart';
import 'package:habitur/providers/summary_statistics_repository.dart';
import 'package:habitur/providers/user_data.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class HabitStatsHandler {
  Habit habit;
  HabitStatsHandler(this.habit);

  void incrementCompletion(context) {
    StatisticsRecorder statsRecorder = StatisticsRecorder();
    habit.completionsToday++;
    habit.totalCompletions++;
    if (habit.completionsToday == habit.requiredCompletions) {
      habit.isCompleted = true;
      Provider.of<SummaryStatisticsRepository>(context, listen: false)
          .totalHabitsCompleted++;
      Provider.of<UserData>(context, listen: false).addHabiturRating();
      habit.streak++;
      habit.confidenceLevel =
          habit.confidenceLevel * pow(1.10, habit.confidenceLevel);
      habit.confidenceStats
          .add(DataPoint(value: habit.confidenceLevel, date: DateTime.now()));
      habit.daysCompleted.add(DateTime.now());
      statsRecorder.logHabitCompletion(context);
    }
    int currentDayIndex = habit.completionStats.indexWhere(
      (dataPoint) =>
          dataPoint.date.year == DateTime.now().year &&
          dataPoint.date.month == DateTime.now().month &&
          dataPoint.date.day == DateTime.now().day,
    );
    if (currentDayIndex != -1) {
      // If there's an entry for the current day, update the completion count
      habit.completionStats[currentDayIndex] = DataPoint(
        date: DateTime.now(),
        value: habit.completionStats[currentDayIndex].value + 1,
      );
    } else {
      // If there's no entry for the current day, add a new entry
      habit.completionStats.add(DataPoint(
        date: DateTime.now(),
        value: 1,
      ));
    }
  }

  void decrementCompletion(context) {
    StatisticsRecorder statsRecorder = StatisticsRecorder();
    if (habit.completionsToday == 0) {
      return;
    }
    if (habit.completionsToday == habit.requiredCompletions) {
      habit.isCompleted = false;
      Provider.of<SummaryStatisticsRepository>(context, listen: false)
          .totalHabitsCompleted--;
      habit.confidenceLevel =
          habit.confidenceLevel * pow(0.90, habit.confidenceLevel);
      statsRecorder.recordAverageConfidenceLevel(context);
      if (habit.daysCompleted.isNotEmpty) {
        habit.daysCompleted.removeLast();
      }
      Provider.of<UserData>(context, listen: false).removeHabiturRating();
      if (habit.streak > 0) {
        habit.streak--;
      }
      if (habit.confidenceStats.isNotEmpty) {
        habit.confidenceStats.removeLast();
      }
    }
    if (habit.completionStats.isNotEmpty) {
      if (habit.completionStats.last.value == 1) {
        habit.completionStats.removeLast();
      } else {
        habit.completionStats.last.value--;
      }
    }
    habit.completionsToday--;
    habit.totalCompletions--;
  }

  void resetHabitCompletions() {
    habit.completionsToday = 0;
    if (habit.streak > habit.highestStreak) {
      habit.highestStreak = habit.streak;
    }
    habit.streak = 0;
  }
}
