import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/models/friend_request.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/modules/auth_service.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/network_state_provider.dart';
import 'package:habitur/util_functions.dart';
import 'package:provider/provider.dart';

class FriendsDatabase {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> sendFriendRequest(
      String recipientUid, BuildContext context) async {
    await showStatusOverlay(
      context,
      'Sending friend request...',
      () async {
        debugPrint(
            '🤝 Starting sendFriendRequest for recipientUid: $recipientUid');

        DocumentReference? recipientDoc = await getUserDocById(recipientUid);
        debugPrint('📄 Recipient doc found: ${recipientDoc != null}');

        if (recipientDoc == null) {
          throw Exception('Recipient not found');
        }

        FriendRequest friendRequest = FriendRequest(
          senderUid: _auth.currentUser!.uid,
          recipientUid: recipientUid,
          dateSent: DateTime.now(),
        );
        debugPrint('📝 Created friend request: ${friendRequest.toMap()}');

        debugPrint('📤 Updating recipient doc with friend request...');
        await recipientDoc.set({
          'receivedFriendRequests':
              FieldValue.arrayUnion([friendRequest.toMap()])
        }, SetOptions(merge: true));
        debugPrint('✅ Successfully updated recipient doc');

        DocumentReference currentUserDoc = userDoc;
        debugPrint('📤 Updating current user doc with sent request...');
        await currentUserDoc.set({
          'sentFriendRequests': FieldValue.arrayUnion([friendRequest.toMap()])
        }, SetOptions(merge: true));
        debugPrint('✅ Successfully updated current user doc');
      },
      successMessage: 'Friend request sent successfully',
    );
  }

  Future<void> sendFriendRequestByUsername(
      String username, BuildContext context) async {
    await showStatusOverlay(
      context,
      'Looking up user...',
      () async {
        debugPrint(
            '🔍 Starting sendFriendRequestByUsername for username: $username');

        if (username.trim().isEmpty) {
          throw Exception('Please enter a username.');
        }

        // Get current user's username
        debugPrint('👤 Fetching current user username...');
        DocumentSnapshot currentUserDoc = await userData;
        String currentUsername = AuthService().currentUser!.displayName ??
            Provider.of<UserLocalStorage>(context, listen: false)
                .currentUser
                .username;
        debugPrint('👤 Current username: $currentUsername');

        if (username.trim().toLowerCase() == currentUsername.toLowerCase()) {
          throw Exception('You cannot send a friend request to yourself.');
        }

        debugPrint('🔍 Searching for user with username: ${username.trim()}');
        CollectionReference users = _firestore.collection('users');
        QuerySnapshot usersFound = await users
            .where('username', isEqualTo: username.trim())
            .limit(2)
            .get();
        debugPrint('👥 Found ${usersFound.docs.length} matching users');

        if (usersFound.docs.isEmpty) {
          throw Exception('No user found with this username.');
        }

        if (usersFound.docs.length > 1) {
          throw Exception('Multiple users found with this username.');
        }

        DocumentSnapshot recipientDoc = usersFound.docs.first;
        String recipientUid = recipientDoc.get('uid');
        debugPrint('👤 Found recipient UID: $recipientUid');

        // Check if already friends - safely get friends list with null check
        List<dynamic> currentUserFriends = [];
        try {
          if (currentUserDoc.exists && currentUserDoc.data() != null) {
            var data = currentUserDoc.data() as Map<String, dynamic>;
            currentUserFriends = data['friends'] as List<dynamic>? ?? [];
          }
        } catch (e) {
          debugPrint('⚠️ Error getting friends list: $e');
        }
        debugPrint('👥 Current friends list: $currentUserFriends');

        if (currentUserFriends.contains(recipientUid)) {
          throw Exception('You are already friends with this user.');
        }

        // Check for existing friend requests - safely get sent requests with null check
        List<dynamic> sentRequests = [];
        try {
          if (currentUserDoc.exists && currentUserDoc.data() != null) {
            var data = currentUserDoc.data() as Map<String, dynamic>;
            sentRequests = data['sentFriendRequests'] as List<dynamic>? ?? [];
          }
        } catch (e) {
          debugPrint('⚠️ Error getting sent requests: $e');
        }
        debugPrint('📤 Current sent requests: $sentRequests');

        bool hasExistingRequest = sentRequests.any((request) =>
            request is Map<String, dynamic> &&
            request['recipientUid'] == recipientUid &&
            request['isAccepted'] != true);

        if (hasExistingRequest) {
          throw Exception('You have already sent a friend request to this user.');
        }

        debugPrint('✨ All checks passed, sending friend request...');
        await sendFriendRequest(recipientUid, context);
        debugPrint('✅ Friend request sent successfully');
      },
      successMessage: 'Friend request sent successfully',
    );
  }

