import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../models/habit.dart';
import '../../../models/user.dart';
import '../../../services/auth_service.dart';
import '../../../services/community_service.dart';
import '../../../services/database_service.dart';

class AdminViewModel extends BaseViewModel {
  final _databaseService = locator<DatabaseService>();
  final _authService = locator<AuthService>();
  final _communityService = locator<CommunityService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final requiredCompletionsController = TextEditingController();

  List<UserModel> _users = [];
  List<UserModel> get users => _users;

  int get totalUsers => _users.length;
  int get activeChallenges => _communityService.getActiveChallengeCount();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    requiredCompletionsController.dispose();
    super.dispose();
  }

  Future<void> initialize() async {
    setBusy(true);
    try {
      await _loadUsers();
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Failed to load users: ${e.toString()}',
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> _loadUsers() async {
    _users = await _databaseService.getAllUsers();
    notifyListeners();
  }

  Future<void> createChallenge() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        requiredCompletionsController.text.isEmpty) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Please fill in all fields',
      );
      return;
    }

    final completions = int.tryParse(requiredCompletionsController.text);
    if (completions == null || completions <= 0) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Please enter a valid number of completions',
      );
      return;
    }
    setBusy(true);
    try {
      await _communityService.createChallenge(
        description: descriptionController.text,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        requiredFullCompletions: completions,
        habit: Habit(
          title: titleController.text,
          currentProgress: 0,
          targetGoal: 0,
          resetPeriod: 'Daily',
          isCommunityHabit: true,
          lastSeen: DateTime.now(),
          id: 0,
          dateCreated: DateTime.now(),
        ),
      );

      titleController.clear();
      descriptionController.clear();
      requiredCompletionsController.clear();

      await _dialogService.showDialog(
        title: 'Success',
        description: 'Challenge created successfully',
      );
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Failed to create challenge: ${e.toString()}',
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> toggleUserBlock(UserModel user) async {
    final response = await _dialogService.showConfirmationDialog(
      title: user.isBlocked ? 'Unblock User' : 'Block User',
      description: user.isBlocked
          ? 'Are you sure you want to unblock ${user.username}? They will regain access to all app features.'
          : 'Are you sure you want to block ${user.username}? This will prevent them from:\n\n'
              '• Logging into the app\n'
              '• Creating or modifying habits\n'
              '• Participating in challenges\n'
              '• Interacting with other users',
      confirmationTitle: user.isBlocked ? 'Unblock' : 'Block',
      cancelTitle: 'Cancel',
    );

    if (response?.confirmed ?? false) {
      setBusy(true);
      try {
        await _databaseService.toggleUserBlock(user);
        await _loadUsers(); // Reload users to update UI

        await _dialogService.showDialog(
          title: 'Success',
          description:
              '${user.username} has been ${user.isBlocked ? 'blocked' : 'unblocked'} successfully.',
        );
      } catch (e) {
        await _dialogService.showDialog(
          title: 'Error',
          description:
              'Failed to ${user.isBlocked ? 'unblock' : 'block'} user: ${e.toString()}',
        );
      } finally {
        setBusy(false);
      }
    }
  }

  void handleNavigation(int index) {
    switch (index) {
      case 0:
        _navigationService.navigateTo(Routes.habitsView);
        break;
      case 1:
        _navigationService.navigateTo(Routes.statisticsView);
        break;
      case 2:
        _navigationService.navigateTo(Routes.communityLeaderboardView);
        break;
      case 3:
        _navigationService.back();
        break;
    }
  }
}
