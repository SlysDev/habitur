import 'package:flutter/material.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/modules/user_stats_calculator.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';

class UserStatsHandler {
  Database db = Database();

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void updateCompletions(UserModel user, context, {double amount = 1.0}) {
    if (user.stats == null) return;

    int currentDayIndex =
        user.stats!.indexWhere((stat) => isSameDay(stat.date, DateTime.now()));

    if (currentDayIndex != -1) {
      Provider.of<UserLocalStorage>(context, listen: false).updateStatByName(
          'completions',
          user.stats![currentDayIndex].completions + amount,
          context);
    }
  }

  void undoCompletion(UserModel user, context, {double? amount}) {
    if (user.stats == null) return;

    int currentDayIndex =
        user.stats!.indexWhere((stat) => isSameDay(stat.date, DateTime.now()));

    if (currentDayIndex != -1) {
      int currentCompletions = user.stats![currentDayIndex].completions;
      if (currentCompletions > 0) {
        // If amount is null, undo the last recorded amount or default to 1
        double amountToUndo = amount ?? 1.0;
        // Don't let completions go below 0
        double newCompletions =
            (currentCompletions - amountToUndo).clamp(0.0, double.infinity);

        Provider.of<UserLocalStorage>(context, listen: false)
            .updateStatByName('completions', newCompletions, context);
      }
    }
  }

  void updateConfidenceLevel(
      UserModel user, double newConfidenceLevel, context) {
    if (user.stats == null) return;

    int currentDayIndex =
        user.stats!.indexWhere((stat) => isSameDay(stat.date, DateTime.now()));

    if (currentDayIndex == -1) {
      if (user.stats!.isEmpty) {
        Provider.of<UserLocalStorage>(context, listen: false)
            .addNewStat(context);
        currentDayIndex = 0;
      } else {
        StatPoint newEntry = user.stats!.last;
        newEntry.date = DateTime.now();
        Provider.of<UserLocalStorage>(context, listen: false)
            .addNewStat(context);
        currentDayIndex = user.stats!.length - 1;
      }
    }
    user.stats![currentDayIndex].confidenceLevel = newConfidenceLevel;
  }

  List<StatPoint> getStatsForDateRange(
      UserModel user, DateTime startDate, DateTime endDate) {
    if (user.stats == null || user.stats!.isEmpty) {
      return [];
    }

    DateTime firstDate = user.stats!.first.date;
    List<StatPoint> statsInRange = [];

    for (DateTime date = startDate;
        date.isBefore(endDate.add(Duration(days: 1)));
        date = date.add(Duration(days: 1))) {
      if (user.stats!
              .indexWhere((dataPoint) => isSameDay(dataPoint.date, date)) !=
          -1) {
        statsInRange.add(user.stats!
            .firstWhere((dataPoint) => isSameDay(dataPoint.date, date)));
      } else if (date.isAfter(firstDate)) {
        statsInRange.add(StatPoint(
          date: date,
          confidenceLevel: 0,
          completions: 0,
          streak: 0,
        ));
      }
    }
    return statsInRange;
  }

  List<StatPoint> getStats(UserModel user) {
    if (user.stats == null) return [];
    return user.stats!.map((stat) => stat).toList(); // make a copy
  }

