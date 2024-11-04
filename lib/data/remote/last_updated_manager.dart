import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/providers/network_state_provider.dart';
import 'package:provider/provider.dart';

class LastUpdatedManager {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<DateTime?> get lastUpdated async {
    CollectionReference users = _firestore.collection('users');
    String uid = _auth.currentUser!.uid.toString();
    DocumentReference userDoc = users.doc(uid);
    DocumentSnapshot userSnapshot = await userDoc.get();
    try {
      return userSnapshot['lastUpdated'].toDate();
    } catch (e) {
      return null;
    }
  }

  // Database functions
  Future<void> syncLastUpdated(BuildContext context, String uid) async {
    try {
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      for (QueryDocumentSnapshot user in usersSnapshot.docs) {
        try {
          user.get('uid');
        } catch (e) {
          continue; // skips users w/o uids
        }

        // Check if the user's uid matches
        if (user.get('uid') == uid) {
          await user.reference.set({
            'lastUpdated': DateTime.now(),
          }, SetOptions(merge: true));
        }
      }
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }
}
