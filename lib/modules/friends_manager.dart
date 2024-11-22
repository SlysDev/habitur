import 'package:flutter/material.dart';
import 'package:habitur/data/remote/friends_database.dart';

import '../models/friend_request.dart';

class FriendsManager {
  final FriendsDatabase _friendsDatabase = FriendsDatabase();

  Future<void> sendFriendRequest(
      String recipientUid, BuildContext context) async {
    await _friendsDatabase.sendFriendRequest(recipientUid, context);
  }

  Future<void> sendFriendRequestByUsername(
      String username, BuildContext context) async {
    await _friendsDatabase.sendFriendRequestByUsername(username, context);
  }

  Stream<List<String>> get friendsStream => _friendsDatabase.getFriendsStream();

  Stream<List<FriendRequest>> get receivedFriendRequestsStream =>
      _friendsDatabase.getReceivedFriendRequestsStream();

  Stream<List<FriendRequest>> get sentFriendRequestsStream =>
      _friendsDatabase.getSentFriendRequestsStream();

  Future<void> acceptFriendRequest(
      FriendRequest friendRequest, BuildContext context) async {
    await _friendsDatabase.acceptFriendRequest(friendRequest, context);
  }

  Future<void> declineFriendRequest(
      FriendRequest friendRequest, BuildContext context) async {
    await _friendsDatabase.declineFriendRequest(friendRequest, context);
  }

  Future<void> cancelFriendRequest(
      FriendRequest friendRequest, BuildContext context) async {
    await _friendsDatabase.cancelFriendRequest(friendRequest, context);
  }

  Future<void> loadFriendsData(BuildContext context) async {
    await _friendsDatabase.loadFriendsData(context);
  }
}
