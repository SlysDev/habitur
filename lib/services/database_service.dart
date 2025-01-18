import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:habitur/models/habit_interface.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/models/time_model.dart';
import 'package:habitur/services/user_service.dart';
import 'package:stacked/stacked.dart';
import '../models/user.dart';
import '../models/habit.dart';
import '../models/stat_point.dart';
import '../models/setting.dart';
import '../app/app.locator.dart';
import '../models/shared_habit.dart';

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

  // normal habits
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

  Future<void> clearUserHabits(String userId) async {
    try {
      final habitsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .get();
      for (var doc in habitsSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e, s) {
      debugPrint('Error clearing user habits: $e');
      debugPrint('$s');
      rethrow;
    }
  }

  // habit interface methods

  Future<List<HabitInterface>> getInterfaceHabits(String userId) async {
    final userService = locator<UserService>();
    List<HabitInterface> habits = [];
    Set<String> habitIds = {};
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .get();
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        final habit = Habit.fromMap(doc.data());
        debugPrint('Habit: ${habit.toMap()}');
        habits.add(habit);
        habitIds.add(habit.id.toString());
      }
      debugPrint(
          'hasSharedHabits: ${userService.currentUser?.hasSharedHabits}');
      if (userService.currentUser?.hasSharedHabits == true) {
        final sharedHabits = await getSharedHabits(userId);
        for (var sharedHabit in sharedHabits) {
          if (!habitIds.contains(sharedHabit.id.toString())) {
            habits.add(sharedHabit);
          }
        }
      }
      return habits;
    } catch (e, s) {
      debugPrint('Error getting habits: $e');
      debugPrint('$s');
      rethrow;
    }
  }

  Future<void> addInterfaceHabit(String userId, HabitInterface habit) async {
    try {
      if (habit is Habit) {
        await addHabit(userId, habit);
      } else if (habit is SharedHabit) {
        await createSharedHabit(habit);
      } else {
        throw Exception('Invalid habit type');
      }
    } catch (e, s) {
      debugPrint('Error adding habit: $e');
      debugPrint('$s');
      rethrow;
    }
  }

  Future<void> updateInterfaceHabit(String userId, HabitInterface habit) async {
    try {
      if (habit is Habit) {
        await updateHabit(userId, habit);
      } else if (habit is SharedHabit) {
        await updateSharedHabit(habit);
      } else {
        throw Exception('Invalid habit type');
      }
    } catch (e) {
      debugPrint('Error updating habit: $e');
      rethrow;
    }
  }

  Future<void> deleteInterfaceHabit(
      String userId, String habitId, bool isShared) async {
    try {
      if (isShared) {
        await deleteSharedHabit(habitId);
      } else {
        await deleteHabit(userId, habitId);
      }
    } catch (e, s) {
      debugPrint('Error deleting habit: $e');
      debugPrint('$s');
      rethrow;
    }
  }

  Future<void> updateAllInterfaceHabits(
      String userId, List<HabitInterface> habits) async {
    try {
      for (HabitInterface habit in habits) {
        await updateInterfaceHabit(userId, habit);
      }
    } catch (e, s) {
      debugPrint('Error updating all habits: $e');
      debugPrint('$s');
      rethrow;
    }
  }

  // Shared Habits
  Future<List<SharedHabit>> getSharedHabits(String userId) async {
    try {
      final sharedHabitsRef = _firestore
          .collection('shared_habits')
          .where('participantUids', arrayContains: userId);

      final snapshot = await sharedHabitsRef.get();
      debugPrint('The number of shared habits gotten: ${snapshot.docs.length}');
      return snapshot.docs
          .map((doc) => SharedHabit.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e, s) {
      debugPrint('Error getting shared habits: $e');
      debugPrint('$s');
      rethrow;
    }
  }

  Stream<SharedHabit> getSharedHabitStreamById(String habitId) {
    // return the stream for the shared habit with the given id
    return _firestore.collection('shared_habits').doc(habitId).snapshots().map(
        (doc) =>
            SharedHabit.fromMap({...doc.data()!, 'id': int.tryParse(doc.id)}));
  }

  Future<SharedHabit?> getSharedHabitById(String habitId) async {
    try {
      final doc =
          await _firestore.collection('shared_habits').doc(habitId).get();
      if (!doc.exists) return null;
      return SharedHabit.fromMap({...doc.data()!, 'id': int.tryParse(doc.id)});
    } catch (e, s) {
      debugPrint('Error getting shared habit: $e');
      debugPrint('$s');
      rethrow;
    }
  }

  Future<void> createSharedHabit(SharedHabit sharedHabit) async {
    try {
      // add it to DB
      await _firestore
          .collection('shared_habits')
          .doc(sharedHabit.id.toString())
          .set(sharedHabit.toMap());

      // update all users hasSharedHabit statuses
      for (ParticipantData participant in sharedHabit.participantData) {
        await setUserSharedHabitStatus(participant.userId, true);
      }
    } catch (e, s) {
      debugPrint('Error creating shared habit: $e');
      debugPrint('$s');
      rethrow;
    }
  }

  Future<void> updateSharedHabit(SharedHabit sharedHabit) async {
    try {
      debugPrint('Updating shared habit in Firestore: ${sharedHabit.toMap()}');
      await _firestore
          .collection('shared_habits')
          .doc(sharedHabit.id.toString())
          .update(sharedHabit.toMap());
      debugPrint('Shared habit updated in Firestore');
    } catch (e, s) {
      debugPrint('Error updating shared habit: $e');
      debugPrint('$s');
      rethrow;
    }
  }

  Future<void> deleteSharedHabit(String habitId) async {
    try {
      await _firestore.collection('shared_habits').doc(habitId).delete();
    } catch (e, s) {
      debugPrint('Error deleting shared habit: $e');
      debugPrint('$s');
      rethrow;
    }
  }

  Future<void> clearUserSharedHabitData(String userId) async {
    try {
      // First remove user from all shared habits in DB
      final sharedHabitsSnapshot = await _firestore
          .collection('shared_habits')
          .where('participantUids', arrayContains: userId)
          .get();
      for (var doc in sharedHabitsSnapshot.docs) {
        await doc.reference.update({
          'participantUids': FieldValue.arrayRemove([userId])
        });
      }
      // Then remove any user-authored Shared habits from their own habits collection
      final userSharedHabitsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .where('isShared', isEqualTo: true)
          .get();
      for (var doc in userSharedHabitsSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e, s) {
      debugPrint('Error clearing user shared habits: $e');
      debugPrint('$s');
      rethrow;
    }
  }

  Future<void> setUserSharedHabitStatus(
      String userId, bool hasSharedHabits) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'hasSharedHabits': hasSharedHabits,
      });
    } catch (e, s) {
      debugPrint('Error setting user shared habit status: $e');
      debugPrint('$s');
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
      final retrievedSettings = doc.exists
          ? (doc
              .data()!
              .entries
              .map<SettingModel>((e) => SettingModel.fromMap({
                    'settingName': e.key,
                    'settingValue': e.value['settingValue'] is Map
                        ? TimeModel.fromMap(e.value['settingValue'])
                        : e.value['settingValue'],
                    'settingDescription:': e.value['settingDescription'] ?? ''
                  }))
              .toList())
          : <SettingModel>[];
      return retrievedSettings;
    } catch (e, s) {
      debugPrint('Error getting settings: $e');
      debugPrint('$s');
      rethrow;
    }
  }

  Future<void> setSettings(String userId, List<SettingModel> settings) async {
    try {
      final settingsMap = settings
          .asMap()
          .map((index, s) => MapEntry(s.settingName, s.toMap()));
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('userSettings')
          .set(settingsMap);
    } catch (e, s) {
      debugPrint('Error setting settings: $e, $s');
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
          .update({setting.settingName: setting.toMap()});
    } catch (e, s) {
      debugPrint('Error updating setting: $e');
      debugPrint('$s');
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
    } catch (e, s) {
      debugPrint('Error toggling user block: $e');
      debugPrint('$s');
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
    } catch (e, s) {
      debugPrint('Error clearing user data: $e');
      debugPrint('$s');
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
            .set({setting.settingName: setting.settingValue.toString()},
                SetOptions(merge: true));
      }
    } catch (e, s) {
      debugPrint('Error resetting user settings: $e');
      debugPrint('$s');
      rethrow;
    }
  }

  // Expose Firebase instances if needed by other services
  FirebaseFirestore get firestore => _firestore;
  FirebaseAuth get auth => _auth;
}
