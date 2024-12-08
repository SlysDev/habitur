import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/shared_habit.dart';
import 'package:habitur/services/navigation_service.dart';
import 'package:habitur/services/shared_habits_service.dart';
import 'package:stacked/stacked.dart';

class SharedHabitsViewModel extends BaseViewModel {
  final _sharedHabitsService = locator<SharedHabitsService>();
  final _navigationService = locator<NavigationService>();

  List<SharedHabit> _sharedHabits = [];
  List<SharedHabit> get sharedHabits => _sharedHabits;

  Future<void> init() async {
    await loadSharedHabits();
  }

  Future<void> loadSharedHabits() async {
    setBusy(true);
    try {
      _sharedHabits = await _sharedHabitsService.getSharedHabits();
      notifyListeners();
    } catch (e) {
      setError(e);
    } finally {
      setBusy(false);
    }
  }

  void navigateToSharedHabitDashboard(SharedHabit sharedHabit) {
    _navigationService.navigateToSharedHabitDashboardView(sharedHabit: sharedHabit);
  }

  void navigateToCreateSharedHabit() {
    _navigationService.navigateToCreateSharedHabitView();
  }
}
