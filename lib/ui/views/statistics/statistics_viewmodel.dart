import 'package:flutter/material.dart';
import 'package:habitur/models/habit_interface.dart';
import 'package:habitur/services/stats/user_stats_service.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/stat_point.dart';

class StatisticsViewModel extends BaseViewModel {
  final _habitService = locator<HabitService>();
  final _userService = locator<UserService>();
  final _userStatsService = locator<UserStatsService>();

  List<HabitInterface> _habits = [];
  List<StatPoint> _statPoints = [];
  List<StatPoint> _habitStats = [];
  double _completionRate = 0.0;
  int _bestStreak = 0;
  Map<dynamic, dynamic> _userMetrics = {
    'totalHabitsCompleted': 0,
    'longestStreak': 0,
    'weekCompletions': 0,
    'overallProgress': 0.0,
    'goalAchievementRates': {},
    'engagement': {},
    'rankedHabits': [],
  };

  // Getters
  List<StatPoint> get habitStats => _habitStats;
  List<StatPoint> get statPoints => _statPoints;
  Map<dynamic, dynamic> get userMetrics => _userMetrics;

  int get totalHabits => userMetrics['totalHabitsCompleted'];
  double get completionRate => _completionRate;
  int get bestStreak => userMetrics['longestStreak'];
  List<HabitInterface> get habits => _habits;

  Future<void> initialize() async {
    setBusy(true);
    debugPrint('Initializing Statistics Viewmodel...');
    try {
      await _loadHabits();
      await _loadStats();
      rebuildUi();
      debugPrint('Done! Rebuilt UI');
    } catch (e) {
      // Handle error
    } finally {
      setBusy(false);
    }
  }

  Future<void> _loadHabits() async {
    _habits = await _habitService.getUserHabits();
    rebuildUi();
  }

  Future<void> _loadStats() async {
    final user = await _userService.getCurrentUser();
    _userMetrics = _userStatsService.getUserStats(_habits);
    if (user != null) {
      _statPoints = user.stats;
    }
    rebuildUi();
  }

  void refreshStats() {
    initialize();
  }
}
