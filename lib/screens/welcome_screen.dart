import 'package:flutter/material.dart';
import 'package:habitur/components/aside_button.dart';
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
            RichText(
              text: TextSpan(children: [
                TextSpan(
                  style: kMainDescription.copyWith(color: Colors.black),
                  text: 'Making habits better, ',
                ),
                TextSpan(
                    text: 'together',
                    style: kMainDescription.copyWith(
                      fontSize: 19,
                      color: kLightBlue,
                    )),
              ]),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 40,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, 'register_screen');
              },
              child: Text(
                'Let\'s begin',
              ),
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
