import 'package:habitur/app/app.locator.dart';
import 'package:habitur/app/app.router.dart';
import 'package:habitur/enums/bottom_sheet_type.dart';
import 'package:habitur/models/shared_habit.dart';
import 'package:habitur/services/shared_habits_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class SharedHabitsViewModel extends BaseViewModel {
  final _sharedHabitsService = locator<SharedHabitsService>();
  final _navigationService = locator<NavigationService>();
  final _bottomSheetService = locator<BottomSheetService>();

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

  Future<void> navigateToSharedHabitDashboard(SharedHabit sharedHabit) async {
    await _navigationService.navigateToSharedHabitDashboardView(
      sharedHabit: sharedHabit,
    );
  }

  Future<void> showCreateSharedHabitSheet() async {
    final response = await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.createSharedHabit,
    );

    if (response?.confirmed == true) {
      await loadSharedHabits();
    }
  }
}
