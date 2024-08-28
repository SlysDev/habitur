import 'package:habitur/models/habit.dart';
import 'package:habitur/modules/habit_stats_calculator.dart';
import 'package:habitur/modules/stats_calculator.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:provider/provider.dart';

class SummaryStatsCalculator {
  int getTotalHabitsCompleted(context) {
    int totalHabitsCompleted = 0;
    for (Habit habit
        in Provider.of<HabitManager>(context, listen: false).habits) {
      totalHabitsCompleted += habit.daysCompleted.length;
    }
    return totalHabitsCompleted;
  }

  double getAverageStreak(context) {
    int streakCount = 0;
    int streakTotal = 0;
    for (Habit habit
        in Provider.of<HabitManager>(context, listen: false).habits) {
      streakCount++;
      streakTotal += habit.streak;
    }
    return (streakTotal / streakCount);
  }

  double getLongestStreak(context) {
    var longestStreakHabit;
    for (Habit habit
        in Provider.of<HabitManager>(context, listen: false).habits) {
      if (longestStreakHabit ??= null) {
        longestStreakHabit = habit;
      } else if (habit.streak > longestStreakHabit.streak) {
        longestStreakHabit = habit;
      }
    }
    return longestStreakHabit.streak;
  }

  double getAverageConfidenceLevel(context) {
    int habitNumber = 0;
    double totalHabitConfidence = 0;
    for (Habit habit
        in Provider.of<HabitManager>(context, listen: false).habits) {
      totalHabitConfidence += habit.confidenceLevel;
      habitNumber++;
    }
    return totalHabitConfidence / habitNumber;
  }

  int getWeekCompletions(context) {
    int weekCompletions = 0;
    DateTime startOfWeek =
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

    for (Habit habit
        in Provider.of<HabitManager>(context, listen: false).habits) {
      for (DateTime completedDate in habit.daysCompleted) {
        if (completedDate.isAfter(startOfWeek) &&
            completedDate.isBefore(startOfWeek.add(Duration(days: 7)))) {
          weekCompletions++;
        }
      }
    }

    return weekCompletions;
  }

  double getAverageDifficultyRating(context) {
    double totalHabitDifficulty = 0;
    for (Habit habit
        in Provider.of<HabitManager>(context, listen: false).habits) {
      StatsCalculator statsCalculator = StatsCalculator();
      double habitDifficultyAverage = statsCalculator
          .calculateAverageValueForStat('difficultyRating', habit.stats);

      totalHabitDifficulty += habitDifficultyAverage;
    }
    return totalHabitDifficulty /
        Provider.of<HabitManager>(context, listen: false).habits.length;
  }
}
