import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:habitur/models/time_model.dart';
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

  Future<void> updateUserStats(String userId, List<StatPoint> stats) async {
    debugPrint('Updating user stats for $userId... in DB');
    try {
      final List<Map<String, dynamic>> statMaps =
          stats.map((s) => s.toMap()).toList();
      final userDoc = _firestore.collection('users').doc(userId);
      await userDoc.set({
        'stats': {
          'statPoints': statMaps,
        },
        'lastUpdated': Timestamp.now(),
      }, SetOptions(merge: true));
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
    } catch (e, s) {
      debugPrint('Error getting habits: $e');
      debugPrint('$s');
      rethrow;
    }
  }

  Future<void> addHabit(String userId, Habit habit) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .doc(habit.id.toString())
          .set(habit.toMap());
    } catch (e, s) {
      debugPrint('Error adding habit: $e');
      debugPrint('$s');
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
          .set(habit.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating habit: $e');
      rethrow;
    }
  }

  Future<void> deleteHabit(String userId, String habitId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .doc(habitId)
          .delete();
    } catch (e, s) {
      debugPrint('Error deleting habit: $e');
      debugPrint('$s');
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
            .set(habit.toMap(), SetOptions(merge: true));
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

  // Future<void> updateSettings(
  //     String userId, List<SettingModel> settings) async {
  //   try {
  //     await _firestore
  //         .collection('users')
  //         .doc(userId)
  //         .collection('settings')
  //         .doc('userSettings')
  //         .set({'settings': settings.map((s) => s.toMap()).toList()});
  //   } catch (e) {
  //     debugPrint('Error updating settings: $e');
  //     rethrow;
  //   }
  // }
  Future<void> updateSetting(String userId, SettingModel setting) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('userSettings')
          .update({setting.settingName: setting.settingValue.toString()});
    } catch (e) {
      debugPrint('Error updating setting: $e');
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

  // Reset Operations
  Future<void> clearUserData(String userId) async {
    try {
      // Clear habits subcollection
      final habitsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .get();
      final userSnapshot =
          await _firestore.collection('users').doc(userId).get();
      for (var doc in habitsSnapshot.docs) {
        // Delete stats subcollection for each habit
        final statsSnapshot = await doc.reference.collection('stats').get();
        for (var statDoc in statsSnapshot.docs) {
          await statDoc.reference.delete();
        }
        await doc.reference.delete();
      }

      // clears user stats from DB
      userSnapshot.reference.set({
        'stats': {'statPoints': []}
      }, SetOptions(merge: true));

      // Reset settings to defaults
      await resetUserSettings(userId);
    } catch (e) {
      debugPrint('Error clearing user data: $e');
      rethrow;
    }
  }

  Future<void> resetUserSettings(String userId) async {
    try {
      final defaultSettings = [
        SettingModel(
          settingValue: true,
          settingName: 'Daily Reminders',
          settingDescription: 'Enable daily reminders',
        ),
        SettingModel(
          settingValue: 3,
          settingName: 'Number of Reminders',
          settingDescription: 'Number of daily reminders',
        ),
        SettingModel(
          settingValue: TimeModel(hour: 10, minute: 0),
          settingName: '1st Reminder Time',
          settingDescription: 'First reminder of the day',
        ),
        SettingModel(
          settingValue: TimeModel(hour: 16, minute: 0),
          settingName: '2nd Reminder Time',
          settingDescription: 'Second reminder of the day',
        ),
        SettingModel(
          settingValue: TimeModel(hour: 22, minute: 0),
          settingName: '3rd Reminder Time',
          settingDescription: 'Third reminder of the day',
        ),
      ];

      // Update settings in Firestore
      for (var setting in defaultSettings) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('settings')
            .doc('userSettings')
            .update({setting.settingName: setting.settingValue.toString()});
      }
    } catch (e) {
      debugPrint('Error resetting user settings: $e');
      rethrow;
    }
  }

  // Expose Firebase instances if needed by other services
  FirebaseFirestore get firestore => _firestore;
  FirebaseAuth get auth => _auth;
}
