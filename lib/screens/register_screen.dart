import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import '../components/accent_elevated_button.dart';
import '../components/filled_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;

class RegisterScreen extends StatelessWidget {
  late final _auth = FirebaseAuth.instance;
  late String username;
  late String email;
  late String password;
  bool showSpinner = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(child: kHabiturLogo),
            Text(
              'Begin your Journey.',
              textAlign: TextAlign.center,
              style: kTitleTextStyle,
            ),
            SizedBox(
              height: 40,
            ),
            FilledTextField(
              hintText: 'Enter your username',
              onChanged: (newValue) {
                username = newValue;
              },
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
                onPressed: () async {
                  try {
                    final newUser = await _auth.createUserWithEmailAndPassword(
                        email: email, password: password);
                    if (newUser.user != null) {
                      _firestore.collection('users').add({
                        'username': username,
                        'uuid': newUser.user!.uid,
                      });
                      Navigator.pushNamed(context, 'home_screen');
                    }
                  } catch (e, st) {
                    print(e);
                  }
                },
                child: Text('Register'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
