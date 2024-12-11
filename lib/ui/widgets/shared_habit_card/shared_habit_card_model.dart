import 'package:habitur/app/app.locator.dart';
import 'package:habitur/app/app.router.dart';
import 'package:habitur/models/shared_habit.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class SharedHabitCardModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  void navigateToSharedHabitDashboard(SharedHabit sharedHabit) {
    // TODO: Register shared habit dashboard as view
    _navigationService.navigateToSharedHabitDashboardView(
        sharedHabit: sharedHabit);
  }
}
