import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/widgets/habit_card_list/habit_card_list.dart';
import 'package:habitur/ui/widgets/home_greeting_header/home_greeting_header.dart';
import 'package:habitur/ui/widgets/loading_overlay/loading_overlay.dart';
import 'package:habitur/ui/widgets/navbar/navbar.dart';
import 'package:habitur/ui/widgets/profile_drawer/profile_drawer.dart';
import 'package:habitur/ui/widgets/profile_drawer_button/profile_drawer_button.dart';
import 'package:stacked/stacked.dart';
import 'habits_viewmodel.dart';

class HabitsView extends StackedView<HabitsViewModel> {
  const HabitsView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, HabitsViewModel viewModel, Widget? child) {
    return LoadingOverlay(
      isLoading: viewModel.isBusy,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          actions: [
            Builder(
              builder: (context) => const ProfileDrawerButton(),
            ),
          ],
        ),
        backgroundColor: kBackgroundColor,
        endDrawer: const ProfileDrawer(),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: RefreshIndicator(
              displacement: 10,
              onRefresh: () async => await viewModel.refreshHabits(),
              backgroundColor: Colors.transparent,
              color: kPrimaryColor,
              strokeWidth: 2,
              child: SingleChildScrollView(
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
          ),
        ),
        bottomNavigationBar: const NavBar(
          currentPage: 'habits',
        ),
      ),
    );
  }

  @override
  HabitsViewModel viewModelBuilder(BuildContext context) {
    final viewModel = HabitsViewModel();
    viewModel.initialize();
    return viewModel;
  }
}
