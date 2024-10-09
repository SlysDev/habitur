import 'package:flutter/material.dart';
import 'package:habitur/components/aside_button.dart';
import 'package:habitur/components/custom_alert_dialog.dart';
import 'package:habitur/components/loading_overlay_wrapper.dart';
import 'package:habitur/components/primary_button.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/data/data_manager.dart';
import 'package:habitur/data/local/habits_local_storage.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/providers/login_registration_state.dart';
import 'package:provider/provider.dart';
import '../components/filled_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habitur/providers/loading_state_provider.dart';
import 'package:habitur/data/local/user_local_storage.dart';

class LoginScreen extends StatelessWidget {
  late final _auth = FirebaseAuth.instance;
  late String email;
  late String password;

  @override
  Widget build(BuildContext context) {
    return Consumer<LoadingStateProvider>(
      builder: (context, loadingData, child) {
        return LoadingOverlayWrapper(
          child: Scaffold(
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      height: 100,
                      child: Flexible(
                        child: Container(
                          margin: EdgeInsets.all(10),
                          child: kHabiturLogo,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.04, // Spacing for logo
                    ),
                    const Text(
                      'Welcome Back.',
                      textAlign: TextAlign.center,
                      style: kTitleTextStyle,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                    FilledTextField(
                      hintText: 'Enter your email',
                      onChanged: (newValue) {
                        email = newValue;
                      },
                    ),
                    const SizedBox(height: 20),
                    FilledTextField(
                      obscureText: true,
                      hintText: 'Enter your password',
                      onChanged: (newValue) {
                        password = newValue;
                      },
                    ),
                    const SizedBox(height: 40),
                    AnimatedContainer(
                      padding: EdgeInsets.all(
                          Provider.of<LoginRegistrationState>(context)
                                  .loginSuccess
                              ? 0
                              : 15),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.fastOutSlowIn,
                      height: Provider.of<LoginRegistrationState>(context)
                              .loginSuccess
                          ? 0
                          : 50,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 1200),
                        opacity: Provider.of<LoginRegistrationState>(context)
                                .loginSuccess
                            ? 0
                            : 1,
                        child: Container(
                          child: Text(
                            Provider.of<LoginRegistrationState>(context)
                                .errorMessage,
                            style: kErrorTextStyle.copyWith(
                              color: kRed,
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.0275,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 80),
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
                                    'Are you sure you want to log in? All of your data will be overwritten.'),
                                actions: [
                                  AsideButton(
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                    text: 'Yes',
                                  ),
                                  const SizedBox(width: 10),
                                  AsideButton(
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                    text: 'No',
                                  ),
                                ],
                              ),
                            );
                          } else {
                            result = true;
                          }
                          result ??= false;
                          if (result) {
                            Provider.of<LoadingStateProvider>(context,
                                    listen: false)
                                .setLoading(true);
                            try {
                              final newUser =
                                  await _auth.signInWithEmailAndPassword(
                                      email: email, password: password);
                              DataManager data = DataManager();
                              await data.loadData(context, forceDbLoad: true);
                              await Provider.of<UserLocalStorage>(context,
                                      listen: false)
                                  .saveData(context);
                              if (newUser.user?.displayName == null) {
                                await _auth.currentUser?.updateDisplayName(
                                    Provider.of<UserLocalStorage>(context,
                                            listen: false)
                                        .currentUser
                                        .username);
                              }
                              await Provider.of<HabitsLocalStorage>(context,
                                      listen: false)
                                  .uploadAllHabits(
                                      Provider.of<HabitManager>(context,
                                              listen: false)
                                          .habits,
                                      context);
                              if (newUser != null) {
                                Provider.of<LoadingStateProvider>(context,
                                        listen: false)
                                    .setLoading(false);
                                Navigator.popAndPushNamed(
                                    context, 'home_screen');
                              }
                            } catch (e, s) {
                              String errorMessage = handleLoginError(e);
                              Provider.of<LoadingStateProvider>(context,
                                      listen: false)
                                  .setLoading(false);
                              Provider.of<LoginRegistrationState>(context,
                                      listen: false)
                                  .loginFail(errorMessage);
                              Future.delayed(Duration(milliseconds: 2500), () {
                                Provider.of<LoginRegistrationState>(context,
                                        listen: false)
                                    .setLoginSuccess(true);
                              });
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Center(
                            child: AsideButton(
                              text: 'Register',
                              onPressed: () {
                                Navigator.popAndPushNamed(
                                    context, 'register_screen');
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Center(
                            child: AsideButton(
                              text: 'Offline Login',
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.popAndPushNamed(
                                    context, 'home_screen');
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String handleLoginError(dynamic e) {
    String errorMessage = '';
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Password must be at least 6 characters.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;
        case 'user-not-found':
          errorMessage = 'This email is not associated with an account.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect email or password.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many login attempts. Please try again later.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'An unexpected error occurred. Please try again.';
          break;
        default:
          errorMessage = 'An unknown error occurred.';
      }
    } else {
      if (e.toString().contains('LateInitializationError')) {
        if (e.toString().contains('email')) {
          errorMessage = 'Please enter an email address';
        } else if (e.toString().contains('password')) {
          errorMessage = 'Please enter a password';
        } else {
          errorMessage = 'An unknown error has occurred';
        }
      }
    }
    return errorMessage;
  }
}
