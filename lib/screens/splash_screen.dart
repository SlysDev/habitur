import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habitur/components/aside_button.dart';
import 'package:habitur/components/custom_alert_dialog.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/data/data_manager.dart';
import 'package:habitur/data/local/habits_local_storage.dart';
import 'package:habitur/data/local/settings_local_storage.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/network_state_provider.dart';
import 'package:habitur/screens/home_screen.dart';
import 'package:habitur/screens/welcome_screen.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    return GestureDetector(
      onDoubleTap: () async {
        dynamic result = await showDialog(
          context: context,
          builder: (context) => CustomAlertDialog(
            title: 'Warning',
            content: Text(
                'Are you sure you want to clear all account data (habits, stats, etc.)? This cannot be undone.'),
            actions: [
              AsideButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  text: 'Yes'),
              SizedBox(width: 10),
              AsideButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  text: 'No'),
            ],
          ),
        );
        result == null ? result = false : null;
        if (result) {
          print('are we here');
          Database db = Database();
          await Provider.of<HabitsLocalStorage>(context, listen: false)
              .deleteData();
          Provider.of<UserLocalStorage>(context, listen: false).clearStats();
          await Provider.of<UserLocalStorage>(context, listen: false)
              .deleteData();
          await Provider.of<SettingsLocalStorage>(context, listen: false)
              .populateDefaultSettingsData();
          Provider.of<SettingsLocalStorage>(context, listen: false)
              .updateSettings();
          db.settingsDatabase.populateDefaultSettingsData();
          if (db.userDatabase.isLoggedIn) {
            await db.habitDatabase.clearHabits(context);
            await db.statsDatabase.clearStatistics(context);
          }
        }
      },
      child: AnimatedSplashScreen.withScreenFunction(
        curve: Curves.ease,
        duration: 1000,
        splash: 'assets/images/logo.png',
        backgroundColor: kBackgroundColor,
        splashIconSize: 150,
        splashTransition: SplashTransition.scaleTransition,
        screenFunction: () async {
          DataManager dataManager = DataManager();
          await dataManager.loadData(context);
          return auth.currentUser != null ? HomeScreen() : WelcomeScreen();
        },
      ),
    );
  }
}
