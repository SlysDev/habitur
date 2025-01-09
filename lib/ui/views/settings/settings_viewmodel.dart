import 'package:flutter/material.dart';
import 'package:habitur/app/app.dialogs.dart';
import 'package:habitur/models/time_model.dart';
import 'package:habitur/services/database_service.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:habitur/services/local_storage_service.dart';
import 'package:habitur/services/shared_habits_service.dart';
import 'package:habitur/services/stats/user_stats_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:habitur/util_functions.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../models/setting.dart';
import '../../../models/privacy_settings.dart';
import '../../../services/auth_service.dart';
import '../../../services/settings_service.dart';
import '../../../services/notification_service.dart';
import '../../../services/notification_scheduling_service.dart';
import '../../../services/status_service.dart';
import '../../../services/community_service.dart';
import '../../views/social_feed/social_feed.dart';
import '../../../services/activity_service.dart';
import '../../../services/friends_service.dart';

class SettingsViewModel extends StreamViewModel<List<SettingModel>> {
  final _authService = locator<AuthService>();
  final _settingsService = locator<SettingsService>();
  final _notificationService = locator<NotificationService>();
  final _notificationSchedulingService =
      locator<NotificationSchedulingService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _userService = locator<UserService>();
  final _localStorageService = locator<LocalStorageService>();
  final _databaseService = locator<DatabaseService>();
  final _communityService = locator<CommunityService>();
  final _activityService = locator<ActivityService>();
  final _friendsService = locator<FriendsService>();
  final _habitService = locator<HabitService>();
  final _userStatsService = locator<UserStatsService>();
  final _sharedHabitsService = locator<SharedHabitsService>();

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  @override
  Stream<List<SettingModel>> get stream => _settingsService.settingsStream;
  List<SettingModel> get settings => data ?? [];

  bool get isEmailVerified => _authService.currentUser?.emailVerified ?? false;

  bool get notificationsEnabled => stringToBool(
      _settingsService.getSetting('notifications')?.settingValue?.toString() ??
          'true');

  bool get communityFeaturesEnabled => stringToBool(_settingsService
          .getSetting('communityFeatures')
          ?.settingValue
          ?.toString() ??
      'true');

  bool get isAdmin => _userService.currentUser?.isAdmin ?? false;

  // Privacy settings
  SharingScope get statsScope =>
      _settingsService.getSetting('statsScope')?.settingValue
          as SharingScope? ??
      SharingScope.friends;

  SharingScope get habitsScope =>
      _settingsService.getSetting('habitsScope')?.settingValue
          as SharingScope? ??
      SharingScope.friends;

  bool get shareActivities => stringToBool(
      _settingsService.getSetting('shareActivities')?.settingValue.toString() ??
          'true');

  bool get shareHabitCompletions => stringToBool(_settingsService
          .getSetting('shareHabitCompletions')
          ?.settingValue as String? ??
      'true');

  bool get shareStreakMilestones => stringToBool(_settingsService
          .getSetting('shareStreakMilestones')
          ?.settingValue as String? ??
      'true');

  bool get shareNewHabits => stringToBool(
      _settingsService.getSetting('shareNewHabits')?.settingValue as String? ??
          'true');

  // Reminder settings
  bool get dailyRemindersEnabled => stringToBool(
        _settingsService
                .getSetting('Daily Reminders')
                ?.settingValue
                .toString() ??
            'true',
      );

  int get numberOfReminders =>
      int.tryParse(_settingsService
              .getSetting('Number of Reminders')
              ?.settingValue
              .toString() ??
          '3') ??
      3;

  TimeModel get firstReminderTime =>
      _settingsService.getSetting('1st Reminder Time')?.settingValue
          as TimeModel? ??
      TimeModel(hour: 10, minute: 0);

  TimeModel get secondReminderTime =>
      _settingsService.getSetting('2nd Reminder Time')?.settingValue
          as TimeModel? ??
      TimeModel(hour: 16, minute: 0);

