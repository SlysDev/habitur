import 'package:flutter/material.dart';
import 'package:habitur/components/aside_button.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/login_registration_state.dart';
import 'package:provider/provider.dart';
import '../components/filled_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habitur/providers/loading_data.dart';
import 'package:habitur/providers/user_data.dart';

class LoginScreen extends StatelessWidget {
  late final _auth = FirebaseAuth.instance;
  late String email;
  late String password;
  @override
  Widget build(BuildContext context) {
    return Consumer<LoadingData>(
      builder: (context, loadingData, child) {
        return Scaffold(
          body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Flexible(child: kHabiturLogo),
            const Text(
              'Welcome Back.',
              textAlign: TextAlign.center,
              style: kTitleTextStyle,
            ),
            const SizedBox(
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
            AnimatedOpacity(
              duration: const Duration(milliseconds: 700),
              opacity: Provider.of<LoginRegistrationState>(context).loginSuccess
                  ? 0
                  : 1,
              child: Container(
                padding: EdgeInsets.all(15),
                child: Text(
                  'Please try again.',
                  style: kErrorTextStyle,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final newUser = await _auth.signInWithEmailAndPassword(
                        email: email, password: password);
                    if (newUser != null) {
                      Navigator.popAndPushNamed(context, 'home_screen');
                    }
                  } catch (e) {
                    print(e);
                    Provider.of<LoginRegistrationState>(context, listen: false)
                        .loginFail();
                  }
                },
                child: const Text('Login'),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(20),
              child: AsideButton(
                text: 'Register',
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.popAndPushNamed(context, 'register_screen');
                },
              ),
            ),
          ]),
        );
      },
    );
  }
}