  Future<void> logHabitCompletion(BuildContext context) async {
    final stopwatch = Stopwatch()..start();
    try {
      final userStorage = Provider.of<UserLocalStorage>(context, listen: false);
      final habitManager = Provider.of<HabitManager>(context, listen: false);
      final user = userStorage.currentUser;
      final userStatsCalculator = UserStatsCalculator(habitManager.habits);
      final now = DateTime.now();

      // Pre-calculate all stats values immediately to parallelize with other operations
      final statsStart = stopwatch.elapsedMilliseconds;
      final Map<String, dynamic> statsUpdates = {
        'date': now,
        'confidenceLevel':
            userStatsCalculator.calculateStatAverage('confidenceLevel'),
        'streak': userStatsCalculator.calculateStatAverage('streak').toInt(),
        'consistencyFactor':
            userStatsCalculator.calculateStatAverage('consistencyFactor'),
        'difficultyRating':
            userStatsCalculator.calculateStatAverage('difficultyRating'),
        'slopeCompletions':
            userStatsCalculator.calculateOverallSlope('completions'),
        'slopeConsistency':
            userStatsCalculator.calculateOverallSlope('consistencyFactor'),
        'slopeConfidenceLevel':
            userStatsCalculator.calculateOverallSlope('confidenceLevel'),
        'slopeDifficultyRating':
            userStatsCalculator.calculateOverallSlope('difficultyRating'),
      };
      debugPrint(
          'Stats calculation took: ${stopwatch.elapsedMilliseconds - statsStart}ms');

      // Do all local updates
      final localStart = stopwatch.elapsedMilliseconds;
      final stats = getStats(user);

      // Optimize date comparison by checking only once
      bool needsNewPoint = true;
      int currentDayIndex = -1;

      for (int i = 0; i < stats.length; i++) {
        final stat = stats[i];
        if (stat.date.year == now.year &&
            stat.date.month == now.month &&
            stat.date.day == now.day) {
          needsNewPoint = false;
          currentDayIndex = i;
          break;
        }
      }

      if (needsNewPoint) {
        fillInMissingDays(context);
        sortStats(context);
      }

      // Update local stats and increment habitur rating in parallel
      await Future.wait([
        Future(() async {
          if (currentDayIndex != -1) {
            statsUpdates['completions'] =
                stats[currentDayIndex].completions + 1;
            await userStorage.updateUserStats(statsUpdates, context);
          } else {
            final newEntry = StatPoint(
              date: now,
              completions: 1,
              confidenceLevel: statsUpdates['confidenceLevel'],
              streak: statsUpdates['streak'],
              consistencyFactor: statsUpdates['consistencyFactor'],
              difficultyRating: statsUpdates['difficultyRating'],
              slopeCompletions: statsUpdates['slopeCompletions'],
              slopeConsistency: statsUpdates['slopeConsistency'],
              slopeConfidenceLevel: statsUpdates['slopeConfidenceLevel'],
              slopeDifficultyRating: statsUpdates['slopeDifficultyRating'],
            );
            userStorage.addUserStatPoint(context, newEntry);
          }
        }),
        Future(() => userStorage.addHabiturRating()),
      ]);

      debugPrint(
          'Local storage update took: ${stopwatch.elapsedMilliseconds - localStart}ms');

      // Batch all remote updates
      final remoteStart = stopwatch.elapsedMilliseconds;
      await Future.wait([
        // Save to local storage
        userStorage.saveData(context),

        // Upload all data in parallel
        Future(() async {
          await Future.wait([
            db.userDatabase.uploadUserData(context),
            db.statsDatabase
                .updateAllStats(AuthService().currentUser!.uid, stats)
          ]);
        }),
      ]);
      debugPrint(
          'Remote updates took: ${stopwatch.elapsedMilliseconds - remoteStart}ms');
    } finally {
      debugPrint(
          'Total habit completion took: ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.stop();
    }
  }

  Future<void> unlogHabitCompletion(BuildContext context) async {
    UserModel user =
        Provider.of<UserLocalStorage>(context, listen: false).currentUser;
    UserStatsCalculator userStatsCalculator = UserStatsCalculator(
        Provider.of<HabitManager>(context, listen: false).habits);
    fillInMissingDays(context);

    int currentDayIndex = getStats(user).indexWhere((stat) =>
        stat.date.year == DateTime.now().year &&
        stat.date.month == DateTime.now().month &&
        stat.date.day == DateTime.now().day);

    if (currentDayIndex != -1) {
      debugPrint('updating current day');
      // Decrement completion count if it's positive
      if (getStats(user)[currentDayIndex].completions > 0) {
        Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
            'completions',
            getStats(user)[currentDayIndex].completions - 1,
            context);
        Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
            'confidenceLevel',
            userStatsCalculator.calculateStatAverage('confidenceLevel'),
            context);
        Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
            'streak',
            userStatsCalculator.calculateStatAverage('streak').toInt(),
            context);
        Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
            'consistencyFactor',
            userStatsCalculator.calculateStatAverage('consistencyFactor'),
            context);
        Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
            'difficultyRating',
            userStatsCalculator.calculateStatAverage('difficultyRating'),
            context);
        Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
            'slopeCompletions',
            userStatsCalculator.calculateOverallSlope('completions'),
            context);
        Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
            'slopeConsistency',
            userStatsCalculator.calculateOverallSlope('consistencyFactor'),
            context);
        Provider.of<UserLocalStorage>(context, listen: false).updateUserStat(
            'slopeConfidenceLevel',
            userStatsCalculator.calculateOverallSlope('confidenceLevel'),
            context);
      }
    } else {
      // No need to undo anything if there's no entry for the current day
      debugPrint('No entry found for unlogging habit completion.');
    }

    recordAverageConfidenceLevel(context);
    db.statsDatabase.updateAllStats(AuthService().currentUser!.uid, user.stats);
  }

  void recordAverageConfidenceLevel(context) {
    UserModel user =
        Provider.of<UserLocalStorage>(context, listen: false).currentUser;
    UserStatsCalculator calc = UserStatsCalculator(
        Provider.of<HabitManager>(context, listen: false).habits);
    int currentDayIndex = getStats(user).indexWhere(
      (stat) =>
          stat.date.year == DateTime.now().year &&
          stat.date.month == DateTime.now().month &&
          stat.date.day == DateTime.now().day,
    );
    // If the two dates are more than a minute apart
    if (getStats(user).isEmpty) {
      Provider.of<UserLocalStorage>(context, listen: false).addUserStatPoint(
          context,
          StatPoint(
              date: DateTime.now(),
              completions: 0,
              confidenceLevel: 1,
              streak: 0));
    } else if (currentDayIndex == -1) {
      StatPoint newEntry = getStats(user).last;
      newEntry.date = DateTime.now();
      newEntry.confidenceLevel = calc.calculateStatAverage('confidenceLevel');
      Provider.of<UserLocalStorage>(context, listen: false)
          .addUserStatPoint(context, newEntry);
    } else {
      getStats(user)[currentDayIndex].confidenceLevel =
          calc.calculateStatAverage('confidenceLevel');
    }
  }

  void fillInMissingDays(context) {
    debugPrint('filling in missing days... (user)');
    UserModel user =
        Provider.of<UserLocalStorage>(context, listen: false).currentUser;
    UserStatsCalculator statsCalculator = UserStatsCalculator(
        Provider.of<HabitManager>(context, listen: false).habits);
    // Create a DateTime object for the start date of the habit
    if (getStats(user).isEmpty) {
      return;
    }
    DateTime startDate = getStats(user).first.date;

    // Iterate through each day from the start date to the current date
    for (DateTime day =
            DateTime(startDate.year, startDate.month, startDate.day);
        day.isBefore(DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day));
        day = day.add(Duration(days: 1))) {
      // Check if a StatPoint already exists for the current day
      if (getStats(user).indexWhere((dataPoint) =>
              DateTime(dataPoint.date.year, dataPoint.date.month,
                  dataPoint.date.day) ==
              day) ==
          -1) {
        // If no StatPoint exists, create a new one with 0 completions
        StatPoint newStatPoint = StatPoint(
          date: day,
          completions: 0,
          confidenceLevel:
              statsCalculator.calculateStatAverage('confidenceLevel'),
          streak: 0,
          consistencyFactor:
              statsCalculator.calculateStatAverage('consistencyFactor'),
          difficultyRating:
              statsCalculator.calculateStatAverage('difficultyRating'),
          slopeCompletions:
              statsCalculator.calculateOverallSlope('completions'),
          slopeConsistency:
              statsCalculator.calculateOverallSlope('consistencyFactor'),
          slopeConfidenceLevel:
              statsCalculator.calculateOverallSlope('confidenceLevel'),
          slopeDifficultyRating:
              statsCalculator.calculateOverallSlope('difficultyRating'),
        );
        Provider.of<UserLocalStorage>(context, listen: false)
            .addUserStatPoint(context, newStatPoint);
      }
    }
  }

  void sortStats(context) {
    UserModel user =
        Provider.of<UserLocalStorage>(context, listen: false).currentUser;
    List<StatPoint> userStats =
        getStats(user).map((stat) => stat).toList(); // make a copy
    userStats.sort((a, b) => a.date.compareTo(b.date));
    Provider.of<UserLocalStorage>(context, listen: false)
        .updateUserProperty('stats', userStats);
  }
}
