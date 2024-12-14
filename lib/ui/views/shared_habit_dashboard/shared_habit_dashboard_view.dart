import 'package:flutter/material.dart';
import 'package:habitur/models/shared_habit.dart';
import 'package:habitur/ui/common/ui_helpers.dart';
import 'package:habitur/ui/widgets/single-stat-card.dart';
import 'package:habitur/ui/widgets/user_avatar/user_avatar.dart';
import 'package:stacked/stacked.dart';
import 'shared_habit_dashboard_viewmodel.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/widgets/modern_card.dart';

class SharedHabitDashboardView
    extends StackedView<SharedHabitDashboardViewModel> {
  final SharedHabit sharedHabit;

  const SharedHabitDashboardView({
    Key? key,
    required this.sharedHabit,
  }) : super(key: key);

  @override
  void onViewModelReady(SharedHabitDashboardViewModel viewModel) {
    viewModel.init(sharedHabit.id.toString());
  }

  @override
  Widget builder(
    BuildContext context,
    SharedHabitDashboardViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: viewModel.incrementProgress,
      //   backgroundColor: kPrimaryColor,
      //   child: const Icon(Icons.add),
      // ),
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
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          color: kBackgroundColor,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: kLightRedAccent,
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  'Group Streak: ${viewModel.groupStreak} days',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
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
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Progress',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: viewModel.currentProgress / viewModel.targetGoal,
            backgroundColor: kDarkGray,
            borderRadius: BorderRadius.circular(15),
            valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryColor),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            '${viewModel.currentProgress}/${viewModel.targetGoal} completions',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: kGray,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsSection(
      BuildContext context, SharedHabitDashboardViewModel viewModel) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Participants',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: viewModel.inviteParticipants,
                child: const Text(
                  'Invite',
                  style: TextStyle(color: kPrimaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 250,
              minHeight: 0,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: viewModel.participants.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                color: kDarkGray,
              ),
              itemBuilder: (context, index) {
                final participant = viewModel.participants[index];
                return FutureBuilder(
                    future: viewModel.getParticipantUsername(participant),
                    builder: (context, snapshot) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            snapshot.connectionState == ConnectionState.waiting
                                ? const CircularProgressIndicator()
                                : UserAvatar(
                                    username: snapshot.data ?? '...',
                                  ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  snapshot.connectionState ==
                                          ConnectionState.waiting
                                      ? const CircularProgressIndicator()
                                      : Text(
                                          snapshot.data ?? '...',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                  Text(
                                    '${participant.habit.currentProgress}/${viewModel.targetGoal} today',
                                    style: const TextStyle(
                                      color: kGray,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '︎✅ ${participant.habit.totalProgress}',
                              style: const TextStyle(
                                color: kLightGreenAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
      BuildContext context, SharedHabitDashboardViewModel viewModel) {
    return Column(
      children: [
        ModernCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Group Stats',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
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
        verticalSpaceLarge,
        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 30,
          mainAxisSpacing: 30,
          shrinkWrap: true,
          children: [
            SingleStatCard(
              statText: viewModel.getCurrentUserHabit().streak.toString() ?? '',
              statDescription: 'Streak',
              fontSize: 40,
              color: Colors.orange.shade300,
            ),
            SingleStatCard(
              statText:
                  viewModel.getCurrentUserHabit().highestStreak.toString() ??
                      '',
              statDescription: 'Highest Streak',
              fontSize: 40,
              color: Colors.white,
            ),
            // TODO: Implement these more complex stats into viewmodel
            // SingleStatCard(
            //   statText: _statsCalculationService
            //       .calculateAverageValueForStat(
            //           viewModel.getCurrentUserHabit().stats, 'confidenceLevel')
            //       .toStringAsFixed(1),
            //   statDescription: 'Average Weekly Completions',
            //   fontSize: 40,
            //   color: Colors.green.shade300,
            // ),
            // SingleStatCard(
            //   statText: (viewModel.getCurrentUserHabit().stats?.length ?? 0) < 7
            //       ? '${(_statsCalculationService.calculateConsistencyFactor(viewModel.getCurrentUserHabit().stats, viewModel.getCurrentUserHabit().targetGoal, period: viewModel.getCurrentUserHabit().stats.length) * 100).toStringAsFixed(0)}%'
            //       : '${(_statsCalculationService.calculateConsistencyFactor(viewModel.getCurrentUserHabit().stats, viewModel.getCurrentUserHabit().targetGoal) * 100).toStringAsFixed(0)}%',
            //   statDescription: '7-day Consistency',
            //   fontSize: 40,
            //   color: Colors.teal.shade300,
            // ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: kGray,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  SharedHabitDashboardViewModel viewModelBuilder(BuildContext context) {
    final viewModel = SharedHabitDashboardViewModel();
    viewModel.init(sharedHabit.id.toString());
    return viewModel;
  }
}
