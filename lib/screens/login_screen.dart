import 'package:flutter/material.dart';
import 'package:habitur/components/aside_button.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/providers/database.dart';
import 'package:ionicons/ionicons.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';
import '../components/filled_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
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
        return BlurryModalProgressHUD(
          progressIndicator: HeartbeatProgressIndicator(
            child: const Icon(
              Ionicons.walk,
              color: kSlateGray,
              size: 50,
            ),
          ),
          blurEffectIntensity: 4,
          inAsyncCall: loadingData.isLoading,
          child: Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Flexible(child: kHabiturLogo),
                const Text(
                  'Welcome Back!',
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
                Container(
                  margin: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final newUser = await _auth.signInWithEmailAndPassword(
                            email: email, password: password);
                        if (newUser != null) {
                          Navigator.popAndPushNamed(context, 'home_screen');
                          loadingData.toggleLoading();
                        } else {
                          loadingData.disableLoading();
                        }
                      } catch (e) {
                        loadingData.disableLoading();
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
                      Navigator.popAndPushNamed(context, 'register_screen');
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
