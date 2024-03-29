import 'package:flutter/material.dart';
import 'package:habitur/components/aside_button.dart';
import 'package:habitur/components/primary-button.dart';
import 'package:habitur/screens/login_screen.dart';
import '../constants.dart';
import '../components/accent_elevated_button.dart';
import '../components/grayscale_elevated_button.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
