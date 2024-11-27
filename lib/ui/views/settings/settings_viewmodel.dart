import 'package:flutter/material.dart';
import 'package:habitur/services/user_service.dart';
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

class SettingsViewModel extends BaseViewModel {
  final _authService = locator<AuthService>();
  final _settingsService = locator<SettingsService>();
  final _notificationService = locator<NotificationService>();
  final _notificationSchedulingService =
      locator<NotificationSchedulingService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _userService = locator<UserService>();
  final _statusService = locator<StatusService>();

  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController bioController;

  bool _isEmailVerified = false;
  bool get isEmailVerified => _isEmailVerified;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  bool _notificationsEnabled = false;
  bool get notificationsEnabled => _notificationsEnabled;

  bool _communityFeaturesEnabled = true;
  bool get communityFeaturesEnabled => _communityFeaturesEnabled;

  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  // Privacy settings
  String _statsScope = 'friends';
  String get statsScope => _statsScope;

  String _habitsScope = 'friends';
  String get habitsScope => _habitsScope;

  bool _shareActivities = true;
  bool get shareActivities => _shareActivities;

  bool _shareHabitCompletions = true;
  bool get shareHabitCompletions => _shareHabitCompletions;

  bool _shareStreakMilestones = true;
  bool get shareStreakMilestones => _shareStreakMilestones;

  bool _shareNewHabits = true;
  bool get shareNewHabits => _shareNewHabits;

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
        _isEmailVerified = _authService.currentUser?.emailVerified ?? false;
        _isAdmin = user.isAdmin;
      }

      await _settingsService.loadSettings();
      final settings = _settingsService.settings;

      // Load settings from the list
      _isDarkMode = _getSetting('darkMode')?.settingValue as bool? ?? false;
      _notificationsEnabled =
          _getSetting('notifications')?.settingValue as bool? ?? false;
      _communityFeaturesEnabled =
          _getSetting('communityFeatures')?.settingValue as bool? ?? true;

      _statsScope =
          _getSetting('statsScope')?.settingValue as String? ?? 'friends';
      _habitsScope =
          _getSetting('habitsScope')?.settingValue as String? ?? 'friends';
      _shareActivities =
          _getSetting('shareActivities')?.settingValue as bool? ?? true;
      _shareHabitCompletions =
          _getSetting('shareHabitCompletions')?.settingValue as bool? ?? true;
      _shareStreakMilestones =
          _getSetting('shareStreakMilestones')?.settingValue as bool? ?? true;
      _shareNewHabits =
          _getSetting('shareNewHabits')?.settingValue as bool? ?? true;
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Failed to load settings: ${e.toString()}',
      );
    } finally {
      setBusy(false);
    }
  }

  SettingModel? _getSetting(String name) {
    return _settingsService.settings.firstWhere(
      (s) => s.settingName == name,
      orElse: () => SettingModel(settingName: name, settingValue: null),
    );
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
      await _dialogService.showDialog(
        title: 'Success',
        description: 'Profile updated successfully.',
      );
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Failed to update profile: ${e.toString()}',
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> updateStatsScope(String? newValue) async {
    if (newValue != null) {
      setBusy(true);
      try {
        await _settingsService.updateSetting(
          SettingModel(settingName: 'statsScope', settingValue: newValue),
        );
        _statsScope = newValue;
        notifyListeners();
      } catch (e) {
        await _dialogService.showDialog(
          title: 'Error',
          description: 'Failed to update stats scope: ${e.toString()}',
        );
      } finally {
        setBusy(false);
      }
    }
  }

  Future<void> updateHabitsScope(String? newValue) async {
    if (newValue != null) {
      setBusy(true);
      try {
        await _settingsService.updateSetting(
          SettingModel(settingName: 'habitsScope', settingValue: newValue),
        );
        _habitsScope = newValue;
        notifyListeners();
      } catch (e) {
        await _dialogService.showDialog(
          title: 'Error',
          description: 'Failed to update habits scope: ${e.toString()}',
        );
      } finally {
        setBusy(false);
      }
    }
  }

  Future<void> updateShareActivities(bool value) async {
    setBusy(true);
    try {
      await _settingsService.updateSetting(
        SettingModel(settingName: 'shareActivities', settingValue: value),
      );
      _shareActivities = value;
      notifyListeners();
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Failed to update sharing settings: ${e.toString()}',
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> updateShareHabitCompletions(bool value) async {
    setBusy(true);
    try {
      await _settingsService.updateSetting(
        SettingModel(settingName: 'shareHabitCompletions', settingValue: value),
      );
      _shareHabitCompletions = value;
      notifyListeners();
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Failed to update sharing settings: ${e.toString()}',
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> updateShareStreakMilestones(bool value) async {
    setBusy(true);
    try {
      await _settingsService.updateSetting(
        SettingModel(settingName: 'shareStreakMilestones', settingValue: value),
      );
      _shareStreakMilestones = value;
      notifyListeners();
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Failed to update sharing settings: ${e.toString()}',
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> updateShareNewHabits(bool value) async {
    setBusy(true);
    try {
      await _settingsService.updateSetting(
        SettingModel(settingName: 'shareNewHabits', settingValue: value),
      );
      _shareNewHabits = value;
      notifyListeners();
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Failed to update sharing settings: ${e.toString()}',
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> updateDarkMode(bool value) async {
    setBusy(true);
    try {
      await _settingsService.updateSetting(
        SettingModel(settingName: 'darkMode', settingValue: value),
      );
      _isDarkMode = value;
      notifyListeners();
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Failed to update dark mode: ${e.toString()}',
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> updateNotifications(bool value) async {
    setBusy(true);
    try {
      if (value) {
        await _notificationService.requestPermission();
      }

      await _settingsService.updateSetting(
        SettingModel(settingName: 'notifications', settingValue: value),
      );
      _notificationsEnabled = value;

      if (value) {
        // Schedule notifications if they're being enabled
        await _notificationSchedulingService.rescheduleNotifications(
          _dialogService.navigatorKey!.currentContext!,
        );
      } else {
        // Cancel all notifications if they're being disabled
        await _notificationService.cancelAllScheduledNotifications();
      }

      notifyListeners();
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Failed to update notification settings: ${e.toString()}',
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> updateCommunityFeatures(bool value) async {
    setBusy(true);
    try {
      await _settingsService.updateSetting(
        SettingModel(settingName: 'communityFeatures', settingValue: value),
      );
      _communityFeaturesEnabled = value;
      notifyListeners();
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Failed to update community features: ${e.toString()}',
      );
    } finally {
      setBusy(false);
    }
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
