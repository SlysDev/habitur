import 'package:habitur/models/habit.dart';
import 'package:habitur/services/stats/base_stats_service.dart';

class UserStatsService extends BaseStatsService {
  double calculateStatAverage(String statisticName, List<Habit> habits) {
    if (habits.isEmpty) return 0.0;

    double sum = 0.0;
    for (Habit habit in habits) {
      if (habit.stats.isEmpty) {
        sum += 0;
      } else {
        sum += calculateAverageValueForStat(habit.stats, statisticName);
      }
    }
    return sum / habits.length;
  }

  double calculateOverallSlope(String statisticName, List<Habit> habits) {
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

  int getTotalHabitsCompleted(List<Habit> habits) {
    return habits.fold(0, (total, habit) => total + habit.daysCompleted.length);
  }

  double getLongestStreak(List<Habit> habits) {
    if (habits.isEmpty) return 0.0;

    return habits
        .map((habit) => habit.streak)
        .reduce((max, streak) => streak > max ? streak : max)
        .toDouble();
  }

  int getWeekCompletions(List<Habit> habits) {
    if (habits.isEmpty) return 0;

    final startOfWeek =
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

    return habits.fold(0, (total, habit) {
      return total +
          habit.daysCompleted
              .where((date) =>
                  date.isAfter(startOfWeek) &&
                  date.isBefore(startOfWeek.add(Duration(days: 7))))
              .length;
    });
  }

  double calculateOverallProgress(List<Habit> habits) {
    if (habits.isEmpty) return 0.0;

    return habits.fold(0.0, (total, habit) {
          if (habit.stats.isEmpty) return total;
          return total + (habit.stats.last.completions / habit.targetGoal);
        }) /
        habits.length;
  }

  // Goal achievement analysis
  Map<String, double> calculateGoalAchievementRates(List<Habit> habits) {
    if (habits.isEmpty) return {};

    var rates = <String, double>{};
    for (var habit in habits) {
      if (habit.stats.isEmpty) continue;
      rates[habit.id.toString()] =
          habit.stats.where((s) => s.completions >= habit.targetGoal).length /
              habit.stats.length;
    }
    return rates;
  }

  // Best/worst performing habits
  List<Habit> getBestPerformingHabits(List<Habit> habits) {
    return List.from(habits)
      ..sort((a, b) {
        double rateA = calculateGoalAchievementRates([a])[a.id] ?? 0.0;
        double rateB = calculateGoalAchievementRates([b])[b.id] ?? 0.0;
        return rateB.compareTo(rateA);
      });
  }

  // // Category performance TODO: Think about implementing habit categories
  // Map<String, double> getCategoryPerformance(List<Habit> habits) {
  //   var categoryStats = <String, Map<String, int>>{};

  //   for (var habit in habits) {
  //     if (habit.category == null) continue;

  //     categoryStats.putIfAbsent(habit.category!, () => {
  //       'completed': 0,
  //       'total': 0
  //     });

  //     for (var stat in habit.stats) {
  //       categoryStats[habit.category]!['total'] =
  //         (categoryStats[habit.category]!['total'] ?? 0) + 1;
  //       if (stat.completions >= habit.targetGoal) {
  //         categoryStats[habit.category]!['completed'] =
  //           (categoryStats[habit.category]!['completed'] ?? 0) + 1;
  //       }
  //     }
  //   }

  //   var performance = <String, double>{};
  //   categoryStats.forEach((category, stats) {
  //     if (stats['total']! > 0) {
  //       performance[category] = stats['completed']! / stats['total']!;
  //     }
  //   });

  //   return performance;
  // }

  // User engagement metrics
  Map<String, dynamic> calculateEngagementMetrics(List<Habit> habits) {
    if (habits.isEmpty) return {};

    var now = DateTime.now();
    var thirtyDaysAgo = now.subtract(Duration(days: 30));

    int totalActions = 0;
    int daysActive = 0;
    Set<DateTime> activeDays = {};

    for (var habit in habits) {
      for (var stat in habit.stats) {
        if (stat.date.isAfter(thirtyDaysAgo)) {
          totalActions += stat.completions;
          if (stat.completions > 0) {
            activeDays
                .add(DateTime(stat.date.year, stat.date.month, stat.date.day));
          }
        }
      }
    }

    daysActive = activeDays.length;

    return {
      'totalActions': totalActions,
      'daysActive': daysActive,
      'engagementRate': daysActive / 30,
      'averageActionsPerDay': totalActions / 30,
    };
  }

  // Enhanced user stats
  Map<String, dynamic> getUserStats(List<Habit> habits) {
    if (habits.isEmpty)
      return {
        'totalHabitsCompleted': 0,
        'longestStreak': 0.0,
        'weekCompletions': 0,
        'overallProgress': 0.0,
        'goalAchievementRates': <String, double>{},
        'engagement': calculateEngagementMetrics([]),
        'rankedHabits': <String>[],
      };

    return {
      'totalHabitsCompleted': getTotalHabitsCompleted(habits),
      'longestStreak': getLongestStreak(habits),
      'weekCompletions': getWeekCompletions(habits),
      'overallProgress': calculateOverallProgress(habits),
      'goalAchievementRates': calculateGoalAchievementRates(habits),
      'engagement': calculateEngagementMetrics(habits),
      'rankedHabits':
          getBestPerformingHabits(habits).map((h) => h.id.toString()).toList(),
    };
  }
}
