import 'package:flutter/material.dart';
import 'package:habitur/ui/widgets/habit_card_list/habit_card_list.dart';
import 'package:habitur/ui/widgets/home_greeting_header/home_greeting_header.dart';
import 'package:habitur/ui/widgets/navbar/navbar.dart';
import 'package:habitur/ui/widgets/profile_drawer/profile_drawer.dart';
import 'package:stacked/stacked.dart';
import 'habits_viewmodel.dart';

class HabitsView extends StackedView<HabitsViewModel> {
  const HabitsView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, HabitsViewModel viewModel, Widget? child) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: const ProfileDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              HomeGreetingHeader(),
              HabitCardList(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBar(
        currentPage: 'habits',
      ),
    );
  }

  @override
  HabitsViewModel viewModelBuilder(BuildContext context) => HabitsViewModel();

  @override
  void onViewModelReady(HabitsViewModel viewModel) => viewModel.initialize();
}
