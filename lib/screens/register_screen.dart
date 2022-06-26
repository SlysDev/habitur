import 'package:flutter/material.dart';
import 'package:habitur/components/habit_card.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/providers/database.dart';
import 'package:ionicons/ionicons.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';
import '../components/filled_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
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
    return Consumer<LoadingData>(
      builder: (context, loadingData, child) {
        return BlurryModalProgressHUD(
          progressIndicator: HeartbeatProgressIndicator(
            child: const Icon(
              Ionicons.walk,
              color: kTurqoiseAccent,
              size: 50,
            ),
          ),
          blurEffectIntensity: 4,
          inAsyncCall: loadingData.isLoading,
          child: Scaffold(
            body: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                  Container(
                    margin: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          final newUser =
                              await _auth.createUserWithEmailAndPassword(
                                  email: email, password: password);
                          if (newUser.user != null) {
                            print('New user created.');
                            Provider.of<Database>(context)
                                .userSetup(username, email);
                            Navigator.popAndPushNamed(context, 'home_screen');
                          }
                        } catch (e) {
                          print(e);
                          loadingData.toggleLoading();
                        }
                        loadingData.toggleLoading();
                      },
                      child: const Text('Register'),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
