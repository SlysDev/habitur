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

import '../util_functions.dart';

final _firestore = FirebaseFirestore.instance;

class RegisterScreen extends StatelessWidget {
  late final _auth = FirebaseAuth.instance;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
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
                    controller: usernameController,
                    hintText: 'Create your username',
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: MultilineTextField(
                    controller: bioController,
                    hintText: 'Add your bio',
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: FilledTextField(
                    controller: emailController,
                    hintText: 'Enter your email',
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: FilledTextField(
                    controller: passwordController,
                    obscureText: true,
                    hintText: 'Create your password',
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
                        Database db = Database();
                        await db.userDatabase.registerUser(
                          usernameController.text,
                          emailController.text,
                          passwordController.text,
                          bioController.text,
                          context,
                          withRethrow: true,
                        );
                        Provider.of<UserLocalStorage>(context, listen: false)
                            .currentUser = UserModel(
                          username: usernameController.text,
                          bio: bioController.text,
                          email: emailController.text,
                          uid: _auth.currentUser!.uid,
                          userLevel: 0,
                          userXP: 0,
                          isAdmin: false,
                        );
                        Provider.of<LoadingStateProvider>(context,
                                listen: false)
                            .setLoading(false);
                        Navigator.popAndPushNamed(context, 'home_screen');
                      } catch (e) {
                        debugPrint(e.toString());
                        String errorMessage = handleRegisterError(e);
                        showErrorDialog(context, errorMessage,
                            duration: Duration(seconds: 2));
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

  String handleRegisterError(dynamic e) {
    String errorMessage = '';
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Password must be at least 6 characters.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account with this email already exists.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        case 'too-many-requests':
          errorMessage =
              'Too many registration attempts. Please try again later.';
          break;
        default:
          errorMessage = 'An unknown error occurred.';
      }
    } else if (e.toString().contains('LateInitializationError')) {
      if (e.toString().contains('email')) {
        errorMessage = 'Please enter an email address';
      } else if (e.toString().contains('password')) {
        errorMessage = 'Please enter a password';
      } else {
        errorMessage = 'An unknown error has occurred';
      }
    } else if (e.toString().contains('Username is already taken')) {
      errorMessage = 'Username is already taken. Please choose another one.';
    } else {
      errorMessage = 'An unknown error has occurred';
    }
    return errorMessage;
  }
}
