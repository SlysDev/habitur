import 'package:flutter/material.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/habit_visibility.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/auth_service.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:habitur/services/stats/base_stats_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:stacked/stacked.dart';

class ProfileDialogModel extends BaseViewModel {
  final _authService = locator<AuthService>();
  final _userService = locator<UserService>();
  final _habitService = locator<HabitService>();
  final _baseStatsService = locator<BaseStatsService>();

  late final String _uid;

  late final bool _isFriendProfile;

  UserModel? _userModel;

  UserModel? get userModel => _userModel;

  bool get isCurrentUser => _uid == _authService.currentUser!.uid;

  void initialize(String uid, bool isFriendProfile) {
    _uid = uid;
    _isFriendProfile = isFriendProfile;
  }

  Future<void> loadUserData() async {
    setBusy(true);
    try {
      if (_uid == _authService.currentUser!.uid) {
        _userModel = _userService.currentUser;
      } else {
        _userModel = await _userService.getUserById(_uid);
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      setBusy(false); // Marks the ViewModel as no longer busy
      notifyListeners(); // Notify listeners of data changes
    }
  }

  List<Habit> getCurrentUserHabits() {
    return _habitService.habits;
  }

  Future<void> updateHabitVisibility(String habitId, bool isVisible) async {
    final userModel = _userModel; // Use a local variable for field promotion.
    if (userModel == null) return;

    userModel.habitVisibilitySettings ??= [];
    var settingIndex = userModel.habitVisibilitySettings!
        .indexWhere((s) => s.habitId == habitId);

    if (settingIndex == -1) {
      userModel.habitVisibilitySettings!
          .add(HabitVisibility(habitId: habitId, isVisible: isVisible));
    } else {
      userModel.habitVisibilitySettings![settingIndex].isVisible = isVisible;
    }
    await _userService.updateUser(userModel); // No error here.
  }

  double getConfidenceLevel() {
    return _baseStatsService.calculateAverageValueForStat(
        _userModel?.stats ?? [], 'confidenceLevel');
  }
}
