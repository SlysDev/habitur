import 'package:flutter/material.dart';
import 'package:habitur/modules/habit_reset_module.dart';
import 'package:habitur/providers/login_registration_state.dart';
import 'package:habitur/screens/statistics_screen.dart';
import 'constants.dart';
// Screens
import 'screens/welcome_screen.dart';
import 'screens/register_screen.dart';
import "screens/login_screen.dart";
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/habit_selection_screen.dart';
// Packages
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:workmanager/workmanager.dart';
// Providers
import 'providers/user_data.dart';
import 'providers/settings_data.dart';
import 'providers/loading_data.dart';
import 'providers/database.dart';

// Background Tasks
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    print("Task executing : $task");
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Workmanager().registerPeriodicTask(
    "1",
    "testReset",
    frequency: Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );
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
          ChangeNotifierProvider<MHabitReset>(
              create: (context) => MHabitReset()),
          ChangeNotifierProvider<Database>(create: (context) => Database()),
          ChangeNotifierProvider<LoadingData>(
              create: (context) => LoadingData()),
          ChangeNotifierProvider<SettingsData>(
              create: (context) => SettingsData()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            textTheme: GoogleFonts.ralewayTextTheme(),
            primaryColor: kDarkBlue,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                  textStyle: MaterialStateProperty.all(
                    GoogleFonts.raleway().copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                  elevation: MaterialStateProperty.all(10),
                  shadowColor: MaterialStateProperty.all(kSlateGray),
                  padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 40)),
                  backgroundColor: MaterialStateProperty.all<Color>(kDarkBlue),
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
            'home_screen': (context) => HomeScreen(
                  isOnline: true,
                ),
            'home_screen_offline': (context) => HomeScreen(
                  isOnline: false,
                ),
            'settings_screen': (context) => SettingsScreen(),
            'statistics_screen': (context) => StatisticsScreen(),
            'habit_selection_screen': (context) => HabitSelectionScreen(),
          },
        ));
  }
}
