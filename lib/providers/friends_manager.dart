import 'package:flutter/material.dart';
import 'package:habitur/data/remote/friends_database.dart';
import 'package:provider/provider.dart';

import '../models/friend_request.dart';

class FriendsManager extends ChangeNotifier {
  final FriendsDatabase _friendsDatabase = FriendsDatabase();

  Future<void> sendFriendRequest(String recipientUid, BuildContext context) async {
    await _friendsDatabase.sendFriendRequest(recipientUid, context);
    notifyListeners();
  }

  Future<void> sendFriendRequestByEmail(String email, BuildContext context) async {
    await _friendsDatabase.sendFriendRequestByEmail(email, context);
    notifyListeners();
  }

  Future<void> acceptFriendRequest(FriendRequest friendRequest, BuildContext context) async {
    await _friendsDatabase.acceptFriendRequest(friendRequest, context);
    notifyListeners();
  }

  Future<void> declineFriendRequest(FriendRequest friendRequest, BuildContext context) async {
    await _friendsDatabase.declineFriendRequest(friendRequest, context);
    notifyListeners();
  }

  Future<void> loadFriendsData(BuildContext context) async {
    await _friendsDatabase.loadFriendsData(context);
    notifyListeners();
  }
}