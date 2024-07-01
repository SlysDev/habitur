import 'package:flutter/material.dart';
import 'package:habitur/components/primary-button.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/login_registration_state.dart';
import 'package:provider/provider.dart';
import '../components/filled_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habitur/providers/loading_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitur/components/aside_button.dart';
import 'package:habitur/providers/user_data.dart';

final _firestore = FirebaseFirestore.instance;

class RegisterScreen extends StatelessWidget {
  late final _auth = FirebaseAuth.instance;
  late String username;
  late String email;
  late String password;
  bool showSpinner = false;
  @override
  Widget build(BuildContext context) {
    Provider.of<LoginRegistrationState>(context).setRegisterSuccess(true);
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Flexible(child: kHabiturLogo),
          const Text(
            'Begin your Journey.',
            textAlign: TextAlign.center,
            style: kTitleTextStyle,
          ),
          const SizedBox(
            height: 40,
          ),
          FilledTextField(
            hintText: 'Create your username',
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
            hintText: 'Create your password',
            onChanged: (newValue) {
              password = newValue;
            },
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 700),
            opacity:
                Provider.of<LoginRegistrationState>(context).registerSuccess
                    ? 0
                    : 1,
            child: Container(
              padding: EdgeInsets.all(15),
              child: Text(
                Provider.of<LoginRegistrationState>(context).errorMessage,
                style: kErrorTextStyle.copyWith(
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(20),
            child: PrimaryButton(
              onPressed: () async {
                try {
                  final newUser = await _auth.createUserWithEmailAndPassword(
                      email: email, password: password);
                  if (newUser.user != null) {
                    print('New user created.');
                    Provider.of<Database>(context, listen: false)
                        .userSetup(username, email);
                    Navigator.popAndPushNamed(context, 'home_screen');
                  }
                } catch (e) {
                  print(e);
                  if (e is FirebaseAuthException) {
                    String errorMessage;
                    switch (e.code) {
                      case 'weak-password':
                        errorMessage =
                            'Password must be at least 6 characters.';
                        break;
                      case 'invalid-email':
                        errorMessage = 'Please enter a valid email address.';
                        break;
                      case 'user-not-found':
                        errorMessage =
                            'This email is not associated with an account.';
                        break;
                      case 'wrong-password':
                        errorMessage = 'Incorrect email or password.';
                        break;
                      case 'user-disabled':
                        errorMessage = 'This account has been disabled.';
                        break;
                      case 'too-many-requests':
                        errorMessage =
                            'Too many login attempts. Please try again later.';
                        break;
                      case 'operation-not-allowed':
                        errorMessage =
                            'An unexpected error occurred. Please try again.';
                        break;
                      default:
                        errorMessage = 'An unknown error occurred.';
                    }
                    Provider.of<LoginRegistrationState>(context, listen: false)
                        .registrationFail(errorMessage);
                  }
                }
              },
              text: 'Register',
            ),
          ),
          Container(
            margin: const EdgeInsets.all(20),
            child: AsideButton(
              text: 'Login',
              onPressed: () {
                Navigator.pop(context);
                Navigator.popAndPushNamed(context, 'login_screen');
              },
            ),
          ),
        ]),
      ),
    );
  }
}
