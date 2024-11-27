import 'package:fl_chart/fl_chart.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/stat_point.dart';

class HabitStat {
  final String habitName;
  final double completionRate;
  final int streak;

  HabitStat({
    required this.habitName,
    required this.completionRate,
    required this.streak,
  });
}

class StatisticsViewModel extends BaseViewModel {
  final _habitService = locator<HabitService>();
  final _userService = locator<UserService>();

  List<Habit> _habits = [];
  List<StatPoint> _statPoints = [];
  List<HabitStat> _habitStats = [];
  int _totalHabits = 0;
  double _completionRate = 0.0;
  int _bestStreak = 0;
  List<FlSpot> _completionData = [];
  List<FlSpot> _streakData = [];

  List<HabitStat> get habitStats => _habitStats;
  int get totalHabits => _totalHabits;
  double get completionRate => _completionRate;
  int get bestStreak => _bestStreak;
  List<FlSpot> get completionData => _completionData;
  List<FlSpot> get streakData => _streakData;

  StatisticsViewModel() {
    _initialize();
  }

  Future<void> _initialize() async {
    setBusy(true);
    try {
      await _loadHabits();
      await _loadStats();
      _calculateStats();
    } catch (e) {
      // Handle error
    } finally {
      setBusy(false);
    }
  }

  Future<void> _loadHabits() async {
    _habits = await _habitService.getUserHabits();
    _totalHabits = _habits.length;
  }

  Future<void> _loadStats() async {
    final user = await _userService.getCurrentUser();
    if (user != null) {
      _statPoints = user.stats;
    }
  }

  void _calculateStats() {
    if (_habits.isEmpty) return;

    // Calculate completion rate
    int totalCompletions = 0;
    int totalPossibleCompletions = 0;
    _bestStreak = 0;

    for (var habit in _habits) {
      totalCompletions += habit.daysCompleted.length;
      final daysSinceCreation =
          DateTime.now().difference(habit.dateCreated).inDays;
      totalPossibleCompletions += daysSinceCreation + 1;

      if (habit.streak != null && habit.streak! > _bestStreak) {
        _bestStreak = habit.streak!;
      }

      _habitStats.add(HabitStat(
        habitName: habit.title,
        completionRate: habit.completionRate ?? 0.0,
        streak: habit.streak ?? 0,
      ));
    }

    _completionRate = totalCompletions / totalPossibleCompletions;

    // Generate chart data
    if (_statPoints.isNotEmpty) {
      for (var i = 0; i < _statPoints.length; i++) {
        final point = _statPoints[i];
        _completionData.add(FlSpot(i.toDouble(), point.completions.toDouble()));
        _streakData.add(FlSpot(i.toDouble(), point.streak.toDouble()));
      }
    }

    notifyListeners();
  }

  void refreshStats() {
    _initialize();
  }
}
