import 'package:flutter/material.dart';
import 'package:habitur/ui/widgets/aside_button.dart';
import 'package:habitur/ui/widgets/primary_button.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/constants.dart';
import 'register_viewmodel.dart';

class RegisterView extends StackedView<RegisterViewModel> {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, RegisterViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
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
              const SizedBox(height: 8.0),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: viewModel.setConfirmPassword,
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Confirm your password',
                ),
              ),
              const SizedBox(height: 24.0),
              PrimaryButton(
                onPressed: viewModel.register,
                text: 'Register',
              ),
              const SizedBox(height: 12.0),
              AsideButton(
                onPressed: viewModel.navigateToLogin,
                text: 'Already have an account? Log in',
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  RegisterViewModel viewModelBuilder(BuildContext context) =>
      RegisterViewModel();
}
