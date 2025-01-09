import 'dart:math';

import 'package:flutter/material.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/ui/common/ui_helpers.dart';
import 'package:habitur/ui/widgets/friends_progress_list/friends_progress_list.dart';
import 'package:habitur/ui/widgets/leaderboard_card/leaderboard_card.dart';
import 'package:habitur/ui/widgets/loading_overlay/loading_overlay.dart';
import 'package:habitur/ui/widgets/modern_card.dart';
import 'package:habitur/ui/widgets/navbar/navbar.dart';
import 'package:habitur/ui/widgets/primary_button.dart';
import 'package:habitur/ui/widgets/static_card.dart';
import 'package:habitur/ui/widgets/user_avatar/user_avatar.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/constants.dart';
import 'package:confetti/confetti.dart';
import '../../widgets/rounded_progress_bar.dart';
import 'community_leaderboard_viewmodel.dart';

class CommunityLeaderboardView
    extends StackedView<CommunityLeaderboardViewModel> {
  final String? challengeId;

  const CommunityLeaderboardView({
    Key? key,
    this.challengeId,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    CommunityLeaderboardViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          LoadingOverlay(
            isLoading: viewModel.isBusy || viewModel.currentChallenge == null,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context, viewModel),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: ConfettiWidget(
                            confettiController: viewModel.controller,
                            blastDirectionality:
                                BlastDirectionality.directional,
                            blastDirection: 3 * pi / 2,
                            emissionFrequency: 0,
                            numberOfParticles: 25,
                            gravity: 0.1,
                            maxBlastForce: 20,
                            minBlastForce: 10,
                          ),
                        ),
                        _buildCurrentUserProgress(context, viewModel),
                        verticalSpaceMedium,
                        _buildFriendsProgressList(context, viewModel),
                        verticalSpaceMedium,
                        _buildLeaderboardSection(context, viewModel),
                        SizedBox(height: screenHeight(context) / 6),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 125,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: PrimaryButton(
        isDisabled:
            viewModel.currentUserParticipantData?.habit.currentProgress ==
                viewModel.currentChallenge?.targetGoal,
        text: 'Complete',
        onPressed: viewModel.incrementProgress,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildAppBar(
      BuildContext context, CommunityLeaderboardViewModel viewModel) {
    return SliverAppBar(
      surfaceTintColor: kDarkGray,
      backgroundColor: kBackgroundColor,
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          viewModel.currentChallenge?.title ?? '...',
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
                  Icons.emoji_events,
                  color: kPrimaryColor,
                  size: 48,
                ),
                verticalSpaceMediumNew,
                Text(
                  viewModel.currentChallenge?.description ?? '',
                  style: kMainDescription,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFriendsProgressList(
      BuildContext context, CommunityLeaderboardViewModel viewModel) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Friends Progress',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<ParticipantData>>(
            future: viewModel.friendsProgress,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(
                    child: Text('Error loading friends progress'));
              }
              final friendsProgress = snapshot.data ?? [];
              return ListView.separated(
                padding: const EdgeInsets.all(0),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: friendsProgress.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final participant = friendsProgress[index];
                  return LeaderboardCard(participant: participant, rank: index + 1);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardSection(
      BuildContext context, CommunityLeaderboardViewModel viewModel) {
    return Column(
      children: [
        ModernCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Leaderboard',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 40),
              Center(
                child: RoundedProgressBar(
                  progress: viewModel.totalProgress,
                  lineHeight: 40,
                  width: screenWidth(context) / 1.5,
                  color: kPrimaryColor,
                ),
              ),
              verticalSpaceMediumNew,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${viewModel.currentChallenge?.currentFullCompletions ?? 0} / ${viewModel.currentChallenge?.requiredFullCompletions ?? 1}',
                    style: kSubDescription,
                  ),
                  horizontalSpaceSmallNew,
                  const Icon(Icons.people, size: 24, color: kGray),
                ],
              ),
              verticalSpaceMediumNew,
              ListView.separated(
                padding: const EdgeInsets.all(0),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: viewModel.sortedParticipants.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final participant = viewModel.sortedParticipants[index];
                  return LeaderboardCard(
                    participant: participant,
                    rank: index + 1,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentUserProgress(
      BuildContext context, CommunityLeaderboardViewModel viewModel) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Progress',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value:
                (viewModel.currentUserParticipantData?.habit.currentProgress ??
                        0) /
                    (viewModel.currentChallenge?.targetGoal ?? 1),
            backgroundColor: kDarkGray,
            borderRadius: BorderRadius.circular(15),
            valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryColor),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            '${viewModel.currentUserParticipantData?.habit.currentProgress ?? 0}/${viewModel.currentChallenge?.targetGoal ?? 1} completions',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: kGray,
                ),
          ),
        ],
      ),
    );
  }

  @override
  CommunityLeaderboardViewModel viewModelBuilder(BuildContext context) {
    final viewModel = CommunityLeaderboardViewModel();
    viewModel.initialize(challengeId: challengeId);
    return viewModel;
  }
}