  Future<void> acceptFriendRequest(
      FriendRequest friendRequest, BuildContext context) async {
    await showStatusOverlay(
      context,
      'Accepting friend request...',
      () async {
        debugPrint(
            '🤝 Starting acceptFriendRequest for friend request: ${friendRequest.toMap()}');

        DocumentReference currentUserDoc = userDoc;
        DocumentReference? senderDoc =
            await getUserDocById(friendRequest.senderUid);

        if (senderDoc == null) {
          throw Exception('Sender not found');
        }

        // Remove the existing friend request from both users
        debugPrint('📤 Updating current user doc to remove friend request...');
        await currentUserDoc.update({
          'receivedFriendRequests':
              FieldValue.arrayRemove([friendRequest.toFirebaseMap()])
        });
        debugPrint('✅ Successfully updated current user doc');

        debugPrint('📤 Updating sender doc to remove friend request...');
        await senderDoc.update({
          'sentFriendRequests':
              FieldValue.arrayRemove([friendRequest.toFirebaseMap()])
        });
        debugPrint('✅ Successfully updated sender doc');

        // Update the friend request with the acceptance details
        friendRequest.isAccepted = true;
        friendRequest.dateAccepted = DateTime.now();

        // Add the updated friend request to both users
        debugPrint(
            '📤 Updating current user doc with accepted friend request...');
        await currentUserDoc.update({
          'friends': FieldValue.arrayUnion([friendRequest.senderUid]),
          'receivedFriendRequests':
              FieldValue.arrayUnion([friendRequest.toMap()])
        });
        debugPrint('✅ Successfully updated current user doc');

        debugPrint('📤 Updating sender doc with accepted friend request...');
        await senderDoc.update({
          'friends': FieldValue.arrayUnion([_auth.currentUser!.uid]),
          'sentFriendRequests': FieldValue.arrayUnion([friendRequest.toMap()])
        });
        debugPrint('✅ Successfully updated sender doc');
      },
      successMessage: 'Friend request accepted',
    );
  }

  Future<void> declineFriendRequest(
      FriendRequest friendRequest, BuildContext context) async {
    await showStatusOverlay(
      context,
      'Declining friend request...',
      () async {
        debugPrint(
            '🚫 Starting declineFriendRequest for friend request: ${friendRequest.toMap()}');

        DocumentReference currentUserDoc = userDoc;
        List<dynamic> receivedRequests = (await currentUserDoc.get()).get('receivedFriendRequests');
        bool foundRequest = false;
        
        for (var request in receivedRequests) {
          if (friendRequest.equals(request)) {
            debugPrint('📤 Updating current user doc to remove friend request...');
            await currentUserDoc.update({
              'receivedFriendRequests': FieldValue.arrayRemove([request])
            });
            debugPrint('✅ Successfully updated current user doc');
            foundRequest = true;
            break;
          }
        }

        if (!foundRequest) {
          throw Exception('Friend request not found');
        }

        DocumentReference? senderDoc = await getUserDocById(friendRequest.senderUid);
        if (senderDoc != null) {
          List<dynamic> sentRequests = (await senderDoc.get()).get('sentFriendRequests');
          for (var request in sentRequests) {
            if (friendRequest.equals(request)) {
              debugPrint('📤 Updating sender doc to remove friend request...');
              await senderDoc.update({
                'sentFriendRequests': FieldValue.arrayRemove([request])
              });
              debugPrint('✅ Successfully updated sender doc');
              break;
            }
          }
        }
      },
      successMessage: 'Friend request declined',
    );
  }

  Future<void> cancelFriendRequest(
      FriendRequest friendRequest, BuildContext context) async {
    await showStatusOverlay(
      context,
      'Cancelling friend request...',
      () async {
        debugPrint('🔄 Starting cancelFriendRequest for request: ${friendRequest.toFirebaseMap()}');

        // Get recipient's document
        DocumentReference? recipientDoc = await getUserDocById(friendRequest.recipientUid);
        if (recipientDoc == null) {
          throw Exception('Recipient not found');
        }

        final requestMap = friendRequest.toFirebaseMap();
        
        // Remove from recipient's received requests
        await recipientDoc.set({
          'receivedFriendRequests': FieldValue.arrayRemove([requestMap])
        }, SetOptions(merge: true));

        // Remove from sender's sent requests
        await userDoc.set({
          'sentFriendRequests': FieldValue.arrayRemove([requestMap])
        }, SetOptions(merge: true));

        debugPrint('✅ Successfully cancelled friend request');
      },
      successMessage: 'Friend request cancelled',
    );
  }

