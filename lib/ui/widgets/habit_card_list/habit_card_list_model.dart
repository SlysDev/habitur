import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

class HabitCardListModel extends BaseViewModel {
  final _habitService = locator<HabitService>();

  List<Habit> get habits => _habitService.habits;

  Future<void> onRefresh() async {
    await _habitService.loadHabits();
    notifyListeners();
  }

  bool habitIsDueToday(int index) {
    return _habitService.habits[index].requiredDatesOfCompletion
        .contains(DateFormat('EEEE').format(DateTime.now()));
  }
}
