import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:habitur/data/local/auth_local_storage.dart';
import 'package:habitur/data/local/habits_local_storage.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/setting.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/models/time_model.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/notifications/notification_controller.dart';
import 'package:habitur/providers/add_habit_screen_provider.dart';
import 'package:habitur/providers/community_challenge_manager.dart';
import 'package:habitur/providers/network_state_provider.dart';
import 'package:habitur/screens/admin-screen.dart';
import 'package:habitur/screens/community_leaderboard_screen.dart';
import 'package:habitur/screens/habits_screen.dart';
import 'package:habitur/screens/splash_screen.dart';
import 'package:habitur/util_functions.dart';
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
import 'data/local/user_local_storage.dart';
import 'package:habitur/data/local/settings_local_storage.dart';
import 'providers/loading_state_provider.dart';
import 'providers/database.dart';
import 'providers/habit_manager.dart';
import 'providers/local_storage.dart';
import 'providers/login_registration_state.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    Directory directory =
        await path_provider.getApplicationDocumentsDirectory();
    await Hive.initFlutter(directory.path);
  }
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(StatPointAdapter());
  Hive.registerAdapter(SettingAdapter());
  Hive.registerAdapter(TimeModelAdapter());
  Hive.registerAdapter(UserModelAdapter());
  await AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      null,
      [
        NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: Color(0xFF9D50DD),
            ledColor: Colors.white)
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'basic_channel_group',
            channelGroupName: 'Basic group')
      ],
      debug: true);
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      // This is just a basic example. For real apps, you must show some
      // friendly dialog box before call the request method.
      // This is very important to not harm the user experience
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });
  runApp(Habitur());
}

class Habitur extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  State<Habitur> createState() => _HabiturState();
}

class _HabiturState extends State<Habitur> {
  @override
  void initState() {
    // Only after at least the action method is set, the notification events are delivered
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:
            NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            NotificationController.onDismissActionReceivedMethod);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<UserLocalStorage>(
              create: (context) => UserLocalStorage()),
          ChangeNotifierProvider<LoginRegistrationState>(
              create: (context) => LoginRegistrationState()),
          ChangeNotifierProvider<HabitManager>(
              create: (context) => HabitManager()),
          ChangeNotifierProvider<HabitsLocalStorage>(
              create: (context) => HabitsLocalStorage()),
          ChangeNotifierProvider<UserLocalStorage>(
              create: (context) => UserLocalStorage()),
          ChangeNotifierProvider<LoadingStateProvider>(
              create: (context) => LoadingStateProvider()),
          ChangeNotifierProvider<SettingsLocalStorage>(
              create: (context) => SettingsLocalStorage()),
          ChangeNotifierProvider<AuthLocalStorage>(
              create: (context) => AuthLocalStorage()),
          ChangeNotifierProvider<LocalStorage>(
              create: (context) => LocalStorage()),
          ChangeNotifierProvider<NetworkStateProvider>(
              create: (context) => NetworkStateProvider()),
          ChangeNotifierProvider<AddHabitScreenProvider>(
              create: (context) => AddHabitScreenProvider()),
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
            timePickerTheme: TimePickerThemeData(
              backgroundColor: kBackgroundColor,
              padding: EdgeInsets.all(30),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              dialBackgroundColor: kBackgroundColor,
              dialHandColor: kPrimaryColor,
              dialTextStyle: kMainDescription,
              dayPeriodColor: kBackgroundColor,
              dayPeriodShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              dayPeriodTextColor: Colors.white,
              dayPeriodTextStyle: kMainDescription.copyWith(fontSize: 15),
              hourMinuteShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              hourMinuteColor: kBackgroundColor,
              hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
                  states.contains(MaterialState.selected)
                      ? Colors.white
                      : kDarkGray),
              hourMinuteTextStyle: kTitleTextStyle,
              cancelButtonStyle: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.only(top: 20)),
                  textStyle: MaterialStateProperty.all(kMainDescription),
                  foregroundColor: MaterialStateProperty.all(kGray),
                  elevation: MaterialStateProperty.all(10),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ))),
              confirmButtonStyle: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.only(top: 20)),
                  textStyle: MaterialStateProperty.all(
                      kMainDescription.copyWith(fontWeight: FontWeight.bold)),
                  foregroundColor: MaterialStateProperty.all(kPrimaryColor),
                  elevation: MaterialStateProperty.all(10),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ))),
            ),
          ),
          initialRoute: 'splash_screen',
          onGenerateRoute: (settings) {
            Widget page;
            switch (settings.name) {
              case 'splash_screen':
                page = const SplashScreen();
                break;
              case 'welcome_screen':
                page = WelcomeScreen();
                break;
              case 'login_screen':
                page = LoginScreen();
                break;
              case 'register_screen':
                page = RegisterScreen();
                break;
              case 'admin_screen':
                page = const AdminScreen();
                break;
              case 'home_screen':
                page = HomeScreen();
                break;
              case 'habits_screen':
                page = HabitsScreen();
                break;
              case 'habits_screen_offline':
                page =
                    HabitsScreen(); // You can differentiate offline here if needed
                break;
              case 'settings_screen':
                page = SettingsScreen();
                break;
              case 'statistics_screen':
                page = const StatisticsScreen();
                break;
              default:
                page = const SplashScreen(); // Default fallback
                break;
            }

            return createFadeRoute(page);
          },
        ));
  }
}
