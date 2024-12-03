import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/widgets/habit_card_list/habit_card_list.dart';
import 'package:habitur/ui/widgets/home_greeting_header/home_greeting_header.dart';
import 'package:habitur/ui/widgets/loading_overlay/loading_overlay.dart';
import 'package:habitur/ui/widgets/navbar/navbar.dart';
import 'package:habitur/ui/widgets/profile_drawer/profile_drawer.dart';
import 'package:stacked/stacked.dart';
import 'habits_viewmodel.dart';

class HabitsView extends StackedView<HabitsViewModel> {
  const HabitsView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, HabitsViewModel viewModel, Widget? child) {
    return LoadingOverlay(
      isLoading: viewModel.isBusy,
      child: const Scaffold(
        backgroundColor: kBackgroundColor,
        endDrawer: ProfileDrawer(),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                HomeGreetingHeader(),
                HabitCardList(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
        bottomNavigationBar: NavBar(
          currentPage: 'habits',
        ),
      ),
    );
  }

  @override
  HabitsViewModel viewModelBuilder(BuildContext context) => HabitsViewModel();

  @override
  void onViewModelReady(HabitsViewModel viewModel) => viewModel.initialize();
}
