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

class UserDatabase {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  Future<void> userSetup(
      String username, String email, String bio, context) async {
    try {
      CollectionReference users = _firestore.collection('users');
      QuerySnapshot accountsWithSameEmail =
          await users.where('email', isEqualTo: email).get();
      if (accountsWithSameEmail.docs.isNotEmpty) {
        throw Exception('An account with this email already exists');
      }
      String uid = _auth.currentUser!.uid.toString();
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
        'lastUpdated': DateTime.now()
      });
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
      return;
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

  Future<UserModel?> getUserById(String uid) async {
    try {
      CollectionReference users = _firestore.collection('users');
      QuerySnapshot usersFound = await users.where('uid', isEqualTo: uid).get();

      if (usersFound.docs.isNotEmpty) {
        if (usersFound.docs.length > 1) {
          // Log error for monitoring purposes, but don’t break the app.
          print("Error: Multiple users found with the same UID ($uid).");
          // Optionally report this to a monitoring tool like Firebase Crashlytics
          // FirebaseCrashlytics.instance.recordError(Exception('Duplicate users found for UID'), StackTrace.current);
        }

        // Return the first user found to continue normal app flow.
        return DataConverter()
            .queryDocumentSnapshotToUserModel(usersFound.docs.first);
      }

      // Handle case where no user was found (user might have been deleted)
      print("Error: User not found for UID ($uid).");
      return null; // Return null to handle this gracefully in the UI
    } catch (e, s) {
      // Catch any other unexpected errors and log them
      print("Error: Failed to fetch user for UID ($uid): $e $s");
      // Optionally, log this to Firebase Crashlytics or another error logging service
      return null; // Return null to ensure the app continues to function
    }
  }

  DocumentReference get userDoc {
    CollectionReference users = _firestore.collection('users');
    String uid = _auth.currentUser!.uid.toString();
    DocumentReference userDoc = users.doc(uid);
    return userDoc;
  }

  Future<DocumentSnapshot> get userData async {
    CollectionReference users = _firestore.collection('users');
    String uid = _auth.currentUser!.uid.toString();
    DocumentReference userDoc = users.doc(uid);
    DocumentSnapshot userSnapshot = await userDoc.get();
    return userSnapshot;
  }

  get currentUser {
    return _auth.currentUser;
  }

  bool get isLoggedIn {
    return _auth.currentUser != null;
  }

  Future<void> loadUserData(context) async {
    // throw Error(); // just mocking an error
    try {
      if (!isLoggedIn) {
        throw Exception('User is not logged in');
      }
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      String uid = _auth.currentUser!.uid.toString();
      for (var user in usersSnapshot.docs) {
        try {
          user.get('uid');
        } catch (e) {
          continue;
        } // handles users w/o uids
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
                  isAdmin: user.get('isAdmin'));
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
    // throw Error();
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
        } // handles users w/o uids
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
            'lastUpdated': DateTime.now(),
          }, SetOptions(merge: true));
        }
      }
      await lastUpdatedManager.syncLastUpdated(context);
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
// Query for all documents matching the user ID
        final querySnapshot = await userCollection
            .where('uid', isEqualTo: userDoc.id) // or any unique identifier
            .get();

        // Loop through all the matching documents and delete them (handles duplicates)
        for (final doc in querySnapshot.docs) {
          querySnapshot.docs.remove(doc);
        }
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());
        showDebugErrorSnackbar(context, e, s);
      }
    }
  }
}
