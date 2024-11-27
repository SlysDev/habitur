import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/privacy_settings.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:stacked/stacked.dart';

class VisibleHabitListModel extends BaseViewModel {
  final _habitService = locator<HabitService>();

  late String userId;
  late bool isFriendProfile;
  SharingScope? _habitsScope;
  List<Habit>? habits;

  void initialize(String userId, bool isFriendProfile,
      SharingScope? habitsScope, List<Habit>? habits) {
    this.userId = userId;
    this.isFriendProfile = isFriendProfile;
    _habitsScope = habitsScope;
    this.habits = habits;
  }

  bool get userHasChosenToShareHabits =>
      _habitsScope == SharingScope.everyone ||
      (_habitsScope == SharingScope.friends && isFriendProfile);

  Future<List<Habit>> loadHabits() async {
    setBusy(true);
    final loadedHabits = await _habitService.getUserHabits(userId: userId);
    setBusy(false);
    return loadedHabits;
  }

  List<Habit> getVisibleHabits(List<Habit>? allHabits) {
    return allHabits!.where((h) => h.isVisible).toList();
  }
}
