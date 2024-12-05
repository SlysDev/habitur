import 'package:flutter/material.dart';
import 'package:habitur/enums/dialog_type.dart';
import 'package:habitur/services/database_service.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:habitur/services/local_storage_service.dart';
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

class SettingsViewModel extends BaseViewModel {
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

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  bool _isEmailVerified = false;
  bool get isEmailVerified => _isEmailVerified;

  bool _notificationsEnabled = false;
  bool get notificationsEnabled => _notificationsEnabled;

  bool _communityFeaturesEnabled = true;
  bool get communityFeaturesEnabled => _communityFeaturesEnabled;

  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  // Privacy settings
  SharingScope _statsScope = SharingScope.friends;
  SharingScope get statsScope => _statsScope;

  SharingScope _habitsScope = SharingScope.friends;
  SharingScope get habitsScope => _habitsScope;

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
      _notificationsEnabled =
          _getSetting('notifications')?.settingValue as bool? ?? false;
      _communityFeaturesEnabled =
          _getSetting('communityFeatures')?.settingValue as bool? ?? true;

      _statsScope = _getSetting('statsScope')?.settingValue as SharingScope? ??
          SharingScope.friends;
      _habitsScope =
          _getSetting('habitsScope')?.settingValue as SharingScope? ??
              SharingScope.friends;
      _shareActivities = stringToBool(
          _getSetting('shareActivities')?.settingValue as String? ?? 'true');
      _shareHabitCompletions = stringToBool(
          _getSetting('shareHabitCompletions')?.settingValue as String? ??
              'true');
      _shareStreakMilestones = stringToBool(
          _getSetting('shareStreakMilestones')?.settingValue as String? ??
              'true');
      _shareNewHabits = stringToBool(
          _getSetting('shareNewHabits')?.settingValue as String? ?? 'true');
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
      final setting = SettingModel(
        settingName: settingName,
        settingValue: value,
      );

      await _settingsService.updateSetting(setting);

      // Update local state based on setting name
      switch (settingName) {
        case 'notifications':
          _notificationsEnabled = value as bool;
          if (_notificationsEnabled) {
            await _notificationService.requestPermission();
          }
          break;
        case 'communityFeatures':
          _communityFeaturesEnabled = value as bool;
          break;
        case 'statsScope':
          _statsScope = value as SharingScope;
          break;
        case 'habitsScope':
          _habitsScope = value as SharingScope;
          break;
        case 'shareActivities':
          _shareActivities = value as bool;
          break;
        case 'shareHabitCompletions':
          _shareHabitCompletions = value as bool;
          break;
        case 'shareStreakMilestones':
          _shareStreakMilestones = value as bool;
          break;
        case 'shareNewHabits':
          _shareNewHabits = value as bool;
          break;
      }
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

  void toggleCommunityFeatures(bool isEnabled) async{
    _communityFeaturesEnabled = isEnabled;
    notifyListeners();
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
        await _localStorageService.clearAllHiveData();
        await _databaseService.clearUserData(_authService.currentUser!.uid);
        await _settingsService.resetToDefaults();
        await _navigationService.clearStackAndShow(Routes.startupView);
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
