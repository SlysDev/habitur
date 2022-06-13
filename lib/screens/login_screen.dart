import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:ionicons/ionicons.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';
import '../components/filled_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:habitur/providers/loading_data.dart';

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
            child: Icon(
              Ionicons.walk,
              color: kTurqoiseAccent,
              size: 50,
            ),
          ),
          blurEffectIntensity: 4,
          inAsyncCall: loadingData.isLoading,
          child: Scaffold(
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
                    onPressed: () async {
                      try {
                        final newUser = await _auth.signInWithEmailAndPassword(
                            email: email, password: password);
                        if (newUser != null) {
                          Navigator.pushNamed(context, 'chat_screen');
                        }
                      } catch (e, st) {
                        print(e);
                        loadingData.toggleLoading();
                      }
                      loadingData.toggleLoading();
                    },
                    child: Text('Login'),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  child: AsideButton(
                    text: 'Register',
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, 'register_screen');
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

class AsideButton extends StatelessWidget {
  String text;
  void Function() onPressed;
  AsideButton({required this.text, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Text(
        text,
        style: TextStyle(color: kTurqoiseAccent),
      ),
      onTap: onPressed,
    );
  }
}
