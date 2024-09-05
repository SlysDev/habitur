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
    await Provider.of<UserLocalStorage>(context, listen: false).loadData();
    await Provider.of<HabitsLocalStorage>(context, listen: false).init();
    await Provider.of<SettingsLocalStorage>(context, listen: false).init();
    if (db.userDatabase.isLoggedIn) {
      DateTime lastUpdated = await db.lastUpdatedManager.lastUpdated;
      if (lastUpdated.isAfter(
          Provider.of<UserLocalStorage>(context, listen: false).lastUpdated)) {
        print('loading from DB');
        await db.userDatabase.loadUserData(context);
        await db.statsDatabase.loadStatistics(context);
        await db.settingsDatabase.loadData(context);
        await db.habitDatabase.loadHabits(context);
        if (!Provider.of<NetworkStateProvider>(context, listen: false)
            .isConnected) {
          await Provider.of<UserLocalStorage>(context, listen: false)
              .loadData();
        }
      } else {
        print('loading from LS');
        await Provider.of<UserLocalStorage>(context, listen: false).loadData();
        await Provider.of<HabitsLocalStorage>(context, listen: false)
            .loadData(context);
        await db.userDatabase.uploadUserData(context);
        await db.statsDatabase.uploadStatistics(context);
        await db.settingsDatabase.uploadData(context);
      }
    } else {
      print('user is not logged in; loading from LS');
      await Provider.of<HabitsLocalStorage>(context, listen: false)
          .loadData(context);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
    await db.communityChallengeDatabase.loadCommunityChallenges(context);
    await Provider.of<HabitManager>(context, listen: false)
        .resetHabits(context);
  }
}
