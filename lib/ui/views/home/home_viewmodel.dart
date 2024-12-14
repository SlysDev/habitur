import 'package:flutter/material.dart';
import 'package:habitur/enums/snackbar_type.dart';
import 'package:habitur/models/habit_interface.dart';
import 'package:habitur/services/database_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/app/app.router.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:habitur/services/data_service.dart';
import 'package:habitur/services/status_service.dart';
import 'package:habitur/services/notification_scheduling_service.dart';
import 'package:habitur/services/settings_service.dart';
import '../../../enums/bottom_sheet_type.dart';

class HomeViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _habitService = locator<HabitService>();
  final _userService = locator<UserService>();
  final _dataService = locator<DataService>();
  final _statusService = locator<StatusService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _notificationSchedulingService =
      locator<NotificationSchedulingService>();
  final _settingsService = locator<SettingsService>();

  int _currentIndex = 0;
  String _userName = '';
  int _totalHabits = 0;
  int _currentStreak = 0;
  int _userLevel = 1;
  int _userXP = 0;

  int get currentIndex => _currentIndex;
  List<HabitInterface> get habits => _habitService.habits;
  String get userName => _userName;
  int get totalHabits => _totalHabits;
  int get currentStreak => _currentStreak;
  int get userLevel => _userLevel;
  int get userXP => _userXP;
  bool get communityFeaturesEnabled =>
      _settingsService.getCommunityFeaturesEnabled();

  HomeViewModel() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _statusService.executeWithLoading(
      loadingMessage: 'Loading your data...',
      operation: () async {
        await _loadUserData();
        await _habitService.getUserHabits();
        await _rescheduleNotificationsIfEnabled();
      },
      successMessage: 'Welcome back, $_userName!',
    );
  }

  Future<void> refreshData() async {
    await _statusService.executeWithLoading(
      loadingMessage: 'Refreshing your data...',
      operation: () async {
        await _dataService.loadAllData(forceDbLoad: true);
        await _loadUserData();
        await _habitService.getUserHabits();
        await _rescheduleNotificationsIfEnabled();
      },
      successMessage: 'Data refreshed successfully',
    );
  }

  Future<void> _rescheduleNotificationsIfEnabled() async {
    try {
      if (_habitService.habits.isNotEmpty) {
        await _notificationSchedulingService.rescheduleNotifications();
      }
    } catch (e) {
      debugPrint('Failed to reschedule notifications: $e');
    }
  }

  Future<void> _loadUserData() async {
    final user = await _userService.getCurrentUser();
    if (user != null) {
      _userName = user.username;
      _totalHabits = _habitService.habits.length;
      _currentStreak = user.stats.last.streak;
      _userLevel = user.userLevel;
      _userXP = user.userXP;
      notifyListeners();
    }
  }

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();

    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        _navigationService.navigateTo(Routes.statisticsView);
        break;
      case 2:
        _navigationService.navigateTo(Routes.communityLeaderboardView);
        break;
    }
  }

  Future<void> navigateToSettings() async {
    await _navigationService.navigateTo(Routes.settingsView);
  }

  Future<void> navigateToAddHabit() async {
    final result = await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.addHabit,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.2),
    );

    if (result?.confirmed ?? false) {
      await _rescheduleNotificationsIfEnabled();
    }
  }

  @override
  List<ListenableServiceMixin> get listenableServices => [_habitService];
}
