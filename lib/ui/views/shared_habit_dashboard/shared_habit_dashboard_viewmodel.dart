import 'package:flutter/material.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/app/app.router.dart';
import 'package:habitur/enums/dialog_type.dart';
import 'package:habitur/enums/snackbar_type.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/shared_habit.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/shared_habits_service.dart';
import 'package:habitur/services/stats/habit_stats_service.dart';
import 'package:habitur/services/stats/stats_calculation_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class SharedHabitDashboardViewModel extends BaseViewModel {
  final _sharedHabitsService = locator<SharedHabitsService>();
  final _userService = locator<UserService>();
  final _navigationService = locator<NavigationService>();
  final _habitStatsService = locator<HabitStatsService>();
  final _dialogService = locator<DialogService>();
  final _snackbarService = locator<SnackbarService>();
  final _statsCalculationService = locator<StatsCalculationService>();

  String? _sharedHabitId;
  SharedHabit? _sharedHabit;
  SharedHabit? get sharedHabit => _sharedHabit;

  List<ParticipantData> get participants => _sharedHabit?.participantData ?? [];
  int get currentProgress => _getCurrentUserProgress();
  int get targetGoal => _sharedHabit?.targetGoal ?? 0;
  int get groupStreak => _calculateGroupStreak();
  int get totalGroupCompletions => _calculateTotalGroupCompletions();
  int get highestGroupStreak => _calculateHighestGroupStreak();
  int get totalActiveDays => _calculateTotalActiveDays();
  bool get isCurrentUserAuthor =>
      _sharedHabit?.author?.uid == _userService.currentUser?.uid;

  Future<void> init(SharedHabit sharedHabit) async {
    _sharedHabit = sharedHabit;
    await loadSharedHabitData(sharedHabit.id.toString());
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
    if (currentUser == null || _sharedHabit == null) return;
    Habit currentUserHabit = getUserHabit();

    try {
      final difficulty = await showDifficultyPopup();
      final currentCompletions = _getCurrentUserProgress();
      if (currentCompletions < _sharedHabit!.targetGoal) {
        _habitStatsService.processHabitIncrement(currentUserHabit,
            amount: 1, difficultyRating: difficulty);
        await _sharedHabitsService.updateParticipantProgress(
            _sharedHabit!, currentUser.uid, currentUserHabit);
        await loadSharedHabitData(_sharedHabit!.id.toString());
      }
    } catch (e) {
      setError(e);
    }
  }

  void inviteParticipants() async {
    final participantsAsUserModels = participants.map((e) async => await _userService.getUserById(e.userId));
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.selectFriends,
      title: 'Share Habit',
      description: 'Select friends to share "${_sharedHabit!.title}" with',
      data: {'preSelectedUsers': participantsAsUserModels}
    );

    if (response?.data.isEmpty) return;

    if (response?.confirmed == true && response?.data is List<UserModel>) {
      List<UserModel> selectedFriends = response!.data as List<UserModel>;
      setBusy(true);
      try {
        // Check if any selected friend is already a participant
        for (var friend in selectedFriends) {
          if (_sharedHabit!.participantData
              .any((p) => p.userId == friend.uid)) {
            throw Exception('${friend.username} has already been added');
          }
        }

        // Create new participant data for each selected friend
        final newParticipants = selectedFriends
            .map((friend) => ParticipantData(
                  username: friend.username,
                  userId: friend.uid,
                  habit: Habit.fromSharedHabit(_sharedHabit!),
                ))
            .toList();

        // Add new participants to the shared habit
        _sharedHabit!.participantData.addAll(newParticipants);

        // Update the shared habit with new participants
        await _sharedHabitsService.updateSharedHabit(_sharedHabit!);

        // TODO: Implement notification sending to new participants
        // This should include:
        // 1. Push notifications
        // 2. In-app notifications
        // 3. Email notifications (if configured)
      } catch (e, s) {
        setError(e);
        _snackbarService.showCustomSnackBar(
          message: e.toString().contains('has already been added')
              ? e.toString()
              : 'Failed to invite participants',
          variant: SnackbarType.error,
        );
        print(s);
      } finally {
        setBusy(false);
      }
    }
  }

  Future<void> removeParticipant(ParticipantData participant) async {
    setBusy(true);
    try {
      _sharedHabit!.participantData.remove(participant);
      await _sharedHabitsService.updateSharedHabit(_sharedHabit!);
    } catch (e) {
      setError(e);
    } finally {
      setBusy(false);
    }
  }

  int _getCurrentUserProgress() {
    final currentUser = _userService.currentUser;
    if (currentUser == null || _sharedHabit == null) return 0;

    final participant = _sharedHabit!.participantData.firstWhere(
        (p) => p.userId == currentUser.uid,
        orElse: () => ParticipantData(
            username: currentUser.username,
            userId: currentUser.uid,
            habit: _sharedHabit!));
    return participant.habit.currentProgress;
  }

  int _calculateGroupStreak() {
    if (_sharedHabit == null || _sharedHabit!.participantData.isEmpty) return 0;

    return _sharedHabit!.participantData
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
    if (_sharedHabit == null) return 0;

    return _sharedHabit!.participantData
        .map((p) => p.habit.totalProgress)
        .fold(0, (sum, count) => sum + count);
  }

  int _calculateHighestGroupStreak() {
    if (_sharedHabit == null || _sharedHabit!.participantData.isEmpty) return 0;

    return _sharedHabit!.participantData
        .map((p) => p.habit.totalProgress)
        .reduce((max, count) => count > max ? count : max);
  }

  int _calculateTotalActiveDays() {
    if (_sharedHabit == null) return 0;

    final now = DateTime.now();
    return _sharedHabit!.participantData
        .where((p) => now.difference(p.habit.lastSeen).inDays <= 1)
        .length;
  }

  Future<String> getParticipantUsername(ParticipantData participant) async {
    UserModel? user = await _userService.getUserById(participant.userId);
    return user?.username ?? '';
  }

  Habit getUserHabit({String? userId}) {
    final currentUser = _userService.currentUser;
    if (currentUser == null) throw Exception('User not found');

    if (_sharedHabit == null) throw Exception('Shared habit not found');

    final participant = _sharedHabit!.participantData.firstWhere(
        (p) => p.userId == (userId ?? currentUser.uid),
        orElse: () => ParticipantData(
            username: currentUser.username,
            userId: currentUser.uid,
            habit: _sharedHabit!));
    return participant.habit;
  }

  Future<double> showDifficultyPopup() async {
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.difficultyPopup,
    );

    return response?.data ?? 5.0;
  }

  bool isParticipantCurrentUser(ParticipantData participant) {
    bool result = participant.userId == _userService.currentUser?.uid;
    debugPrint(result.toString());
    return result;
  }

  double getAverageWeeklyCompletions({String? userId}) {
    Habit habit = getUserHabit(userId: userId);
    return _statsCalculationService.calculateAverageValueForStat(
        habit.stats, 'completions');
  }

  double getAverageConsistency({String? userId, int period = 7}) {
    Habit habit = getUserHabit(userId: userId);
    return _statsCalculationService.calculateConsistencyFactor(
        habit.stats, habit.targetGoal,
        period: period);
  }
}
