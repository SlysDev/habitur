import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habitur/models/shared_habit.dart';
import 'package:habitur/ui/common/ui_helpers.dart';
import 'package:habitur/ui/widgets/habit_heat_map/habit_heat_map.dart';
import 'package:habitur/ui/widgets/heat_map/heat_map.dart';
import 'package:habitur/ui/widgets/loading_overlay/loading_overlay.dart';
import 'package:habitur/ui/widgets/multi_stat_line_graph/multi_stat_line_graph.dart';
import 'package:habitur/ui/widgets/single_stat_card.dart';
import 'package:habitur/ui/widgets/user_avatar/user_avatar.dart';
import 'package:stacked/stacked.dart';
import 'shared_habit_dashboard_viewmodel.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/widgets/modern_card.dart';
import 'package:dots_indicator/dots_indicator.dart';

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
      backgroundColor: kBackgroundColor,
      body: LoadingOverlay(
        isLoading: viewModel.isBusy,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context, viewModel),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressSection(context, viewModel),
                    verticalSpaceMedium,
                    _buildParticipantsSection(context, viewModel),
                    verticalSpaceMedium,
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
      surfaceTintColor: kDarkGray,
      backgroundColor: kBackgroundColor,
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          viewModel.sharedHabitStreamData?.title ?? '...',
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
                  Icons.local_fire_department_rounded,
                  color: kOrangeAccent,
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
              // TextButton(
              //   onPressed: viewModel.inviteParticipants,
              //   child: const Text(
              //     'Invite',
              //     style: TextStyle(color: kPrimaryColor),
              //   ),
              // ),
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
              itemCount:
                  viewModel.sortedParticipants.length, // Use sortedParticipants
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                color: kFadedBlue,
              ),
              itemBuilder: (context, index) {
                final participant = viewModel.sortedParticipantsStreamData[
                    index]; // Use sortedParticipants
                return FutureBuilder(
                    future: viewModel.getParticipantUsername(participant),
                    builder: (context, snapshot) {
                      return Slidable(
                        enabled: viewModel.isCurrentUserAuthor &&
                            !(viewModel.isParticipantCurrentUser(participant)),
                        startActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              autoClose: true,
                              onPressed: (context) async {
                                await viewModel.removeParticipant(participant);
                              },
                              backgroundColor: kLightRedAccent,
                              icon: Icons.person_remove,
                              label: 'Remove',
                            ),
                          ],
                        ),
                        child: Opacity(
                          opacity: participant.habit.isCompleted ? 0.80 : 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16),
                            decoration: BoxDecoration(
                              color: participant.habit.isCompleted
                                  ? kLightGreenAccent.withOpacity(0.3)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                snapshot.connectionState ==
                                        ConnectionState.waiting
                                    ? const CustomShimmerLoading.circular(
                                        width: 40, height: 40)
                                    : UserAvatar(
                                        username: snapshot.data ?? '...',
                                      ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      snapshot.connectionState ==
                                              ConnectionState.waiting
                                          ? const CustomShimmerLoading
                                              .rectangular(
                                              height: 20, width: 100)
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
                                Row(
                                  children: [
                                    // Streak info
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: kOrangeAccent.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.local_fire_department_rounded,
                                            color: kOrangeAccent,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${participant.habit.streak}',
                                            style: const TextStyle(
                                              color: kOrangeAccent,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Total completions
                                    Text(
                                      '︎✅ ${participant.habit.totalProgress}',
                                      style: const TextStyle(
                                        color: kLightGreenAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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
                ],
              ),
              verticalSpaceMedium,
              HabitHeatMap(data: viewModel.aggregatedStats),
            ],
          ),
        ),
        verticalSpaceMedium,
        _buildParticipantStatsCarousel(context, viewModel),
        verticalSpaceMedium,
        ModernCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Stats',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              verticalSpaceMedium,
              MultiStatLineGraph(
                data: viewModel.getUserHabit().stats,
                showStatTitle: true,
                height: 250,
                showChangeIndicator: true,
              ),
              verticalSpaceMedium,
              HabitHeatMap(data: viewModel.getUserHabit().stats),
              verticalSpaceMedium,
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                shrinkWrap: true,
                children: [
                  SingleStatCard(
                    statText: viewModel.getUserHabit().streak.toString() ?? '',
                    statDescription: 'Streak',
                    fontSize: screenWidth(context) / 12,
                    color: Colors.orange.shade300,
                  ),
                  SingleStatCard(
                    statText:
                        viewModel.getUserHabit().highestStreak.toString() ?? '',
                    statDescription: 'Highest Streak',
                    fontSize: screenWidth(context) / 12,
                    color: Colors.white,
                  ),
                  SingleStatCard(
                    statText: viewModel
                        .getAverageWeeklyCompletions()
                        .toStringAsFixed(1),
                    statDescription: 'Average Weekly Completions',
                    fontSize: screenWidth(context) / 12,
                    color: Colors.green.shade300,
                  ),
                  SingleStatCard(
                    statText: (viewModel.getAverageConsistency() * 100)
                            .toStringAsFixed(0) +
                        '%',
                    statDescription: '7-day Consistency',
                    fontSize: screenWidth(context) / 12,
                    color: Colors.teal.shade300,
                  ),
                ],
              ),
            ],
          ),
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
    viewModel.init(sharedHabit);
    return viewModel;
  }
}

class CustomShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  const CustomShimmerLoading.rectangular({
    Key? key,
    this.width = double.infinity,
    required this.height,
  })  : shapeBorder = const RoundedRectangleBorder(),
        super(key: key);

  const CustomShimmerLoading.circular({
    Key? key,
    required this.width,
    required this.height,
  })  : shapeBorder = const CircleBorder(),
        super(key: key);

  @override
  _CustomShimmerLoadingState createState() => _CustomShimmerLoadingState();
}

class _CustomShimmerLoadingState extends State<CustomShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: ShapeDecoration(
            shape: widget.shapeBorder,
            gradient: LinearGradient(
              colors: [
                kDarkGray.withOpacity(0.3),
                kDarkGray.withOpacity(0.1),
                kDarkGray.withOpacity(0.3)
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3
              ],
              begin: Alignment(-1.0, -0.3),
              end: Alignment(1.0, 0.3),
            ),
          ),
        );
      },
    );
  }
}

Widget _buildParticipantStatsCarousel(
    BuildContext context, SharedHabitDashboardViewModel viewModel) {
  return ModernCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Participant Stats',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        verticalSpaceMedium,
        SizedBox(
          height: 475,
          child: PageView.builder(
            itemCount: viewModel.sortedParticipantsStreamData.length,
            onPageChanged: viewModel.setCurrentCarouselIndex,
            itemBuilder: (context, index) {
              final participant = viewModel.sortedParticipantsStreamData[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    FutureBuilder<String>(
                      future: viewModel.getParticipantUsername(participant),
                      builder: (context, snapshot) {
                        return Column(
                          children: [
                            UserAvatar(
                              username: snapshot.data ?? '',
                              size: 2,
                            ),
                            verticalSpaceSmall,
                            Text(
                              snapshot.data ?? '...',
                              style: kHeadingTextStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    verticalSpaceMedium,
                    GridView.count(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: [
                        SingleStatCard(
                          statText: participant.habit.streak.toString(),
                          statDescription: 'Current Streak',
                          fontSize: 32,
                          color: Colors.orange.shade300,
                        ),
                        SingleStatCard(
                          statText: participant.habit.highestStreak.toString(),
                          statDescription: 'Highest Streak',
                          fontSize: 32,
                          color: Colors.white,
                        ),
                        SingleStatCard(
                          statText: viewModel
                              .getAverageWeeklyCompletions(
                                  userId: participant.userId)
                              .toStringAsFixed(1),
                          statDescription: 'Weekly Average',
                          fontSize: 32,
                          color: Colors.green.shade300,
                        ),
                        SingleStatCard(
                          statText:
                              '${(viewModel.getAverageConsistency(userId: participant.userId) * 100).toStringAsFixed(0)}%',
                          statDescription: 'Consistency',
                          fontSize: 30,
                          color: Colors.teal.shade300,
                        ),
                      ],
                    ),
                    verticalSpaceMedium,
                  ],
                ),
              );
            },
          ),
        ),
        Center(
          child: DotsIndicator(
            dotsCount: viewModel.sortedParticipants.length,
            position: viewModel.currentCarouselIndex,
            decorator: DotsDecorator(
              activeColor: kPrimaryColor,
              size: const Size(8.0, 8.0),
              activeSize: const Size(16.0, 8.0),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
