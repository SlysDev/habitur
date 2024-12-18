import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';
import '../app/app.locator.dart';
import '../services/network_service.dart';

class SyncService with ListenableServiceMixin {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _networkService = locator<NetworkService>();

  DateTime? _cachedLastUpdated;

  // Reactive values for sync status
  final _isSyncing = ReactiveValue<bool>(false);

  bool get isSyncing => _isSyncing.value;

  SyncService() {
    listenToReactiveValues([_isSyncing]);
  }

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
      debugPrint('Error getting last updated: $e');
      return null;
    }
  }

  Future<void> syncLastUpdated(String uid) async {
    if (!_networkService.isConnected) {
      debugPrint('No network connection, skipping sync');
      return;
    }

    try {
      _isSyncing.value = true;
      final now = DateTime.now();

      await _firestore.collection('users').doc(uid).update({
        'lastUpdated': now,
      });

      _cachedLastUpdated = now;
    } catch (e) {
      debugPrint('Error syncing last updated: $e');
      rethrow;
    } finally {
      _isSyncing.value = false;
    }
  }

  void clearCache() {
    _cachedLastUpdated = null;
    notifyListeners();
  }
}