  Future<void> loadFriendsData(BuildContext context) async {
    await showStatusOverlay(
      context,
      'Loading friends data...',
      () async {
        debugPrint('📊 Starting loadFriendsData...');

        DocumentSnapshot userSnapshot = await userData;
        List<String> friends = List<String>.from(userSnapshot.get('friends'));
        debugPrint('👥 Loaded friends list: $friends');

        List<FriendRequest> receivedFriendRequests = (userSnapshot
                    .get('receivedFriendRequests') as List<dynamic>?)
                ?.map((req) => FriendRequest.fromMap(req as Map<String, dynamic>))
                .toList() ??
            [];
        debugPrint('📤 Loaded received friend requests: $receivedFriendRequests');

        List<FriendRequest> sentFriendRequests = (userSnapshot
                    .get('sentFriendRequests') as List<dynamic>?)
                ?.map((req) => FriendRequest.fromMap(req as Map<String, dynamic>))
                .toList() ??
            [];
        debugPrint('📤 Loaded sent friend requests: $sentFriendRequests');

        Provider.of<UserLocalStorage>(context, listen: false)
            .updateUserProperty('friends', friends);
        Provider.of<UserLocalStorage>(context, listen: false)
            .updateUserProperty('receivedFriendRequests', receivedFriendRequests);
        Provider.of<UserLocalStorage>(context, listen: false)
            .updateUserProperty('sentFriendRequests', sentFriendRequests);
        debugPrint('✅ Successfully loaded friends data');
      },
      successMessage: 'Friends data loaded successfully',
    );
  }

  Stream<List<String>> getFriendsStream() {
    return userDoc.snapshots().map((snapshot) {
      debugPrint(
          '📊 Emitting friends list: ${List<String>.from(snapshot.get('friends'))}');
      return List<String>.from(snapshot.get('friends'));
    });
  }

  Stream<List<FriendRequest>> getReceivedFriendRequestsStream() {
    return userDoc.snapshots().map((snapshot) {
      debugPrint(
          '📊 Emitting received friend requests: ${(snapshot.get('receivedFriendRequests') as List<dynamic>?)?.map((req) => FriendRequest.fromMap(req as Map<String, dynamic>)).toList() ?? []}');
      return (snapshot.get('receivedFriendRequests') as List<dynamic>?)
              ?.map((req) => FriendRequest.fromMap(req as Map<String, dynamic>))
              .toList() ??
          [];
    });
  }

  Stream<List<FriendRequest>> getSentFriendRequestsStream() {
    return userDoc.snapshots().map((snapshot) {
      debugPrint(
          '📊 Emitting sent friend requests: ${(snapshot.get('sentFriendRequests') as List<dynamic>?)?.map((req) => FriendRequest.fromMap(req as Map<String, dynamic>)).toList() ?? []}');
      return (snapshot.get('sentFriendRequests') as List<dynamic>?)
              ?.map((req) => FriendRequest.fromMap(req as Map<String, dynamic>))
              .toList() ??
          [];
    });
  }

  Future<DocumentReference?> getUserDocById(String uid) async {
    try {
      debugPrint('🔍 Starting getUserDocById for UID: $uid');

      // Get direct document reference instead of querying
      DocumentReference userDocRef = _firestore.collection('users').doc(uid);
      DocumentSnapshot docSnapshot = await userDocRef.get();

      debugPrint('📄 Checking if document exists for UID: $uid');
      if (docSnapshot.exists) {
        debugPrint('✅ Found user document for UID: $uid');
        return userDocRef;
      } else {
        debugPrint('⚠️ No user document found for UID: $uid');
        return null;
      }
    } catch (e, s) {
      debugPrint('❌ Error in getUserDocById: $e');
      debugPrint('📍 Stack trace: $s');
      return null;
    }
  }

  DocumentReference get userDoc {
    String uid = _auth.currentUser!.uid;
    debugPrint('📄 Getting user document reference for UID: $uid');
    return _firestore.collection('users').doc(uid);
  }

  Future<DocumentSnapshot> get userData async {
    String uid = _auth.currentUser!.uid;
    debugPrint('📄 Fetching user data for UID: $uid');
    DocumentReference userDocRef = _firestore.collection('users').doc(uid);
    DocumentSnapshot snapshot = await userDocRef.get();
    debugPrint('✅ Successfully fetched user data for UID: $uid');
    return snapshot;
  }

  Future<List<Habit>> getFriendVisibleHabits(String friendUid, BuildContext context) async {
    try {
      debugPrint('📊 Starting getFriendVisibleHabits for friendUid: $friendUid');
      return await Database().habitDatabase.loadHabits(context, userID: friendUid);
    } catch (e, s) {
      debugPrint('❌ Error in getFriendVisibleHabits: $e');
      debugPrint('📍 Stack trace: $s');
      return [];
    }
  }
}
