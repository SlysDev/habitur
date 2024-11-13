import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/data/remote/data_converter.dart';
import 'package:habitur/data/remote/last_updated_manager.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/network_state_provider.dart';
import 'package:habitur/util_functions.dart';
import 'package:provider/provider.dart';
import '../../modules/auth_service.dart';

import '../../models/friend_request.dart';

class UserDatabase {
  final _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<void> userSetup(String username, String email, String bio, context,
      {withRethrow = false}) async {
    try {
      CollectionReference users = _firestore.collection('users');
      String uid = _authService.currentUser!.uid.toString();
      DocumentReference userDoc = users.doc(uid); // create a new doc w/ uid.
      userDoc.set({
        'username': username,
        'bio': bio,
        'email': email,
        'uid': uid,
        'stats': {'totalHabitsCompleted': 0, 'statPoints': []},
        'userLevel': 1,
        'userXP': 0,
        'isAdmin': false,
        'friends': [],
        'receivedFriendRequests': [],
        'sentFriendRequests': [],
        'lastUpdated': DateTime.now()
      });
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
      return;
    } catch (e, s) {
      if (withRethrow) {
        rethrow;
      }
      debugPrint(e.toString());
      if (!e.toString().contains('User is not logged in')) {
        debugPrint(s.toString());
        showDebugErrorSnackbar(context, e, s);
      }
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  Future<void> registerUser(String username, String email, String password,
      String bio, BuildContext context,
      {withRethrow = false}) async {
    UserCredential? newUser;
    try {
      // Create user with email and password
      newUser =
          await _authService.registerWithEmailAndPassword(email, password);
      // Setup user in Firestore; check for dupe emails/usernames
      CollectionReference users = _firestore.collection('users');

      // Check if the username is already taken
      QuerySnapshot accountsWithSameUsername =
          await users.where('username', isEqualTo: username).get();
      if (accountsWithSameUsername.docs.isNotEmpty) {
        throw Exception('Username is already taken');
      }

      QuerySnapshot accountsWithSameEmail =
          await users.where('email', isEqualTo: email).get();
      if (accountsWithSameEmail.docs.isNotEmpty) {
        throw Exception('An account with this email already exists');
      }

      if (newUser.user != null) {
        // Update display name
        await _authService.updateDisplayName(username);
        // Setup user in Firestore
        await userSetup(username, email, bio, context, withRethrow: true);
      }
    } catch (e) {
      if (newUser?.user != null) {
        await newUser?.user!.delete();
      }
      if (withRethrow) {
        rethrow;
      }
    }
  }

  Future<DocumentReference?> getUserDocById(String uid) async {
    try {
      CollectionReference users = _firestore.collection('users');
      QuerySnapshot usersFound = await users.where('uid', isEqualTo: uid).get();

      if (usersFound.docs.isNotEmpty) {
        if (usersFound.docs.length > 1) {
          debugPrint("Error: Multiple users found with the same UID ($uid).");
        }
        return usersFound.docs.first.reference;
      }

      debugPrint("Error: User not found for UID ($uid).");
      return null;
    } catch (e, s) {
      debugPrint("Error: Failed to fetch user document for UID ($uid): $e $s");
      return null;
    }
  }

  Future<UserModel?> getUserModelById(String uid) async {
    DocumentReference? userDoc = await getUserDocById(uid);

    if (userDoc != null) {
      DocumentSnapshot snapshot = await userDoc.get();
      return DataConverter().documentSnapshotToUserModel(snapshot);
    }

    return null;
  }

  DocumentReference get userDoc {
    CollectionReference users = _firestore.collection('users');
    String uid = _authService.currentUser!.uid.toString();
    DocumentReference userDoc = users.doc(uid);
    return userDoc;
  }

  Future<DocumentSnapshot> get userData async {
    CollectionReference users = _firestore.collection('users');
    String uid = _authService.currentUser!.uid.toString();
    DocumentReference userDoc = users.doc(uid);
    DocumentSnapshot userSnapshot = await userDoc.get();
    return userSnapshot;
  }

  get currentUser {
    return _authService.currentUser;
  }

  bool get isLoggedIn {
    return _authService.isLoggedIn;
  }

  Future<void> loadUserData(context) async {
    try {
      if (!isLoggedIn) {
        throw Exception('User is not logged in');
      }
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      String uid = _authService.currentUser!.uid.toString();
      for (var user in usersSnapshot.docs) {
        try {
          user.get('uid');
        } catch (e) {
          continue;
        }
        if (user.get('uid') == uid) {
          debugPrint('loading user...');
          Provider.of<UserLocalStorage>(context, listen: false).currentUser =
              UserModel(
            username: user.get('username'),
            bio: user.get('bio'),
            email: user.get('email'),
            uid: user.get('uid'),
            userLevel: user.get('userLevel'),
            userXP: user.get('userXP'),
            isAdmin: user.get('isAdmin'),
            friends: List<String>.from(user.get('friends') ?? []),
            receivedFriendRequests:
                (user.get('receivedFriendRequests') as List<dynamic>?)
                        ?.map((req) =>
                            FriendRequest.fromMap(req as Map<String, dynamic>))
                        .toList() ??
                    [],
            sentFriendRequests:
                (user.get('sentFriendRequests') as List<dynamic>?)
                        ?.map((req) =>
                            FriendRequest.fromMap(req as Map<String, dynamic>))
                        .toList() ??
                    [],
          );
          Provider.of<UserLocalStorage>(context, listen: false)
              .notifyListeners();
        }
      }
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
      debugPrint(e.toString());
      if (!e.toString().contains('User is not logged in')) {
        debugPrint(s.toString());
        showDebugErrorSnackbar(context, e, s);
      }
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  Future<void> uploadUserData(context) async {
    LastUpdatedManager lastUpdatedManager = LastUpdatedManager();
    try {
      if (!isLoggedIn) {
        throw Exception('User is not logged in');
      }
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      for (var user in usersSnapshot.docs) {
        try {
          user.get('uid');
        } catch (e) {
          continue;
        }
        if (user.get('uid') ==
            Provider.of<UserLocalStorage>(context, listen: false)
                .currentUser
                .uid) {
          await user.reference.set({
            'username': Provider.of<UserLocalStorage>(context, listen: false)
                .currentUser
                .username,
            'bio': Provider.of<UserLocalStorage>(context, listen: false)
                .currentUser
                .bio,
            'email': Provider.of<UserLocalStorage>(context, listen: false)
                .currentUser
                .email,
            'userLevel': Provider.of<UserLocalStorage>(context, listen: false)
                .currentUser
                .userLevel,
            'userXP': Provider.of<UserLocalStorage>(context, listen: false)
                .currentUser
                .userXP,
            'isAdmin': Provider.of<UserLocalStorage>(context, listen: false)
                .currentUser
                .isAdmin,
            'friends': Provider.of<UserLocalStorage>(context, listen: false)
                .currentUser
                .friends,
            'receivedFriendRequests':
                Provider.of<UserLocalStorage>(context, listen: false)
                    .currentUser
                    .receivedFriendRequests
                    .map((req) => req.toMap())
                    .toList(),
            'sentFriendRequests':
                Provider.of<UserLocalStorage>(context, listen: false)
                    .currentUser
                    .sentFriendRequests
                    .map((req) => req.toMap())
                    .toList(),
            'lastUpdated': DateTime.now(),
          }, SetOptions(merge: true));
        }
      }
      await lastUpdatedManager.syncLastUpdated(
          context, _authService.currentUser!.uid);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
      debugPrint(e.toString());
      if (!e.toString().contains('User is not logged in')) {
        debugPrint(s.toString());
        showDebugErrorSnackbar(context, e, s);
      }
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  Future<void> deleteUser(context) async {
    CollectionReference userCollection = _firestore.collection('users');
    if (isLoggedIn) {
      try {
        DocumentReference? userDoc =
            await getUserDocById(_authService.currentUser!.uid.toString());
        await userDoc!.delete();
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());
        showDebugErrorSnackbar(context, e, s);
      }
    }
  }
}
