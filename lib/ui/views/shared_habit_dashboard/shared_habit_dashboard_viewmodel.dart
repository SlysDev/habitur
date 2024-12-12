import 'package:habitur/app/app.locator.dart';
import 'package:habitur/app/app.router.dart';
import 'package:habitur/models/shared_habit.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/services/shared_habits_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class SharedHabitDashboardViewModel extends BaseViewModel {
  final _sharedHabitsService = locator<SharedHabitsService>();
  final _userService = locator<UserService>();
  final _navigationService = locator<NavigationService>();

  late SharedHabit _sharedHabit;
  SharedHabit get sharedHabit => _sharedHabit;

  List<ParticipantData> get participants => _sharedHabit.participantData;
  int get currentProgress => _getCurrentUserProgress();
  int get targetGoal => _sharedHabit.targetGoal;
  int get groupStreak => _calculateGroupStreak();
  int get totalGroupCompletions => _calculateTotalGroupCompletions();
  int get highestGroupStreak => _calculateHighestGroupStreak();
  int get totalActiveDays => _calculateTotalActiveDays();

  Future<void> init(SharedHabit sharedHabit) async {
    _sharedHabit = sharedHabit;
    await loadSharedHabitData();
  }

  Future<void> loadSharedHabitData() async {
    setBusy(true);
    try {
      // Refresh shared habit data
      final updatedHabit =
          await _sharedHabitsService.getSharedHabitById(_sharedHabit.id);
      if (updatedHabit != null) {
        _sharedHabit = updatedHabit;
      }
      notifyListeners();
    } catch (e) {
      setError(e);
    } finally {
      setBusy(false);
    }
  }

  Future<void> incrementProgress() async {
    final currentUser = _userService.currentUser;
    if (currentUser == null) return;

    try {
      final currentCompletions = _getCurrentUserProgress();
      if (currentCompletions < _sharedHabit.targetGoal) {
        await _sharedHabitsService.updateParticipantProgress(
          _sharedHabit,
          currentUser.uid,
          currentCompletions + 1,
        );
        await loadSharedHabitData();
      }
    } catch (e) {
      setError(e);
    }
  }

  void inviteParticipants() {
    _navigationService.navigateToInviteParticipantsView(
        sharedHabit: _sharedHabit);
  }

  int _getCurrentUserProgress() {
    final currentUser = _userService.currentUser;
    if (currentUser == null) return 0;

    final participant = _sharedHabit.participantData
        .firstWhere((p) => p.user.uid == currentUser.uid);
    return participant.habit.currentProgress;
  }

  int _calculateGroupStreak() {
    if (_sharedHabit.participantData.isEmpty) return 0;

    return _sharedHabit.participantData
        .map((participant) => _getParticipantStreak(participant))
        .reduce((min, current) => current < min ? current : min);
  }

  int _getParticipantStreak(ParticipantData participant) {
    final now = DateTime.now();
    final daysSinceLastSeen = now.difference(participant.habit.lastSeen).inDays;

    if (daysSinceLastSeen > 1) return 0;
    return participant.habit.totalProgress;
  }

  int _calculateTotalGroupCompletions() {
    return _sharedHabit.participantData
        .map((p) => p.habit.totalProgress)
        .fold(0, (sum, count) => sum + count);
  }

  int _calculateHighestGroupStreak() {
    if (_sharedHabit.participantData.isEmpty) return 0;

    return _sharedHabit.participantData
        .map((p) => p.habit.totalProgress)
        .reduce((max, count) => count > max ? count : max);
  }

  int _calculateTotalActiveDays() {
    final now = DateTime.now();
    return _sharedHabit.participantData
        .where((p) => now.difference(p.habit.lastSeen).inDays <= 1)
        .length;
  }
}
