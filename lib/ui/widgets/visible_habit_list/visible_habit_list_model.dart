import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/habit_interface.dart';
import 'package:habitur/models/privacy_settings.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:stacked/stacked.dart';

class VisibleHabitListModel extends BaseViewModel {
  final _habitService = locator<HabitService>();

  late String userId;
  late bool isFriendProfile;
  SharingScope? _habitsScope;
  List<HabitInterface>? habits;

  Future<void> initialize(String userId, bool isFriendProfile,
      SharingScope? habitsScope, List<HabitInterface>? habits) async {
    this.userId = userId;
    this.isFriendProfile = isFriendProfile;
    _habitsScope = habitsScope;
    this.habits = habits;
    await loadHabits();
  }

  bool get userHasChosenToShareHabits =>
      _habitsScope == SharingScope.everyone ||
      (_habitsScope == SharingScope.friends && isFriendProfile);

  Future<List<HabitInterface>> loadHabits() async {
    final loadedHabits = await _habitService.getUserHabits(userId: userId);
    return loadedHabits;
  }

  List<HabitInterface> getVisibleHabits(List<HabitInterface>? allHabits) {
    return allHabits!.where((h) => h.isVisible).toList();
  }
}
