import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/shared_habit.dart';
import 'package:habitur/services/navigation_service.dart';
import 'package:stacked/stacked.dart';

class SharedHabitCardModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  
  void navigateToSharedHabitDashboard(SharedHabit sharedHabit) {
    _navigationService.navigateToSharedHabitDashboardView(sharedHabit: sharedHabit);
  }
}
