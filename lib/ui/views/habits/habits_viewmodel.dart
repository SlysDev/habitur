import 'package:habitur/app/app.dialogs.dart';
import 'package:habitur/models/habit_interface.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/app/app.router.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:habitur/services/network_service.dart';
import 'package:habitur/services/status_service.dart';
import 'package:habitur/services/shared_habits_service.dart';
import 'package:stacked_services/stacked_services.dart';

class HabitsViewModel extends ReactiveViewModel {
  final _habitService = locator<HabitService>();
  final _navigationService = locator<NavigationService>();
  final _networkService = locator<NetworkService>();
  final _statusService = locator<StatusService>();
  final _dialogService = locator<DialogService>();
  final _sharedHabitsService = locator<SharedHabitsService>();

  List<HabitInterface> get habits => _habitService.habits;
  bool get isConnected => _networkService.isConnected;

  @override
  List<ListenableServiceMixin> get listenableServices => [_habitService];

  Future<void> initialize() async {
    await refreshHabits();
    rebuildUi();
  }

  Future<void> refreshHabits() async {
    await runBusyFuture(
      _habitService.loadHabits(),
    );
    rebuildUi();
  }

  void handleNavigation(int index) {
    switch (index) {
      case 0:
        // Already on habits
        break;
      case 1:
        _navigationService.navigateTo(Routes.statisticsView);
        break;
      case 2:
        _navigationService.navigateTo(Routes.communityLeaderboardView);
        break;
      case 3:
        _navigationService.navigateTo(Routes.settingsView);
        break;
    }
  }

  Future<void> convertHabitToShared(Habit habit) async {
    try {
      // Show dialog to select participants
      final response = await _dialogService.showCustomDialog(
        variant: DialogType.selectFriends,
        title: 'Select Participants',
        description: 'Choose friends to share this habit with',
      );

      if (response?.confirmed == true && response?.data is List<UserModel>) {
        final participants = response!.data as List<UserModel>;

        setBusy(true);
        final sharedHabit =
            await _sharedHabitsService.convertHabitToSharedHabit(
          habit,
          participants,
        );

        if (sharedHabit != null) {
          // Update the habit in the local service
          await _habitService.updateHabit(habit);

          // Refresh habits list
          await refreshHabits();

          // Show success dialog
          await _dialogService.showDialog(
            title: 'Success',
            description: 'Habit converted to shared habit successfully!',
          );
        } else {
          await _dialogService.showDialog(
            title: 'Error',
            description: 'Failed to convert habit to shared habit.',
          );
        }
      }
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'An error occurred: $e',
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> navigateToEditHabit(Habit habit) async {
    await _navigationService.navigateToEditHabitView(
        habitId: habit.id.toString());
  }
}
