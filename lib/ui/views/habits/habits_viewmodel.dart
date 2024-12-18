import 'package:stacked/stacked.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/app/app.router.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:habitur/services/network_service.dart';
import 'package:habitur/services/status_service.dart';
import 'package:stacked_services/stacked_services.dart';

class HabitsViewModel extends ReactiveViewModel {
  final _habitService = locator<HabitService>();
  final _navigationService = locator<NavigationService>();
  final _networkService = locator<NetworkService>();
  final _statusService = locator<StatusService>();

  List<Habit> get habits => _habitService.habits;
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
}
