import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';
import '../models/user.dart';
import '../models/habit.dart';
import '../models/stat_point.dart';
import '../models/setting.dart';
import '../app/app.locator.dart';

class DatabaseService with ListenableServiceMixin {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  DatabaseService() {
    _initializeFirestore();
  }

  void _initializeFirestore() {
    _firestore.settings = Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // User Operations
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      debugPrint('Error creating user: $e');
      rethrow;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      final user = UserModel.fromMap(data);

      // If user is blocked, throw an error
      if (user.isBlocked) {
        throw Exception(
            'Account is blocked. Please contact support for assistance.');
      }

      return user;
    } catch (e) {
      debugPrint('Error getting user: $e');
      rethrow;
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Error getting all users: $e');
      rethrow;
    }
  }

  // Stats Operations
  Future<List<StatPoint>> getStats(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      final stats = doc.data()?['stats']?['statPoints'] ?? [];
      return (stats as List).map((s) => StatPoint.fromMap(s)).toList();
    } catch (e) {
      debugPrint('Error getting stats: $e');
      rethrow;
    }
  }

  Future<void> updateStats(String userId, List<StatPoint> stats) async {
    try {
      final statMaps = stats.map((s) => s.toMap()).toList();
      await _firestore.collection('users').doc(userId).update({
        'stats.statPoints': statMaps,
        'lastUpdated': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Error updating stats: $e');
      rethrow;
    }
  }

  // Habits Operations
  Future<List<Habit>> getHabits(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .get();
      return snapshot.docs.map((doc) => Habit.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Error getting habits: $e');
      rethrow;
    }
  }

  Future<void> updateHabit(String userId, Habit habit) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .doc(habit.id.toString())
          .set(habit.toMap());
    } catch (e) {
      debugPrint('Error updating habit: $e');
      rethrow;
    }
  }

  Future<void> updateAllHabits(String userId, List<Habit> habits) async {
    try {
      for (Habit habit in habits) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('habits')
            .doc(habit.id.toString())
            .set(habit.toMap());
      }
    } catch (e) {
      debugPrint('Error updating all habits: $e');
      rethrow;
    }
  }

  // Settings Operations
  Future<List<SettingModel>> getSettings(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('userSettings')
          .get();
      return doc.exists
          ? (doc
              .data()!
              .entries
              .map<SettingModel>((e) => SettingModel.fromMap({e.key: e.value}))
              .toList())
          : <SettingModel>[];
    } catch (e) {
      debugPrint('Error getting settings: $e');
      rethrow;
    }
  }

  Future<void> updateSettings(String userId, SettingModel settings) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('userSettings')
          .set(settings.toMap());
    } catch (e) {
      debugPrint('Error updating settings: $e');
      rethrow;
    }
  }

  Future<void> toggleUserBlock(UserModel user) async {
    try {
      final newBlockedStatus = !user.isBlocked;
      final updatedUser = user.copyWith(
        isBlocked: newBlockedStatus,
        blockedAt: newBlockedStatus ? DateTime.now() : null,
        blockReason: newBlockedStatus ? 'Blocked by admin' : null,
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(updatedUser.toMap());
    } catch (e) {
      debugPrint('Error toggling user block: $e');
      rethrow;
    }
  }

  // Expose Firebase instances if needed by other services
  FirebaseFirestore get firestore => _firestore;
  FirebaseAuth get auth => _auth;
}
