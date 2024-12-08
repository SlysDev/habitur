import 'package:flutter/material.dart';
import 'package:habitur/ui/common/app_colors.dart';
import 'package:habitur/ui/widgets/shared_habit_card/shared_habit_card.dart';
import 'package:stacked/stacked.dart';
import 'shared_habits_viewmodel.dart';

class SharedHabitsView extends StackedView<SharedHabitsViewModel> {
  const SharedHabitsView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    SharedHabitsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Shared Habits',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: kcPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: viewModel.isBusy
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.sharedHabits.isEmpty
                        ? _buildEmptyState(context)
                        : ListView.builder(
                            itemCount: viewModel.sharedHabits.length,
                            itemBuilder: (context, index) {
                              final sharedHabit = viewModel.sharedHabits[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: SharedHabitCard(
                                  sharedHabit: sharedHabit,
                                  onTap: () => viewModel
                                      .navigateToSharedHabitDashboard(sharedHabit),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: viewModel.navigateToCreateSharedHabit,
        backgroundColor: kcAccentColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_outlined,
            size: 64,
            color: kcPrimaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No shared habits yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: kcPrimaryColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a shared habit to start building habits together!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: kcMediumGrey,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: kcAccentColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: const Text('Create Shared Habit'),
          ),
        ],
      ),
    );
  }

  @override
  SharedHabitsViewModel viewModelBuilder(BuildContext context) =>
      SharedHabitsViewModel();
}
