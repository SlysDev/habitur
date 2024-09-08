import 'package:habitur/data/local/habits_local_storage.dart';
import 'package:habitur/data/local/settings_local_storage.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/providers/network_state_provider.dart';
import 'package:provider/provider.dart';

class DataManager {
  // TODO 9/7/24: Fix error when loading data and not logged in & working from offline data
  Future<void> loadData(context) async {
    Database db = Database();
    await Provider.of<UserLocalStorage>(context, listen: false).loadData();
    await Provider.of<HabitsLocalStorage>(context, listen: false).init();
    await Provider.of<SettingsLocalStorage>(context, listen: false).init();
    if (db.userDatabase.isLoggedIn) {
      DateTime lastUpdated = await db.lastUpdatedManager.lastUpdated;
      if (lastUpdated.isAfter(
              Provider.of<UserLocalStorage>(context, listen: false)
                  .lastUpdated) ||
          Provider.of<HabitsLocalStorage>(context, listen: false)
              .getHabitData()
              .isEmpty) {
        print('loading from DB');
        await db.loadData(context);
        if (!Provider.of<NetworkStateProvider>(context, listen: false)
            .isConnected) {
          print('offline; loading from LS');
          await Provider.of<UserLocalStorage>(context, listen: false)
              .loadData();
          await Provider.of<HabitsLocalStorage>(context, listen: false)
              .loadData(context);
        }
      } else {
        print('loading from LS');
        await Provider.of<UserLocalStorage>(context, listen: false).loadData();
        await Provider.of<HabitsLocalStorage>(context, listen: false)
            .loadData(context);
        await db.userDatabase.uploadUserData(context);
        await db.statsDatabase.uploadStatistics(context);
        await db.settingsDatabase.uploadData(context);
        await db.communityChallengeDatabase.loadCommunityChallenges(context);
      }
    } else {
      print('user is not logged in; loading from LS');
      await Provider.of<UserLocalStorage>(context, listen: false).loadData();
      await Provider.of<HabitsLocalStorage>(context, listen: false)
          .loadData(context);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
    await Provider.of<HabitManager>(context, listen: false)
        .resetHabits(context);
  }
}
