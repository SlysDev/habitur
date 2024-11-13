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
        // Remove the existing friend request from both users
        await currentUserDoc.update({
          'receivedFriendRequests':
              FieldValue.arrayRemove([friendRequest.toFirebaseMap()])
        });

        await senderDoc.update({
          'sentFriendRequests': FieldValue.arrayRemove([friendRequest.toFirebaseMap()])
        });

        // Update the friend request with the acceptance details
        friendRequest.isAccepted = true;
        friendRequest.dateAccepted = DateTime.now();

        // Add the updated friend request to both users
        await currentUserDoc.update({
          'friends': FieldValue.arrayUnion([friendRequest.senderUid]),
          'receivedFriendRequests':
              FieldValue.arrayUnion([friendRequest.toMap()])
        });

        await senderDoc.update({
          'friends': FieldValue.arrayUnion([_auth.currentUser!.uid]),
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
      List<dynamic> receivedRequests =
          (await currentUserDoc.get()).get('receivedFriendRequests');
      for (var request in receivedRequests) {
        if (friendRequest.equals(request)) {
          await currentUserDoc.update({
            'receivedFriendRequests':
                FieldValue.arrayRemove([request])
          });
          break;
        }
      }

      DocumentReference? senderDoc =
          await getUserDocById(friendRequest.senderUid);
      if (senderDoc != null) {
        List<dynamic> sentRequests =
            (await senderDoc.get()).get('sentFriendRequests');
        for (var request in sentRequests) {
          if (friendRequest.equals(request)) {
            await senderDoc.update({
              'sentFriendRequests':
                  FieldValue.arrayRemove([request])
            });
            break;
          }
        }
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

  Stream<List<String>> getFriendsStream() {
    return userDoc.snapshots().map((snapshot) {
      return List<String>.from(snapshot.get('friends'));
    });
  }

  Stream<List<FriendRequest>> getReceivedFriendRequestsStream() {
    return userDoc.snapshots().map((snapshot) {
      return (snapshot.get('receivedFriendRequests') as List<dynamic>?)
              ?.map((req) => FriendRequest.fromMap(req as Map<String, dynamic>))
              .toList() ??
          [];
    });
  }

  Stream<List<FriendRequest>> getSentFriendRequestsStream() {
    return userDoc.snapshots().map((snapshot) {
      return (snapshot.get('sentFriendRequests') as List<dynamic>?)
              ?.map((req) => FriendRequest.fromMap(req as Map<String, dynamic>))
              .toList() ??
          [];
    });
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
