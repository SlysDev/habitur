import 'package:flutter/material.dart';
import 'package:habitur/components/aside_button.dart';
import 'package:habitur/components/custom_alert_dialog.dart';
import 'package:habitur/components/loading_overlay_wrapper.dart';
import 'package:habitur/components/primary_button.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/data/data_manager.dart';
import 'package:habitur/data/local/habits_local_storage.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/providers/login_registration_state.dart';
import 'package:habitur/screens/welcome_screen.dart';
import 'package:provider/provider.dart';
import '../components/filled_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habitur/providers/loading_state_provider.dart';
import 'package:habitur/data/local/user_local_storage.dart';

class DeleteAcccountLoginScreen extends StatelessWidget {
  late final _auth = FirebaseAuth.instance;
  late String email;
  late String password;
  @override
  Widget build(BuildContext context) {
    return Consumer<LoadingStateProvider>(
      builder: (context, loadingData, child) {
        return LoadingOverlayWrapper(
          child: Scaffold(
            body:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                height: 100,
                child: kHabiturLogo,
              ),
              const Text(
                'Relogin',
                textAlign: TextAlign.center,
                style: kTitleTextStyle,
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Re-authenticate to start the account deletion process',
                  textAlign: TextAlign.center,
                  style: kMainDescription.copyWith(color: kDarkGray),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: FilledTextField(
                  hintText: 'Enter your email',
                  onChanged: (newValue) {
                    email = newValue;
                  },
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: FilledTextField(
                  obscureText: true,
                  hintText: 'Enter your password',
                  onChanged: (newValue) {
                    password = newValue;
                  },
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 700),
                opacity:
                    Provider.of<LoginRegistrationState>(context).loginSuccess
                        ? 0
                        : 1,
                child: Container(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    Provider.of<LoginRegistrationState>(context).errorMessage,
                    style: kErrorTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(20),
                child: PrimaryButton(
                    text: 'Login',
                    onPressed: () async {
                      dynamic result;
                      if (Provider.of<HabitsLocalStorage>(context,
                              listen: false)
                          .getHabitData(context)
                          .isNotEmpty) {
                        result = await showDialog(
                          context: context,
                          builder: (context) => CustomAlertDialog(
                            title: 'Warning',
                            content: Text(
                                'Are you sure? All of your data will be lost'),
                            actions: [
                              AsideButton(
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  text: 'Yes'),
                              SizedBox(width: 10),
                              AsideButton(
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                  text: 'No'),
                            ],
                          ),
                        );
                      } else {
                        result = true;
                      }
                      result == null ? result = false : null;
                      if (result) {
                        Provider.of<LoadingStateProvider>(context,
                                listen: false)
                            .setLoading(true);
                        try {
                          Database db = Database();
                          Provider.of<LoadingStateProvider>(context,
                                  listen: false)
                              .setLoading(true);
                          late final _auth = FirebaseAuth.instance;
                          await db.userDatabase.deleteUser(context);
                          await _auth.currentUser!.delete();
                          Provider.of<LoadingStateProvider>(context,
                                  listen: false)
                              .setLoading(false);
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WelcomeScreen()),
                              (route) => false);
                          Navigator.popAndPushNamed(context, 'welcome_screen');
                        } catch (e, s) {
                          debugPrint(e.toString());
                          debugPrint(s.toString());
                          String errorMessage = '';
                          if (e is FirebaseAuthException) {
                            switch (e.code) {
                              case 'weak-password':
                                errorMessage =
                                    'Password must be at least 6 characters.';
                                break;
                              case 'invalid-email':
                                errorMessage =
                                    'Please enter a valid email address.';
                                break;
                              case 'user-not-found':
                                errorMessage =
                                    'This email is not associated with an account.';
                                break;
                              case 'wrong-password':
                                errorMessage = 'Incorrect email or password.';
                                break;
                              case 'user-disabled':
                                errorMessage =
                                    'This account has been disabled.';
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
                          } else if (e
                              .toString()
                              .contains('LateInitializationError')) {
                            if (e.toString().contains('email')) {
                              errorMessage = 'Please enter an email address';
                            } else if (e.toString().contains('password')) {
                              errorMessage = 'Please enter a password';
                            } else {
                              errorMessage = 'An unknown error has occurred';
                            }
                          }
                          Provider.of<LoginRegistrationState>(context,
                                  listen: false)
                              .loginFail(errorMessage);
                        }
                        Provider.of<LoadingStateProvider>(context,
                                listen: false)
                            .setLoading(false);
                      }
                    }),
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
              Container(
                margin: const EdgeInsets.all(20),
                child: AsideButton(
                  text: 'Offline Login',
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.popAndPushNamed(context, 'home_screen');
                  },
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}
