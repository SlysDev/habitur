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
  DateTime? _cachedLastUpdated;

  Future<DateTime?> get lastUpdated async {
    if (_cachedLastUpdated != null) {
      return _cachedLastUpdated;
    }

    try {
      String uid = _auth.currentUser!.uid;
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(uid).get();
      _cachedLastUpdated = userSnapshot['lastUpdated']?.toDate();
      return _cachedLastUpdated;
    } catch (e) {
      return null;
    }
  }

  Future<void> syncLastUpdated(BuildContext context, String uid) async {
    try {
      final now = DateTime.now();
      await _firestore.collection('users').doc(uid).update({
        'lastUpdated': now,
      });
      _cachedLastUpdated = now;
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  void clearCache() {
    _cachedLastUpdated = null;
  }
}
