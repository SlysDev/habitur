import 'package:flutter/material.dart';
import 'package:habitur/providers/community_challenge_manager.dart';
import 'package:habitur/providers/statistics_display_manager.dart';
import 'package:habitur/providers/summary_statistics_repository.dart';
import 'package:habitur/screens/admin-screen.dart';
import 'package:habitur/screens/community_leaderboard_screen.dart';
import 'package:habitur/screens/habits_screen.dart';
import 'constants.dart';
// Screens
import 'screens/welcome_screen.dart';
import 'screens/register_screen.dart';
import "screens/login_screen.dart";
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/edit_habit_screen.dart';
import 'screens/statistics_screen.dart';
// Packages
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
// Providers
import 'providers/user_data.dart';
import 'providers/settings_data.dart';
import 'providers/loading_data.dart';
import 'providers/database.dart';
import 'providers/habit_manager.dart';
import 'providers/local_storage.dart';
import 'providers/login_registration_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  await Hive.openBox("habits_storage");
  runApp(Habitur());
}

class Habitur extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<UserData>(create: (context) => UserData()),
          ChangeNotifierProvider<LoginRegistrationState>(
              create: (context) => LoginRegistrationState()),
          ChangeNotifierProvider<HabitManager>(
              create: (context) => HabitManager()),
          ChangeNotifierProvider<Database>(create: (context) => Database()),
          ChangeNotifierProvider<LoadingData>(
              create: (context) => LoadingData()),
          ChangeNotifierProvider<SettingsData>(
              create: (context) => SettingsData()),
          ChangeNotifierProvider<LocalStorage>(
              create: (context) => LocalStorage()),
          ChangeNotifierProvider<SummaryStatisticsRepository>(
              create: (context) => SummaryStatisticsRepository()),
          ChangeNotifierProvider<StatisticsDisplayManager>(
              create: (context) => StatisticsDisplayManager()),
          ChangeNotifierProvider<CommunityChallengeManager>(
              create: (context) => CommunityChallengeManager()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: kBackgroundColor,
            textTheme: GoogleFonts.dmSansTextTheme().copyWith(
              bodyMedium: TextStyle(color: Colors.white),
            ),
            primaryColor: kPrimaryColor,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                  textStyle: MaterialStateProperty.all(kCtaBtnStyle),
                  foregroundColor: MaterialStateProperty.all(kBackgroundColor),
                  elevation: MaterialStateProperty.all(10),
                  shadowColor:
                      MaterialStateProperty.all(kPrimaryColor.withOpacity(0.3)),
                  padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 40)),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(kPrimaryColor),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ))),
            ),
          ),
          initialRoute: 'welcome_screen',
          routes: {
            'welcome_screen': (context) => WelcomeScreen(),
            'login_screen': (context) => LoginScreen(),
            'register_screen': (context) => RegisterScreen(),
            'admin_screen': (context) => AdminScreen(),
            'home_screen': (context) => HomeScreen(
                  isOnline: true,
                ),
            'home_screen_offline': (context) => HomeScreen(
                  isOnline: false,
                ),
            'habits_screen': (context) => HabitsScreen(
                  isOnline: true,
                ),
            'habits_screen_offline': (context) => HabitsScreen(
                  isOnline: false,
                ),
            'settings_screen': (context) => SettingsScreen(),
            'statistics_screen': (context) => StatisticsScreen(),
          },
        ));
  }
}
