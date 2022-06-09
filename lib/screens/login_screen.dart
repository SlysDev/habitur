import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import '../components/filled_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatelessWidget {
  late final _auth = FirebaseAuth.instance;
  late String email;
  late String password;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(child: kHabiturLogo),
          Text(
            'Welcome Back!',
            textAlign: TextAlign.center,
            style: kTitleTextStyle,
          ),
          SizedBox(
            height: 40,
          ),
          FilledTextField(
            hintText: 'Enter your email',
            onChanged: (newValue) {
              email = newValue;
            },
          ),
          FilledTextField(
            obscureText: true,
            hintText: 'Enter your password',
            onChanged: (newValue) {
              password = newValue;
            },
          ),
          Container(
            margin: EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                _auth.signInWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                Navigator.pushNamed(context, 'home_screen');
              },
              child: Text('Login'),
            ),
          ),
        ],
      ),
    );
  }
}
