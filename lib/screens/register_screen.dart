import 'package:flutter/material.dart';
import 'package:habitur/components/loading_overlay_wrapper.dart';
import 'package:habitur/components/multiline_outlined_text_field.dart';
import 'package:habitur/components/primary_button.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/loading_state_provider.dart';
import 'package:habitur/providers/login_registration_state.dart';
import 'package:provider/provider.dart';
import '../components/filled_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitur/components/aside_button.dart';
import 'package:habitur/data/local/user_local_storage.dart';

final _firestore = FirebaseFirestore.instance;

class RegisterScreen extends StatelessWidget {
  late final _auth = FirebaseAuth.instance;
  late String username;
  late String bio;
  late String email;
  late String password;
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    return LoadingOverlayWrapper(
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.04, // Spacing for logo
                ),
                Container(
                  height: 100,
                  child: Center(
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
                  'Hey there!',
                  textAlign: TextAlign.center,
                  style: kTitleTextStyle,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.04,
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: FilledTextField(
                    hintText: 'Create your username',
                    onChanged: (newValue) {
                      username = newValue;
                    },
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: MultilineTextField(
                    hintText: 'Add your bio',
                    onChanged: (newValue) {
                      bio = newValue;
                    },
                  ),
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
                    hintText: 'Create your password',
                    onChanged: (newValue) {
                      password = newValue;
                    },
                  ),
                ),
                AnimatedContainer(
                  padding: EdgeInsets.all(
                      Provider.of<LoginRegistrationState>(context)
                              .registerSuccess
                          ? 0
                          : 15),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.fastOutSlowIn,
                  height: Provider.of<LoginRegistrationState>(context)
                          .registerSuccess
                      ? 0
                      : 50,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 1200),
                    opacity: Provider.of<LoginRegistrationState>(context)
                            .registerSuccess
                        ? 0
                        : 1,
                    child: Container(
                      child: Text(
                        Provider.of<LoginRegistrationState>(context)
                            .errorMessage,
                        style: kErrorTextStyle.copyWith(
                          color: kRed,
                          fontSize: MediaQuery.of(context).size.height * 0.0275,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                  child: PrimaryButton(
                    onPressed: () async {
                      try {
                        Provider.of<LoadingStateProvider>(context,
                                listen: false)
                            .setLoading(true);
                        final newUser =
                            await _auth.createUserWithEmailAndPassword(
                                email: email, password: password);
                        if (newUser.user != null) {
                          Database db = Database();
                          debugPrint('New user created.');
                          _auth.currentUser?.updateDisplayName(username);
                          await db.userDatabase
                              .userSetup(username, email, bio, context);
                          Provider.of<UserLocalStorage>(context, listen: false)
                                  .currentUser =
                              UserModel(
                                  username: username,
                                  bio: bio,
                                  email: email,
                                  uid: newUser.user!.uid,
                                  userLevel: 0,
                                  userXP: 0,
                                  isAdmin: false);
                          Provider.of<LoadingStateProvider>(context,
                                  listen: false)
                              .setLoading(false);
                          Navigator.popAndPushNamed(context, 'home_screen');
                        }
                      } catch (e) {
                        debugPrint(e.toString());
                        String errorMessage = '';
                        debugPrint(e.runtimeType.toString());
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
                            case 'too-many-requests':
                              errorMessage =
                                  'Too many registration attempts. Please try again later.';
                              break;
                            case 'operation-not-allowed':
                              errorMessage =
                                  'An unexpected error occurred. Please try again.';
                              break;
                            case 'email-already-in-use':
                              errorMessage =
                                  'An account with this email already exists.';
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
                          } else if (e.toString().contains(
                              'The email address is already in use by another account')) {
                            errorMessage =
                                'An account with this email already exists';
                          } else {
                            errorMessage = 'An unknown error has occurred';
                          }
                        }
                        Provider.of<LoadingStateProvider>(context,
                                listen: false)
                            .setLoading(false);
                        Provider.of<LoginRegistrationState>(context,
                                listen: false)
                            .registrationFail(errorMessage);
                        Future.delayed(Duration(milliseconds: 2500), () {
                          Provider.of<LoginRegistrationState>(context,
                                  listen: false)
                              .setRegisterSuccess(true);
                        });
                      }
                    },
                    text: 'Register',
                  ),
                ),
                Center(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    child: AsideButton(
                      text: 'Login',
                      onPressed: () {
                        Navigator.popAndPushNamed(context, 'login_screen');
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.1, // Extra bottom padding for scrollable content
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
