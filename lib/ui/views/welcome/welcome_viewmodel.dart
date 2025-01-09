import 'package:habitur/services/local_storage_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/app/app.router.dart';

class WelcomeViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  Future<void> navigateToRegister() async {
    await _navigationService.navigateTo(Routes.registerView);
  }

  Future<void> navigateToLogin() async {
    await _navigationService.navigateTo(Routes.loginView);
  }

  Future<void> clearLocalStorageData() async {
    await locator<LocalStorageService>().clearAllHiveData();
  }
}
