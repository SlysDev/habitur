import 'package:flutter/material.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/friends_service.dart';
import 'package:stacked/stacked.dart';

class SelectFriendsDialogViewModel extends StreamViewModel {
  final _friendsService = locator<FriendsService>();
  @override
  Stream<List<String>> get stream => _friendsService.friendsStream;

  List<String> get friendsIds => data ?? [];

  List<UserModel> _friends = [];
  List<UserModel> get friends => _friends;

  List<UserModel> _selectedFriends = [];
  List<UserModel> get selectedFriends => _selectedFriends;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<UserModel> get filteredFriends {
    if (_searchQuery.isEmpty) return _friends;
    return _friends.where((friend) {
      final query = _searchQuery.toLowerCase();
      return friend.username.toLowerCase().contains(query) ||
          friend.email.toLowerCase().contains(query);
    }).toList();
  }

  SelectFriendsDialogViewModel() {
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setBusy(true);
    try {
      _friends = await _friendsService.getFriends();
      debugPrint('Loaded ${_friends.length} friends');
      notifyListeners();
    } catch (e) {
      // Handle error appropriately
      setError(e);
    } finally {
      setBusy(false);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  bool isSelected(UserModel friend) {
    return _selectedFriends.any((f) => f.uid == friend.uid);
  }

  void toggleFriendSelection(UserModel friend) {
    if (isSelected(friend)) {
      _selectedFriends.removeWhere((f) => f.uid == friend.uid);
      debugPrint('Removed ${friend.username} from selected friends');
    } else {
      _selectedFriends.add(friend);
      debugPrint('Added ${friend.username} to selected friends');
    }
    notifyListeners();
  }

  UserModel getFriendById(String id) {
    return _friends.firstWhere((friend) => friend.uid == id);
  }
}
