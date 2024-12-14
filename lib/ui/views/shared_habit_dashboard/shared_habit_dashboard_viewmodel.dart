import 'package:habitur/app/app.locator.dart';
import 'package:habitur/app/app.router.dart';
import 'package:habitur/enums/dialog_type.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/shared_habit.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/shared_habits_service.dart';
import 'package:habitur/services/stats/habit_stats_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class SharedHabitDashboardViewModel extends BaseViewModel {
  final _sharedHabitsService = locator<SharedHabitsService>();
  final _userService = locator<UserService>();
  final _navigationService = locator<NavigationService>();
  final _habitStatsService = locator<HabitStatsService>();
  final _dialogService = locator<DialogService>();

  late SharedHabit _sharedHabit;
  SharedHabit get sharedHabit => _sharedHabit;

  List<ParticipantData> get participants => _sharedHabit.participantData;
  int get currentProgress => _getCurrentUserProgress();
  int get targetGoal => _sharedHabit.targetGoal;
  int get groupStreak => _calculateGroupStreak();
  int get totalGroupCompletions => _calculateTotalGroupCompletions();
  int get highestGroupStreak => _calculateHighestGroupStreak();
  int get totalActiveDays => _calculateTotalActiveDays();

  Future<void> init(String id) async {
    await loadSharedHabitData(id);
  }

  Future<void> loadSharedHabitData(String id) async {
    setBusy(true);
    try {
      // Refresh shared habit data
      final updatedHabit =
          await _sharedHabitsService.getSharedHabitById(int.parse(id));
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
    Habit currentUserHabit = getCurrentUserHabit();

    try {
      final difficulty = await showDifficultyPopup();
      final currentCompletions = _getCurrentUserProgress();
      if (currentCompletions < _sharedHabit.targetGoal) {
        _habitStatsService.processHabitIncrement(currentUserHabit,
            amount: 1, difficultyRating: difficulty);
        await _sharedHabitsService.updateParticipantProgress(
            _sharedHabit, currentUser.uid, currentUserHabit);
        await loadSharedHabitData(_sharedHabit.id.toString());
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

    final participant = _sharedHabit.participantData.firstWhere(
        (p) => p.userId == currentUser.uid,
        orElse: () => ParticipantData(
            username: currentUser.username,
            userId: currentUser.uid,
            habit: _sharedHabit));
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

  Future<String> getParticipantUsername(ParticipantData participant) async {
    UserModel? user = await _userService.getUserById(participant.userId);
    return user?.username ?? '';
  }

  Habit getCurrentUserHabit() {
    final currentUser = _userService.currentUser;
    if (currentUser == null) throw Exception('User not found');

    final participant = _sharedHabit.participantData.firstWhere(
        (p) => p.userId == currentUser.uid,
        orElse: () => ParticipantData(
            username: currentUser.username,
            userId: currentUser.uid,
            habit: _sharedHabit));
    return participant.habit;
  }

  Future<double> showDifficultyPopup() async {
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.difficultyPopup,
    );

    return response?.data ?? 5.0;
  }
}
