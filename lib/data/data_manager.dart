import 'package:flutter/material.dart';
import 'package:habitur/data/local/habits_local_storage.dart';
import 'package:habitur/data/local/settings_local_storage.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/providers/network_state_provider.dart';
import 'package:provider/provider.dart';

class DataManager {
  Future<void> loadData(context) async {
    Database db = Database();
    await Provider.of<UserLocalStorage>(context, listen: false)
        .loadData(context);
    await Provider.of<HabitsLocalStorage>(context, listen: false).init(context);
    await Provider.of<SettingsLocalStorage>(context, listen: false)
        .init(context);
    if (db.userDatabase.isLoggedIn) {
      DateTime lastUpdated = await db.lastUpdatedManager.lastUpdated;
      if (lastUpdated.isAfter(
              Provider.of<UserLocalStorage>(context, listen: false)
                  .lastUpdated) ||
          Provider.of<HabitsLocalStorage>(context, listen: false)
              .getHabitData(context)
              .isEmpty) {
        debugPrint('loading from DB');
        await db.loadData(context);
        if (!Provider.of<NetworkStateProvider>(context, listen: false)
            .isConnected) {
          debugPrint('offline; loading from LS');
          await Provider.of<UserLocalStorage>(context, listen: false)
              .loadData(context);
          await Provider.of<HabitsLocalStorage>(context, listen: false)
              .loadData(context);
        }
      } else {
        debugPrint('loading from LS');
        await Provider.of<UserLocalStorage>(context, listen: false)
            .loadData(context);
        await Provider.of<HabitsLocalStorage>(context, listen: false)
            .loadData(context);
        await db.userDatabase.uploadUserData(context);
        await db.statsDatabase.uploadStatistics(context);
        await db.settingsDatabase.uploadData(context);
        await db.communityChallengeDatabase.loadCommunityChallenges(context);
      }
    } else {
      debugPrint('user is not logged in; loading from LS');
      await Provider.of<UserLocalStorage>(context, listen: false)
          .loadData(context);
      await Provider.of<HabitsLocalStorage>(context, listen: false)
          .loadData(context);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
    await Provider.of<HabitManager>(context, listen: false)
        .resetHabits(context);
  }
}