  TimeModel get thirdReminderTime =>
      _settingsService.getSetting('3rd Reminder Time')?.settingValue
          as TimeModel? ??
      TimeModel(hour: 22, minute: 0);

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> initialize() async {
    setBusy(true);

    try {
      final user = await _userService.getCurrentUser();
      if (user != null) {
        usernameController = TextEditingController(text: user.username);
        emailController = TextEditingController(text: user.email);
        bioController = TextEditingController(text: user.bio);
      }

      await _settingsService.loadSettings();
    } catch (e, s) {
      debugPrint('----------------- Failed to load settings:');
      debugPrint(e.toString());
      debugPrint(s.toString());
      await _dialogService.showCustomDialog(
        variant: DialogType.modern,
        title: 'Error',
        description: 'Failed to load settings: ${e.toString()}',
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> verifyEmail() async {
    setBusy(true);
    try {
      await _authService.sendVerificationEmail();
      await _dialogService.showDialog(
        title: 'Success',
        description: 'Verification email sent. Please check your inbox.',
      );
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Failed to send verification email: ${e.toString()}',
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> updateProfile() async {
    setBusy(true);
    try {
      final selectedUser = await _userService.getCurrentUser();
      await _userService.updateUser(
        selectedUser!.copyWith(
          username: usernameController.text,
          email: emailController.text,
          bio: bioController.text,
        ),
      );
      setBusy(false);
      await _dialogService.showCustomDialog(
        variant: DialogType.success,
        title: 'Success!',
        description: 'Profile updated successfully.',
      );
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Failed to update profile: ${e.toString()}',
      );
    } finally {}
  }

  Future<void> updateSetting<T>(String settingName, T value) async {
    setBusy(true);
    try {
      final settingValue = value is bool ? value.toString() : value;
      final setting = SettingModel(
        settingName: settingName,
        settingValue: settingValue,
      );

      await _settingsService.updateSetting(setting);
      rebuildUi();
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Failed to update setting: ${e.toString()}',
      );
    } finally {
      setBusy(false);
    }
  }

  void toggleCommunityFeatures(bool isEnabled) async {
    setBusy(true);
    if (isEnabled) {
      await _settingsService.enableCommunityFeatures();
      _activityService.enableActivityService();
      _friendsService.enableFriendsService();
    } else {
      await _settingsService.disableCommunityFeatures();
      _activityService.disableActivityService();
      _friendsService.disableFriendsService();
    }
    setBusy(false);
  }

  Future<void> logout() async {
    final response = await _dialogService.showConfirmationDialog(
      title: 'Logout',
      description: 'Are you sure you want to logout?',
      confirmationTitle: 'Logout',
      cancelTitle: 'Cancel',
    );

    if (response?.confirmed ?? false) {
      setBusy(true);
      try {
        await _authService.signOut();
        await _navigationService.clearStackAndShow(Routes.welcomeView);
      } catch (e) {
        await _dialogService.showDialog(
          title: 'Error',
          description: 'Failed to logout: ${e.toString()}',
        );
      } finally {
        setBusy(false);
      }
    }
  }

  Future<void> clearData() async {
    final response = await _dialogService.showConfirmationDialog(
      title: 'Clear Data',
      description: 'Are you sure you want to clear all data?',
      confirmationTitle: 'Clear',
      cancelTitle: 'Cancel',
    );

    if (response?.confirmed ?? false) {
      setBusy(true);
      try {
        await _habitService.clearCurrentUserHabits();
        await _userStatsService.clearCurrentUserStats();
        await _sharedHabitsService.clearCurrentUserSharedHabits();
        await _settingsService.resetToDefaults();
        await _navigationService.clearStackAndShow(Routes.startupView);
        await _communityService.clearCurrentUserChallengeData();
      } catch (e) {
        await _dialogService.showDialog(
          title: 'Error',
          description: 'Failed to clear data: ${e.toString()}',
        );
      } finally {
        setBusy(false);
      }
    }
  }

  Future<void> deleteAccount() async {
    final response = await _dialogService.showConfirmationDialog(
      title: 'Delete Account',
      description:
          'Are you sure you want to delete your account? This action cannot be undone.',
      confirmationTitle: 'Delete',
      cancelTitle: 'Cancel',
    );

    if (response?.confirmed ?? false) {
      setBusy(true);
      try {
        await _authService.deleteAccount();
        await _navigationService.clearStackAndShow(Routes.welcomeView);
      } catch (e) {
        await _dialogService.showDialog(
          title: 'Error',
          description: 'Failed to delete account: ${e.toString()}',
        );
      } finally {
        setBusy(false);
      }
    }
  }

  void navigateToAdminPanel() {
    _navigationService.navigateTo(Routes.adminView);
  }
}
