import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/data/local/habits_local_storage.dart';
import 'package:habitur/data/local/settings_local_storage.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/screens/home_screen.dart';
import 'package:habitur/screens/welcome_screen.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    return AnimatedSplashScreen.withScreenFunction(
      curve: Curves.ease,
      animationDuration: Duration(milliseconds: 800),
      duration: 1000,
      splash: 'assets/images/logo.png',
      backgroundColor: kBackgroundColor,
      splashIconSize: 150,
      splashTransition: SplashTransition.scaleTransition,
      screenFunction: () async {
        print('running?');
        await Provider.of<UserLocalStorage>(context, listen: false).loadData();
        await Provider.of<HabitsLocalStorage>(context, listen: false).init();
        await Provider.of<SettingsLocalStorage>(context, listen: false).init();
        return auth.currentUser != null ? HomeScreen() : WelcomeScreen();
      },
    );
  }
}
