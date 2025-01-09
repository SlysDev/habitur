import 'package:flutter/material.dart';
import 'package:habitur/ui/widgets/aside_button.dart';
import 'package:habitur/ui/widgets/loading_overlay/loading_overlay.dart';
import 'package:habitur/ui/widgets/primary_button.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/constants.dart';
import 'login_viewmodel.dart';

class LoginView extends StackedView<LoginViewModel> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, LoginViewModel viewModel, Widget? child) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: LoadingOverlay(
          isLoading: viewModel.isBusy,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    height: 100.0,
                    child: kHabiturLogo,
                  ),
                  const SizedBox(height: 48.0),
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.center,
                    onChanged: viewModel.setEmail,
                    decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter your email',
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    obscureText: true,
                    textAlign: TextAlign.center,
                    onChanged: viewModel.setPassword,
                    decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter your password',
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  PrimaryButton(
                    onPressed: viewModel.login,
                    text: 'Log In',
                  ),
                  const SizedBox(height: 12.0),
                  AsideButton(
                    onPressed: viewModel.navigateToRegister,
                    text: 'Don\'t have an account? Sign up',
                  ),
                  const SizedBox(height: 12.0),
                  AsideButton(
                    onPressed: viewModel.loginOffline,
                    text: 'Login Offline',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  LoginViewModel viewModelBuilder(BuildContext context) => LoginViewModel();
}
