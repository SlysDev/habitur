import 'package:flutter/foundation.dart';
import 'package:habitur/services/database_service.dart';
import 'package:habitur/services/local_storage_service.dart';
import 'package:habitur/services/notification_scheduling_service.dart';
import 'package:habitur/services/settings_service.dart';
import 'package:habitur/util_functions.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/app/app.router.dart';
import 'package:habitur/services/auth_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:habitur/services/data_service.dart';
import 'package:habitur/services/notification_service.dart';

class StartupViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _authService = locator<AuthService>();
  final _userService = locator<UserService>();
  final _dataService = locator<DataService>();
  final _notificationService = locator<NotificationService>();
  final _notificationSchedulingService =
      locator<NotificationSchedulingService>();
  final _localStorageService = locator<LocalStorageService>();
  final _databaseService = locator<DatabaseService>();
  final _settingsService = locator<SettingsService>();

  // Called immediately after the model is initialized
  Future<void> runStartupLogic() async {
    setBusy(true);

    try {
      // LS init
      await _localStorageService.init();
      // Request notification permissions early
      await _notificationService.requestPermission();

      // Load settings
      await _settingsService.loadSettings();

      debugPrint(
        'Clearing user data for user: ${_authService.currentUser?.uid ?? ''}',
      );
      // await _databaseService.clearUserData(_authService.currentUser?.uid ?? '');
      // Load all necessary data
      await _dataService.loadAllData();

      // Check authentication state
      final currentUser = _authService.currentUser;

      if (currentUser != null) {
        // User is logged in
        await _userService.loadUser(currentUser.uid);
        await _navigationService.replaceWith(Routes.homeView);
      } else {
        // No user logged in
        await _navigationService.replaceWith(Routes.welcomeView);
      }
    } catch (e, s) {
      // Handle any initialization errors
      // You might want to show an error dialog or navigate to an error screen
      print('Startup Error: $e');
      print('Stacktrace: $s');
      await _navigationService.replaceWith(Routes.welcomeView);
    } finally {
      setBusy(false);
    }
  }
}
