import 'package:habitur/enums/dialog_type.dart';
import 'package:habitur/enums/snackbar_type.dart';
import 'package:habitur/models/habit_interface.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:habitur/services/shared_habits_service.dart';
import 'package:habitur/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';

class HabitOverviewViewModel extends BaseViewModel {
  final _habitService = locator<HabitService>();
  final _sharedHabitsService = locator<SharedHabitsService>();
  final _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();

  HabitInterface? habit;

  void initialize(String habitId) async {
    setBusy(true);
    HabitInterface? retrievedHabit = await _habitService.getHabit(habitId);
    if (retrievedHabit != null) {
      habit = retrievedHabit;
    } else {
      // Handle the case where the habit is not found
      throw Exception('Habit not found');
    }
    setBusy(false);
    notifyListeners();
  }

  Future<void> shareHabit() async {
    if (habit == null) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'No habit selected to share.',
      );
      return;
    }

    // Prevent sharing already shared habits
    if (habit!.isShared) {
      await _dialogService.showCustomDialog(
        title: 'Cannot Share',
        description: 'This habit is already a shared habit.',
        variant: DialogType.modern,
      );
      return;
    }

    try {
      // Show dialog to select participants
      final response = await _dialogService.showCustomDialog(
        variant: DialogType.selectFriends,
        title: 'Share Habit',
        description: 'Select friends to share "${habit!.title}" with',
      );

      if (response?.confirmed == true && response?.data is List<UserModel>) {
        final participants = response!.data as List<UserModel>;
        setBusy(true);
        final sharedHabit =
            await _sharedHabitsService.convertHabitToSharedHabit(
          habit! as Habit,
          participants,
        );

        if (sharedHabit != null) {
          // Trying this out to see if it is necessary
          habit = sharedHabit;
          // Update the habit in LS and DB services to persist the changes
          await _habitService.updateHabit(sharedHabit);

          // Navigate to the shared habit dashboard
          await _navigationService.navigateToSharedHabitDashboardView(
            sharedHabit: sharedHabit,
          );

          await _snackbarService.showCustomSnackBar(
              message: 'Converted habit successfully!',
              variant: SnackbarType.success);
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

  void navigateToEditHabit() {
    if (habit != null) {
      _navigationService.navigateToEditHabitView(
        habitId: habit!.id.toString(),
      );
    }
  }
}
