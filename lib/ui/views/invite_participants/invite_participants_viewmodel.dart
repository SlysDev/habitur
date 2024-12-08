import 'package:flutter/material.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/shared_habit.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/services/shared_habits_service.dart';
import 'package:habitur/services/friends_service.dart';
import 'package:habitur/services/navigation_service.dart';
import 'package:stacked/stacked.dart';

class InviteParticipantsViewModel extends BaseViewModel {
  final _sharedHabitsService = locator<SharedHabitsService>();
  final _friendsService = locator<FriendsService>();
  final _navigationService = locator<NavigationService>();

  final searchController = TextEditingController();

  late SharedHabit _sharedHabit;
  List<User> _friends = [];
  final Set<User> _selectedFriends = {};
  String _searchQuery = '';

  List<User> get friends => _friends;
  Set<User> get selectedFriends => _selectedFriends;
  
  List<User> get filteredFriends => _friends
      .where((friend) => friend.username
          .toLowerCase()
          .contains(_searchQuery.toLowerCase()))
      .toList();

  Future<void> init(SharedHabit sharedHabit) async {
    _sharedHabit = sharedHabit;
    await loadFriends();
  }

  Future<void> loadFriends() async {
    setBusy(true);
    try {
      _friends = await _friendsService.getFriends();
      notifyListeners();
    } catch (e) {
      setError(e);
    } finally {
      setBusy(false);
    }
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  bool isSelected(User friend) => _selectedFriends.contains(friend);

  bool isExistingParticipant(User friend) {
    return _sharedHabit.participantData
        .any((participant) => participant.user.uid == friend.uid);
  }

  void toggleFriendSelection(User friend) {
    if (_selectedFriends.contains(friend)) {
      _selectedFriends.remove(friend);
    } else {
      _selectedFriends.add(friend);
    }
    notifyListeners();
  }

  Future<void> sendInvitations() async {
    if (_selectedFriends.isEmpty) return;

    setBusy(true);
    try {
      // Create new participant data for each selected friend
      final newParticipants = _selectedFriends.map((friend) => ParticipantData(
            user: friend,
            fullCompletionCount: 0,
            currentCompletions: 0,
            lastSeen: DateTime.now(),
          )).toList();

      // Add new participants to the shared habit
      _sharedHabit.participantData.addAll(newParticipants);
      
      // Update the shared habit with new participants
      await _sharedHabitsService.updateSharedHabit(_sharedHabit);

      // TODO: Implement notification sending to new participants
      // This should include:
      // 1. Push notifications
      // 2. In-app notifications
      // 3. Email notifications (if configured)
      
      _navigationService.back(result: newParticipants);
    } catch (e) {
      setError(e);
    } finally {
      setBusy(false);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
