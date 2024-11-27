import 'package:flutter/material.dart';
import 'package:habitur/ui/views/social_feed/social_feed.dart';
import 'package:habitur/ui/widgets/habit_card_list/habit_card_list.dart';
import 'package:habitur/ui/widgets/home_greeting_header/home_greeting_header.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/constants.dart';
import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, HomeViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Habitur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: viewModel.navigateToSettings,
          ),
        ],
      ),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeGreetingHeader(),
                    // TODO: Convert home greeting header to a stacked widget
                    _buildUserStats(viewModel),
                    const SizedBox(height: 24),
                    Expanded(
                      child: SocialFeed(
                        onRefresh: () async {
                          await viewModel.refreshData();
                        },
                      ),
                    ),
                    _buildHabitsList(viewModel),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: viewModel.navigateToAddHabit,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: viewModel.currentIndex,
        onTap: viewModel.setIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Community',
          ),
        ],
      ),
    );
  }

  Widget _buildUserStats(HomeViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${viewModel.userName}!',
              style: kTitleTextStyle,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Habits', viewModel.totalHabits.toString()),
                _buildStatItem('Streak', viewModel.currentStreak.toString()),
                _buildStatItem('Level', viewModel.userLevel.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: kTitleTextStyle.copyWith(fontSize: 24),
        ),
        Text(
          label,
          style: kSubDescription,
        ),
      ],
    );
  }

  Widget _buildHabitsList(HomeViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Habits',
          style: kTitleTextStyle,
        ),
        const SizedBox(height: 16),
        HabitCardList(),
        // TODO: Convert habit card list to a stacked widget
        // ListView.builder(
        //   shrinkWrap: true,
        //   physics: const NeverScrollableScrollPhysics(),
        //   itemCount: viewModel.habits.length,
        //   itemBuilder: (context, index) {
        //     final habit = viewModel.habits[index];
        //     return Card(
        //       child: ListTile(
        //         title: Text(habit.title),
        //         subtitle: Text(habit.description),
        //         trailing: IconButton(
        //           icon: const Icon(Icons.check_circle_outline),
        //           onPressed: () => viewModel.completeHabit(habit.id),
        //         ),
        //         onTap: () => viewModel.navigateToEditHabit(habit.id),
        //       ),
        //     );
        //   },
        // ),
      ],
    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();
}
