import 'package:flutter/material.dart';
import 'package:habitur/ui/widgets/aside_button.dart';
import 'package:habitur/ui/widgets/primary_button.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/constants.dart';
import 'welcome_viewmodel.dart';

class WelcomeView extends StackedView<WelcomeViewModel> {
  const WelcomeView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, WelcomeViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 100, child: kHabiturLogo),
            const SizedBox(height: 20),
            Text(
              'Habitur',
              style: kTitleTextStyle.copyWith(fontSize: 64),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 10),
            const SizedBox(height: 40),
            PrimaryButton(
              onPressed: viewModel.navigateToRegister,
              text: 'Let\'s begin',
            ),
            const SizedBox(height: 40),
            AsideButton(
              onPressed: viewModel.navigateToLogin,
              text: 'I already have an account',
            ),
          ],
        ),
      ),
    );
  }

  @override
  WelcomeViewModel viewModelBuilder(BuildContext context) => WelcomeViewModel();
}
