import 'package:flutter/material.dart';
import 'package:habitur/data/local/habits_local_storage.dart';
import 'package:habitur/data/local/settings_local_storage.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/providers/network_state_provider.dart';
import 'package:provider/provider.dart';

class DataManager {
  Future<void> loadData(context, {bool forceDbLoad = false}) async {
    debugPrint('\n=== Starting loadData() ===');
    debugPrint('forceDbLoad: $forceDbLoad');
    
    try {
      if (forceDbLoad) {
        debugPrint('Clearing local storage...');
        await clearLocalStorage(context);
        debugPrint('Local storage cleared');
      }
      
      debugPrint('Initializing storage...');
      await initLocalStorage(context);
      debugPrint('Storage initialized');
      
      debugPrint('Loading user data...');
      await loadUserData(context, forceDbLoad: forceDbLoad);
      debugPrint('User data loaded');
      
      debugPrint('Loading habits data...');
      await loadHabitsData(context, forceDbLoad: forceDbLoad);
      debugPrint('Habits data loaded');
      
      debugPrint('Loading settings data...');
      await loadSettingsData(context, forceDbLoad: forceDbLoad);
      debugPrint('Settings data loaded');
      
      debugPrint('Loading stats data...');
      await loadStatsData(context, forceDbLoad: forceDbLoad);
      debugPrint('Stats data loaded');
      
      debugPrint('Loading community challenges...');
      await loadCommunityChallenges(context, forceDbLoad: forceDbLoad);
      debugPrint('Community challenges loaded');
      
      debugPrint('Resetting habits...');
      await _resetHabits(context);
      debugPrint('Habits reset');
      
      debugPrint('=== Data loading complete ===\n');
    } catch (e, stackTrace) {
      debugPrint('\n!!! Error in loadData() !!!');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('========================\n');
      rethrow;
    }
  }

  Future<void> initLocalStorage(context) async {
    await Provider.of<UserLocalStorage>(context, listen: false).init(context);
    await Provider.of<SettingsLocalStorage>(context, listen: false)
        .init(context);
    await Provider.of<HabitsLocalStorage>(context, listen: false).init(context);
  }

  Future<void> clearLocalStorage(context) async {
    debugPrint('Clearing all local storage...');
    await Provider.of<UserLocalStorage>(context, listen: false).clearData();
    await Provider.of<HabitsLocalStorage>(context, listen: false).clearData();
    await Provider.of<SettingsLocalStorage>(context, listen: false).clearData();
  }

  Future<void> loadUserData(BuildContext context,
      {bool forceDbLoad = false}) async {
    Database db = Database();
    if (db.userDatabase.isLoggedIn) {
      if (await _shouldLoadFromDb(
          Provider.of<UserLocalStorage>(context, listen: false).lastUpdated,
          forceDbLoad,
          context)) {
        debugPrint('Loading user data from DB');
        await db.userDatabase.loadUserData(context);
      } else {
        debugPrint('Loading user data from Local Storage');
        try {
          await Provider.of<UserLocalStorage>(context, listen: false)
              .loadData(context);
        } catch (e) {
          debugPrint('LS data load failed; trying from DB');
          await db.userDatabase.loadUserData(context);
        }
      }
    } else {
      debugPrint('User not logged in, loading from Local Storage');
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
      await Provider.of<UserLocalStorage>(context, listen: false)
          .loadData(context);
    }
  }

  Future<void> loadHabitsData(BuildContext context,
      {bool forceDbLoad = false}) async {
    Database db = Database();
    final habitsLocalStorage =
        Provider.of<HabitsLocalStorage>(context, listen: false);
        final HabitManager habitManager = Provider.of<HabitManager>(context, listen: false);

    if (db.userDatabase.isLoggedIn) {
      if (await _shouldLoadFromDb(
          habitsLocalStorage.lastUpdated, forceDbLoad, context)) {
        debugPrint('Loading habits from DB');
        await habitManager.loadHabitsFromDB(context);
      } else {
        debugPrint('Loading habits from Local Storage');
        await habitManager.loadHabitsFromLocalStorage(context);
      }
    } else {
      debugPrint('User not logged in, loading habits from Local Storage');
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
        await habitManager.loadHabitsFromLocalStorage(context);
    }
  }

  Future<void> loadStatsData(BuildContext context,
      {bool forceDbLoad = false}) async {
    Database db = Database();
    if (db.userDatabase.isLoggedIn) {
      if (await _shouldLoadFromDb(
          Provider.of<UserLocalStorage>(context, listen: false).lastUpdated,
          forceDbLoad,
          context)) {
        debugPrint('Loading stats from DB');
        await db.statsDatabase.loadStatistics(context);
      } else {
        debugPrint('Loading stats from Local Storage');
        await Provider.of<UserLocalStorage>(context, listen: false)
            .loadData(context);
      }
    } else {
      debugPrint('User not logged in, loading stats from Local Storage');
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
      await Provider.of<UserLocalStorage>(context, listen: false)
          .loadData(context);
    }
  }

  Future<void> loadSettingsData(BuildContext context,
      {bool forceDbLoad = false}) async {
    Database db = Database();
    final settingsLocalStorage =
        Provider.of<SettingsLocalStorage>(context, listen: false);

    if (db.userDatabase.isLoggedIn) {
      if (await _shouldLoadFromDb(
          settingsLocalStorage.lastUpdated, forceDbLoad, context)) {
        debugPrint('Loading settings from DB');
        await db.settingsDatabase.loadData(context);
      }
    }
  }

  Future<void> loadCommunityChallenges(BuildContext context,
      {bool forceDbLoad = false}) async {
    Database db = Database();
    if (db.userDatabase.isLoggedIn) {
      await db.communityChallengeDatabase.loadCommunityChallenges(context);
    }
  }

  Future<void> _resetHabits(BuildContext context) async {
    await Provider.of<HabitManager>(context, listen: false)
        .resetHabits(context);
  }

  Future<bool> _shouldLoadFromDb(
      DateTime localLastUpdated, bool forceDbLoad, BuildContext context) async {
    Database db = Database();
    DateTime? dbLastUpdated = await db.lastUpdatedManager.lastUpdated;
    if (dbLastUpdated == null) {
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
      return false;
    }
    return forceDbLoad || dbLastUpdated.isAfter(localLastUpdated);
  }
}
