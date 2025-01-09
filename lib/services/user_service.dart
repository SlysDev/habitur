import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/auth_service.dart';
import 'package:habitur/services/database_service.dart';
import 'package:habitur/services/local_storage_service.dart';
import 'package:habitur/services/stats/stats_calculation_service.dart';
import 'package:stacked/stacked.dart';
import 'stats/user_stats_service.dart';

import '../models/habit.dart';

class UserService with ListenableServiceMixin {
  final _databaseService = locator<DatabaseService>();
  final _localStorageService = locator<LocalStorageService>();
  final _authService = locator<AuthService>();
  final _statsCalculationService = locator<StatsCalculationService>();

  ReactiveValue<UserModel?> _currentUser = ReactiveValue<UserModel?>(null);
  UserModel? get currentUser => _currentUser.value;
  Stream<UserModel?> get userStream => _currentUser.values;

  UserService() {
    listenToReactiveValues([_currentUser]);
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<void> updateCompletions(UserModel user, {double amount = 1.0}) async {
    if (user.stats == null) return;

    int currentDayIndex =
        user.stats!.indexWhere((stat) => isSameDay(stat.date, DateTime.now()));

    if (currentDayIndex != -1) {
      await _localStorageService.updateUserStat(
          'completions', user.stats![currentDayIndex].completions + amount);
    }
  }

  Future<void> undoCompletion(UserModel user, {double? amount}) async {
    if (user.stats == null) return;

    int currentDayIndex =
        user.stats!.indexWhere((stat) => isSameDay(stat.date, DateTime.now()));

    if (currentDayIndex != -1) {
      int currentCompletions = user.stats![currentDayIndex].completions;
      if (currentCompletions > 0) {
        double amountToUndo = amount ?? 1.0;
        double newCompletions =
            (currentCompletions - amountToUndo).clamp(0.0, double.infinity);

        await _localStorageService.updateUserStat(
            'completions', newCompletions);
      }
    }
  }

  Future<void> updateConfidenceLevel(
      UserModel user, double newConfidenceLevel) async {
    if (user.stats == null) return;

    int currentDayIndex =
        user.stats!.indexWhere((stat) => isSameDay(stat.date, DateTime.now()));

    if (currentDayIndex == -1) {
      if (user.stats!.isEmpty) {
        await _localStorageService.addNewUserStat();
        currentDayIndex = 0;
      } else {
        StatPoint newEntry = user.stats!.last;
        newEntry.date = DateTime.now();
        await _localStorageService.addNewUserStat();
        currentDayIndex = user.stats!.length - 1;
      }
    }
    user.stats![currentDayIndex].confidenceLevel = newConfidenceLevel;
    await _localStorageService.updateUserStat(
        'confidenceLevel', newConfidenceLevel);
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

  Future<void> unlogHabitCompletion() async {
    final user = await getCurrentUser();
    if (user == null) return;

    await undoCompletion(user);
  }

  Future<void> recordAverageConfidenceLevel(List<Habit> habits) async {
    final user = await getCurrentUser();
    if (user == null) return;

    double averageConfidence = _statsCalculationService.calculateStatAverage(
        'confidenceLevel', habits);
    await updateConfidenceLevel(user, averageConfidence);
  }

  Future<void> fillInMissingDays() async {
    final user = await getCurrentUser();
    if (user == null || user.stats == null || user.stats!.isEmpty) return;

    List<StatPoint> stats = getStats(user);
    DateTime lastDate = stats.last.date;
    DateTime now = DateTime.now();

    while (!isSameDay(lastDate, now)) {
      lastDate = lastDate.add(Duration(days: 1));
      StatPoint newStat = StatPoint(
        date: lastDate,
        confidenceLevel: 0,
        completions: 0,
        streak: 0,
      );
      stats.add(newStat);
    }

    await _localStorageService.updateAllStats(stats);
  }

  Future<void> sortStats() async {
    final user = await getCurrentUser();
    if (user == null || user.stats == null) return;

    List<StatPoint> stats = getStats(user);
    stats.sort((a, b) => a.date.compareTo(b.date));
    await _localStorageService.updateAllStats(stats);
  }

  Future<void> updateStats(List<Habit> habits) async {
    final user = await getCurrentUser();
    if (user != null) {
      await _databaseService.updateUserStats(user.uid, user.stats);

      await updateUser(user);
    }
  }

  Future<UserModel?> getCurrentUser() async {
    return await _localStorageService.getCurrentUser();
  }

  Future<UserModel?> getUserById(String userId) async {
    return await _databaseService.getUser(userId);
  }

  Future<void> createUser(UserModel user) async {
    await _databaseService.createUser(user);
    await _localStorageService.setCurrentUser(user);
    _currentUser.value = user;
    notifyListeners();
  }

  Future<void> updateUser(UserModel user) async {
    await _databaseService.updateUser(user);
    await _localStorageService.setCurrentUser(user);
    _currentUser.value = user;
    notifyListeners();
  }

  Future<void> loadUser(String userId, {forceDB = false}) async {
    UserModel? localStorageUser = await _localStorageService.getCurrentUser();
    if (forceDB || localStorageUser == null) {
      _currentUser.value = await _databaseService.getUser(userId);
      if (_currentUser.value != null) {
        await _localStorageService.setCurrentUser(_currentUser.value!);
      }
    } else {
      // use LS value
      _currentUser.value = localStorageUser;
    }
    notifyListeners();
  }

  Future<void> loadFromRemote() async {
    final String? userID = _authService.currentUser?.uid ?? currentUser?.uid;
    if (userID == null) throw Exception('User is logged out');
    final user = await _databaseService.getUser(userID);
    if (user != null) {
      _currentUser.value = user;
      await _localStorageService.setCurrentUser(user);
      notifyListeners();
    }
  }

  Future<void> loadFromLocal() async {
    final user = await _localStorageService.getCurrentUser();
    if (user != null) {
      _currentUser.value = user;
      notifyListeners();
    }
  }
}
