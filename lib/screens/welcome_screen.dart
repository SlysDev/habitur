import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habitur/components/aside_button.dart';
import 'package:habitur/components/primary_button.dart';
import 'package:habitur/data/local/auth_local_storage.dart';
import 'package:habitur/screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../components/accent_elevated_button.dart';
import '../components/grayscale_elevated_button.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            kHabiturLogo,
            Text(
              'Habitur',
              style: kTitleTextStyle.copyWith(fontSize: 64),
            ),
            SizedBox(
              height: 20,
            ),
            // Text(
            //   'Glad to have you here.',
            //   textAlign: TextAlign.center,
            //   style: kHeadingTextStyle,
            // ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 40,
            ),
            PrimaryButton(
              onPressed: () {
                Navigator.pushNamed(context, 'register_screen');
              },
              text: 'Let\'s begin',
            ),
            SizedBox(
              height: 40,
            ),
            AsideButton(
                text: 'Login',
                onPressed: () {
                  Navigator.pushNamed(context, 'login_screen');
                }),
            // Only for offline testing purposes
            SizedBox(
              height: 40,
            ),
            AsideButton(
                text: 'Continue as Guest',
                onPressed: () {
                  Navigator.pushNamed(context, 'habits_screen');
                }),
            // AsideButton(
            //   text: 'Offline Login',
            //   onPressed: () {
            //     Navigator.pushNamed(context, 'home_screen_offline');
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
