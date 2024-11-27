import 'package:stacked/stacked.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:habitur/app/app.router.dart';

class HabitOverviewViewModel extends BaseViewModel {
  final _habitService = locator<HabitService>();
  late Habit habit;

  void initialize(String habitId) async {
    setBusy(true);
    Habit? retrievedHabit = await _habitService.getHabit(habitId);
    if (retrievedHabit != null) {
      habit = retrievedHabit;
    } else {
      // Handle the case where the habit is not found
      throw Exception('Habit not found');
    }
    setBusy(false);
    notifyListeners();
  }
}
