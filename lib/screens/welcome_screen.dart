import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:habitur/screens/login_screen.dart';
import '../constants.dart';
import '../components/accent_elevated_button.dart';
import '../components/grayscale_elevated_button.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Flexible(child: kHabiturLogo),
              Text(
                'Habitur',
                style: kTitleTextStyle,
              )
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Glad to have you here.',
            textAlign: TextAlign.center,
            style: kHeadingTextStyle,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'With Habitur, you can build your life, one habit at a time.',
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 60,
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
              })
        ],
      ),
    );
  }
}
