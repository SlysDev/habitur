import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../constants.dart';
import 'startup_viewmodel.dart';

class StartupView extends StackedView<StartupViewModel> {
  const StartupView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    StartupViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            if (viewModel.isBusy)
              const CircularProgressIndicator(
                color: kPrimaryColor,
                strokeCap: StrokeCap.round,
                strokeWidth: 6.0,
                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
              ),
          ],
        ),
      ),
    );
  }

  @override
  StartupViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      StartupViewModel();

  @override
  void onViewModelReady(StartupViewModel viewModel) =>
      viewModel.runStartupLogic();
}
