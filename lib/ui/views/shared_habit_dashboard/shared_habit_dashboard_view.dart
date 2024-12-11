import 'package:flutter/material.dart';
import 'package:habitur/models/shared_habit.dart';
import 'package:habitur/ui/common/app_colors.dart';
import 'package:habitur/ui/widgets/user_avatar/user_avatar.dart';
import 'package:stacked/stacked.dart';
import 'shared_habit_dashboard_viewmodel.dart';

class SharedHabitDashboardView
    extends StackedView<SharedHabitDashboardViewModel> {
  final SharedHabit sharedHabit;

  const SharedHabitDashboardView({
    Key? key,
    required this.sharedHabit,
  }) : super(key: key);

  @override
  void onViewModelReady(SharedHabitDashboardViewModel viewModel) {
    viewModel.init(sharedHabit);
  }

  @override
  Widget builder(
    BuildContext context,
    SharedHabitDashboardViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: viewModel.isBusy
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  _buildAppBar(context, viewModel),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProgressSection(context, viewModel),
                          const SizedBox(height: 24),
                          _buildParticipantsSection(context, viewModel),
                          const SizedBox(height: 24),
                          _buildStatsSection(context, viewModel),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: viewModel.incrementProgress,
        backgroundColor: kcAccentColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAppBar(
      BuildContext context, SharedHabitDashboardViewModel viewModel) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          viewModel.sharedHabit.title,
          style: const TextStyle(
            color: kcPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                kcFadedBlue,
                kcFadedBlue.withOpacity(0.7),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: kcAccentColor,
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  'Group Streak: ${viewModel.groupStreak} days',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: kcPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(
      BuildContext context, SharedHabitDashboardViewModel viewModel) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: kcPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: viewModel.currentProgress / viewModel.targetGoal,
              backgroundColor: kcLightGrey,
              valueColor: const AlwaysStoppedAnimation<Color>(kcAccentColor),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              '${viewModel.currentProgress}/${viewModel.targetGoal} completions',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: kcMediumGrey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsSection(
      BuildContext context, SharedHabitDashboardViewModel viewModel) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Participants',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: kcPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: viewModel.inviteParticipants,
                  child: const Text('Invite'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 250, // Adjust this value as needed
                minHeight: 0,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: viewModel.participants.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  color: kcFadedBlue,
                ),
                itemBuilder: (context, index) {
                  final participant = viewModel.participants[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        UserAvatar(
                          username: participant.user.username,
                          size: 40,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                participant.user.username,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${participant.currentCompletions}/${viewModel.targetGoal} today',
                                style: const TextStyle(
                                  color: kcMediumGrey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '🔥 ${participant.fullCompletionCount}',
                          style: const TextStyle(
                            color: kcAccentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(
      BuildContext context, SharedHabitDashboardViewModel viewModel) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Group Stats',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: kcPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  'Total Completions',
                  viewModel.totalGroupCompletions.toString(),
                ),
                _buildStatItem(
                  context,
                  'Highest Streak',
                  viewModel.highestGroupStreak.toString(),
                ),
                _buildStatItem(
                  context,
                  'Active Days',
                  viewModel.totalActiveDays.toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: kcAccentColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: kcMediumGrey,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  SharedHabitDashboardViewModel viewModelBuilder(BuildContext context) {
    final viewModel = SharedHabitDashboardViewModel();
    viewModel.init(sharedHabit);
    return viewModel;
  }
}
