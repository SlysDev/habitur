import 'package:habitur/models/habit.dart';
import 'package:habitur/modules/stats_calculator.dart';

class UserStatsCalculator extends StatsCalculator {
  List<Habit> habits;
  UserStatsCalculator(this.habits);

  double calculateStatAverage(String statisticName) {
    if (habits.isEmpty) return 0.0;
    double sum = 0.0;
    for (Habit habit in habits) {
      if (habit.stats.isEmpty) {
        sum += 0;
      } else {
        sum +=
            calculateAverageValueForStat(statisticName, habit.stats).toDouble();
        // make commit showing that you're now calculating the true average for all days
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

  int getTotalHabitsCompleted(context) {
    int totalHabitsCompleted = 0;
    for (Habit habit in habits) {
      totalHabitsCompleted += habit.daysCompleted.length;
    }
    return totalHabitsCompleted;
  }

  double getLongestStreak(context) {
    var longestStreakHabit;
    for (Habit habit in habits) {
      if (longestStreakHabit ??= null) {
        longestStreakHabit = habit;
      } else if (habit.streak > longestStreakHabit.streak) {
        longestStreakHabit = habit;
      }
    }
    return longestStreakHabit.streak;
  }

  int getWeekCompletions(context) {
    int weekCompletions = 0;
    DateTime startOfWeek =
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

    for (Habit habit in habits) {
      for (DateTime completedDate in habit.daysCompleted) {
        if (completedDate.isAfter(startOfWeek) &&
            completedDate.isBefore(startOfWeek.add(Duration(days: 7)))) {
          weekCompletions++;
        }
      }
    }

    return weekCompletions;
  }
}
