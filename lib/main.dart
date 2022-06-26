import 'package:flutter/material.dart';
import 'constants.dart';
// Screens
import 'screens/welcome_screen.dart';
import 'screens/register_screen.dart';
import "screens/login_screen.dart";
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
// Packages
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
// Providers
import 'providers/user_data.dart';
import 'providers/settings_data.dart';
import 'providers/loading_data.dart';
import 'providers/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(Habitur());
}

class Habitur extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<UserData>(create: (context) => UserData()),
          ChangeNotifierProvider<Database>(create: (context) => Database()),
          ChangeNotifierProvider<LoadingData>(
              create: (context) => LoadingData()),
          ChangeNotifierProvider<SettingsData>(
              create: (context) => SettingsData()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            textTheme: GoogleFonts.workSansTextTheme(),
            primaryColor: kDarkBlueColor,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                  textStyle: MaterialStateProperty.all(
                    GoogleFonts.workSans().copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  elevation: MaterialStateProperty.all(10),
                  shadowColor: MaterialStateProperty.all(kLightAccent),
                  padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 30)),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(kDarkBlueColor),
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
            'home_screen': (context) => HomeScreen(),
            'settings_screen': (context) => SettingsScreen(),
          },
        ));
  }
}
