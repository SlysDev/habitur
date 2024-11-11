import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/models/friend_request.dart';
import 'package:habitur/util_functions.dart';
import 'package:provider/provider.dart';
import 'package:habitur/providers/network_state_provider.dart';

class FriendsDatabase {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> sendFriendRequest(
      String recipientUid, BuildContext context) async {
    try {
      DocumentReference? recipientDoc = await getUserDocById(recipientUid);
      if (recipientDoc != null) {
        FriendRequest friendRequest = FriendRequest(
          senderUid: _auth.currentUser!.uid,
          recipientUid: recipientUid,
          dateSent: DateTime.now(),
        );

        await recipientDoc.update({
          'receivedFriendRequests':
              FieldValue.arrayUnion([friendRequest.toMap()])
        });

        DocumentReference currentUserDoc = userDoc;
        await currentUserDoc.update({
          'sentFriendRequests': FieldValue.arrayUnion([friendRequest.toMap()])
        });
      }
    } catch (e, s) {
      debugPrint(e.toString());
      showDebugErrorSnackbar(context, e, s);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  Future<void> sendFriendRequestByEmail(
      String email, BuildContext context) async {
    try {
      CollectionReference users = _firestore.collection('users');
      QuerySnapshot usersFound =
          await users.where('email', isEqualTo: email).get();

      if (usersFound.docs.isEmpty) {
        showErrorDialog(context, 'No user found with this email.');
        return;
      }

      if (usersFound.docs.length > 1) {
        showErrorDialog(context, 'Multiple users found with this email.');
        return;
      }

      String recipientUid = usersFound.docs.first.get('uid');
      await sendFriendRequest(recipientUid, context);
    } catch (e, s) {
      debugPrint(e.toString());
      showDebugErrorSnackbar(context, e, s);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  Future<void> acceptFriendRequest(
      FriendRequest friendRequest, BuildContext context) async {
    try {
      DocumentReference currentUserDoc = userDoc;
      DocumentReference? senderDoc =
          await getUserDocById(friendRequest.senderUid);

      if (senderDoc != null) {
        await currentUserDoc.update({
          'friends': FieldValue.arrayUnion([friendRequest.senderUid]),
          'receivedFriendRequests':
              FieldValue.arrayRemove([friendRequest.toMap()])
        });

        friendRequest.isAccepted = true;
        friendRequest.dateAccepted = DateTime.now();

        await senderDoc.update({
          'friends': FieldValue.arrayUnion([_auth.currentUser!.uid]),
          'sentFriendRequests': FieldValue.arrayRemove([friendRequest.toMap()]),
          'sentFriendRequests': FieldValue.arrayUnion([friendRequest.toMap()])
        });
      }
    } catch (e, s) {
      debugPrint(e.toString());
      showDebugErrorSnackbar(context, e, s);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  Future<void> declineFriendRequest(
      FriendRequest friendRequest, BuildContext context) async {
    try {
      DocumentReference currentUserDoc = userDoc;
      await currentUserDoc.update({
        'receivedFriendRequests':
            FieldValue.arrayRemove([friendRequest.toMap()])
      });

      DocumentReference? senderDoc =
          await getUserDocById(friendRequest.senderUid);
      if (senderDoc != null) {
        await senderDoc.update({
          'sentFriendRequests': FieldValue.arrayRemove([friendRequest.toMap()])
        });
      }
    } catch (e, s) {
      debugPrint(e.toString());
      showDebugErrorSnackbar(context, e, s);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  Future<void> loadFriendsData(BuildContext context) async {
    try {
      DocumentSnapshot userSnapshot = await userData;
      List<String> friends = List<String>.from(userSnapshot.get('friends'));
      List<FriendRequest> receivedFriendRequests = (userSnapshot
                  .get('receivedFriendRequests') as List<dynamic>?)
              ?.map((req) => FriendRequest.fromMap(req as Map<String, dynamic>))
              .toList() ??
          [];
      List<FriendRequest> sentFriendRequests = (userSnapshot
                  .get('sentFriendRequests') as List<dynamic>?)
              ?.map((req) => FriendRequest.fromMap(req as Map<String, dynamic>))
              .toList() ??
          [];

      Provider.of<UserLocalStorage>(context, listen: false)
          .updateUserProperty('friends', friends);
      Provider.of<UserLocalStorage>(context, listen: false)
          .updateUserProperty('receivedFriendRequests', receivedFriendRequests);
      Provider.of<UserLocalStorage>(context, listen: false)
          .updateUserProperty('sentFriendRequests', sentFriendRequests);
    } catch (e, s) {
      debugPrint(e.toString());
      showDebugErrorSnackbar(context, e, s);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  Future<DocumentReference?> getUserDocById(String uid) async {
    try {
      CollectionReference users = _firestore.collection('users');
      QuerySnapshot usersFound = await users.where('uid', isEqualTo: uid).get();

      if (usersFound.docs.isNotEmpty) {
        return usersFound.docs.first.reference;
      }

      debugPrint("Error: User not found for UID ($uid).");
      return null;
    } catch (e, s) {
      debugPrint("Error: Failed to fetch user document for UID ($uid): $e $s");
      return null;
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
}
