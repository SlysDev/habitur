import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/friend_request.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/habit_interface.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/auth_service.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:stacked/stacked_annotations.dart';

@LazySingleton()
class FriendsService {
  final _firestore = FirebaseFirestore.instance;
  final _authService = locator<AuthService>();
  final _habitService = locator<HabitService>();
  final _userService = locator<UserService>();

  // Core friend operations
  Stream<List<String>> get friendsStream {
    final userDoc =
        _firestore.collection('users').doc(_authService.currentUser!.uid);
    return userDoc.snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return [];
      return List<String>.from(snapshot.data()!['friends'] ?? []);
    });
  }

  Stream<List<FriendRequest>> get receivedRequestsStream {
    final userDoc =
        _firestore.collection('users').doc(_authService.currentUser!.uid);
    return userDoc.snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return [];
      final requests =
          snapshot.data()!['receivedFriendRequests'] as List<dynamic>? ?? [];
      return requests
          .map((req) => FriendRequest.fromMap(req as Map<String, dynamic>))
          .toList();
    });
  }

  Stream<List<FriendRequest>> get sentRequestsStream {
    final userDoc =
        _firestore.collection('users').doc(_authService.currentUser!.uid);
    return userDoc.snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return [];
      final requests =
          snapshot.data()!['sentFriendRequests'] as List<dynamic>? ?? [];
      return requests
          .map((req) => FriendRequest.fromMap(req as Map<String, dynamic>))
          .toList();
    });
  }

  Future<bool> isFriend(String? userId, {String? otherUserId}) async {
    if (userId == null) {
      debugPrint(
          'the user sent into isFriend() of friends_service.dart is null');
      return false;
    }
    // If otherUser is provided, check if those two users are friends
    if (otherUserId != null) {
      final otherUserDoc =
          await _firestore.collection('users').doc(otherUserId).get();
      if (!otherUserDoc.exists) return false;

      final friendsList =
          List<String>.from(otherUserDoc.data()?['friends'] ?? []);
      return friendsList.contains(userId);
    }

    // Otherwise check if the provided user is friends with the current user
    if (!_authService.isLoggedIn) return false;

    final userDoc = await _firestore
        .collection('users')
        .doc(_authService.currentUser!.uid)
        .get();
    if (!userDoc.exists) {
      debugPrint(
          'couldn\'t find user doc in DB in friends_service.dart isFriend()');
      return false;
    }

    final friendsList = List<String>.from(userDoc.data()?['friends'] ?? []);
    return friendsList.contains(userId);
  }

  // Friend request operations
  Future<void> sendFriendRequest(String recipientUid) async {
    final recipientDoc = await _getUserDocById(recipientUid);
    if (recipientDoc == null) {
      throw Exception('Recipient not found');
    }

    final friendRequest = FriendRequest(
      senderUid: _authService.currentUser!.uid,
      recipientUid: recipientUid,
      dateSent: DateTime.now(),
    );

    await recipientDoc.set({
      'receivedFriendRequests': FieldValue.arrayUnion([friendRequest.toMap()])
    }, SetOptions(merge: true));

    final currentUserDoc =
        _firestore.collection('users').doc(_authService.currentUser!.uid);
    await currentUserDoc.set({
      'sentFriendRequests': FieldValue.arrayUnion([friendRequest.toMap()])
    }, SetOptions(merge: true));
  }

  Future<void> sendFriendRequestByUsername(String username) async {
    if (username.trim().isEmpty) {
      throw Exception('Please enter a username.');
    }

    final currentUsername = _authService.currentUser!.displayName;
    if (username.trim().toLowerCase() == currentUsername?.toLowerCase()) {
      throw Exception('You cannot send a friend request to yourself.');
    }

    final users = _firestore.collection('users');
    final usersFound = await users
        .where('username', isEqualTo: username.trim())
        .limit(2)
        .get();

    if (usersFound.docs.isEmpty) {
      throw Exception('No user found with this username.');
    }

    if (usersFound.docs.length > 1) {
      throw Exception('Multiple users found with this username.');
    }

    final recipientDoc = usersFound.docs.first;
    final recipientUid = recipientDoc.get('uid');

    // Check if already friends
    final currentUserDoc = await _firestore
        .collection('users')
        .doc(_authService.currentUser!.uid)
        .get();
    final currentUserFriends =
        List<String>.from(currentUserDoc.data()?['friends'] ?? []);

    if (currentUserFriends.contains(recipientUid)) {
      throw Exception('You are already friends with this user.');
    }

    // Check for existing friend requests
    final sentRequests =
        List<dynamic>.from(currentUserDoc.data()?['sentFriendRequests'] ?? []);
    final hasExistingRequest = sentRequests.any((request) =>
        request is Map<String, dynamic> &&
        request['recipientUid'] == recipientUid &&
        request['isAccepted'] != true);

    if (hasExistingRequest) {
      throw Exception('You have already sent a friend request to this user.');
    }

    await sendFriendRequest(recipientUid);
  }

  Future<void> acceptFriendRequest(FriendRequest request) async {
    final currentUserDoc =
        _firestore.collection('users').doc(_authService.currentUser!.uid);
    final senderDoc = await _getUserDocById(request.senderUid);

    if (senderDoc == null) {
      throw Exception('Sender not found');
    }

    // Remove existing friend request
    await currentUserDoc.update({
      'receivedFriendRequests':
          FieldValue.arrayRemove([request.toFirebaseMap()])
    });

    await senderDoc.update({
      'sentFriendRequests': FieldValue.arrayRemove([request.toFirebaseMap()])
    });

    // Update request with acceptance details
    request.isAccepted = true;
    request.dateAccepted = DateTime.now();

    // Add updated request and friend connection
    await currentUserDoc.update({
      'friends': FieldValue.arrayUnion([request.senderUid]),
      'receivedFriendRequests': FieldValue.arrayUnion([request.toMap()])
    });

    await senderDoc.update({
      'friends': FieldValue.arrayUnion([_authService.currentUser!.uid]),
      'sentFriendRequests': FieldValue.arrayUnion([request.toMap()])
    });
  }

  Future<void> declineFriendRequest(FriendRequest request) async {
    final currentUserDoc =
        _firestore.collection('users').doc(_authService.currentUser!.uid);
    final senderDoc = await _getUserDocById(request.senderUid);

    if (senderDoc == null) {
      throw Exception('Sender not found');
    }

    await currentUserDoc.update({
      'receivedFriendRequests':
          FieldValue.arrayRemove([request.toFirebaseMap()])
    });

    await senderDoc.update({
      'sentFriendRequests': FieldValue.arrayRemove([request.toFirebaseMap()])
    });
  }

  Future<void> cancelFriendRequest(FriendRequest request) async {
    final currentUserDoc =
        _firestore.collection('users').doc(_authService.currentUser!.uid);
    final recipientDoc = await _getUserDocById(request.recipientUid);

    if (recipientDoc == null) {
      throw Exception('Recipient not found');
    }

    await currentUserDoc.update({
      'sentFriendRequests': FieldValue.arrayRemove([request.toFirebaseMap()])
    });

    await recipientDoc.update({
      'receivedFriendRequests':
          FieldValue.arrayRemove([request.toFirebaseMap()])
    });
  }

  // Friend data operations
  Future<List<HabitInterface>> getFriendVisibleHabits(String friendUid) async {
    List<HabitInterface> habits =
        await _habitService.getUserHabits(userId: friendUid);
    final friendDoc = await _getUserDocById(friendUid);
    if (friendDoc == null) {
      throw Exception('Friend not found');
    }

    final snapshot = await friendDoc.get();
    if (!snapshot.exists || snapshot.data() == null) {
      return [];
    }

    try {
      final Map<String, dynamic>? data =
          snapshot.data() as Map<String, dynamic>?;
      final habits = data?['habits'] as List<dynamic>? ?? [];
      return habits
          .where((habit) => habit['isPublic'] == true)
          .map((habit) => Habit.fromMap(habit as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error parsing friend habits: $e');
      return [];
    }
  }

  Future<List<UserModel>> getFriends() async {
    final currentUser = _userService.currentUser;
    if (currentUser == null) return [];

    try {
      final friendsSnapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('friends')
          .get();

      final friendIds = friendsSnapshot.docs.map((doc) => doc.id).toList();
      if (friendIds.isEmpty) return [];

      final friendsData = await Future.wait(friendIds.map(
          (friendId) => _firestore.collection('users').doc(friendId).get()));

      return friendsData
          .where((doc) => doc.exists)
          .map((doc) => UserModel.fromMap({...doc.data()!, 'uid': doc.id}))
          .toList();
    } catch (e) {
      print('Error getting friends: $e');
      return [];
    }
  }

  // Helper methods
  Future<DocumentReference?> _getUserDocById(String uid) async {
    final userDoc = _firestore.collection('users').doc(uid);
    final snapshot = await userDoc.get();
    if (!snapshot.exists) return null;
    return userDoc;
  }

  void enableFriendsService() {
    // Logic to enable the friends system
    // For example, start processing friend requests
  }

  void disableFriendsService() {
    // Logic to disable the friends system
    // For example, stop processing friend requests
  }
}
