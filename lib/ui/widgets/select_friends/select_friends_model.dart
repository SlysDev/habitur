import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/friends_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:habitur/app/app.locator.dart';

class SelectFriendsModel extends StreamViewModel<List<String>> {
  final _friendsService = locator<FriendsService>();
  final _userService = locator<UserService>();

  // Constructor with initial selected friends
  SelectFriendsModel({List<UserModel>? initialSelectedFriends}) {
    if (initialSelectedFriends != null) {
      _selectedFriends.addAll(initialSelectedFriends);
    }
  }

  // Stream of friend UIDs
  @override
  Stream<List<String>> get stream => _friendsService.friendsStream;

  // Selected friends set for tracking
  final Set<UserModel> _selectedFriends = {};
  Set<UserModel> get selectedFriends => _selectedFriends;

  // Search query for filtering friends
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Method to get full friend details by UID
  Future<UserModel> getFriendById(String id) async {
    final friend = await _userService.getUserById(id);
    if (friend == null) {
      throw Exception('Friend not found');
    }
    return friend;
  }

  // Toggle friend selection
  void toggleFriendSelection(UserModel friend) {
    if (_selectedFriends.any((f) => f.uid == friend.uid)) {
      _selectedFriends.removeWhere((f) => f.uid == friend.uid);
      debugPrint('Removed ${friend.username} from selected friends');
    } else {
      _selectedFriends.add(friend);
      debugPrint('Added ${friend.username} to selected friends');
    }
    notifyListeners();
  }

  // Check if a friend is selected
  bool isSelected(UserModel friend) {
    return _selectedFriends.any((f) => f.uid == friend.uid);
  }

  // Filtered friends based on search query
  List<String> get filteredFriendIds {
    if (data == null) return [];

    return data!.where((friendId) {
      // If no search query, return all friends
      if (_searchQuery.isEmpty) return true;

      // TODO: Implement more robust search logic
      return true;
    }).toList();
  }
}
