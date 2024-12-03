import 'package:flutter/material.dart';
import 'package:habitur/ui/widgets/leaderboard_card/leaderboard_card.dart';
import 'package:habitur/ui/widgets/navbar/navbar.dart';
import 'package:habitur/ui/widgets/user_avatar/user_avatar.dart';
import 'package:stacked/stacked.dart';
import '../../../constants.dart';
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
    debugPrint('Building leaderboard view...');
    debugPrint('Challenge id: $challengeId');
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: SafeArea(
          child: viewModel.isBusy
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              padding: EdgeInsets.all(16),
                              icon: Icon(Icons.arrow_back),
                              onPressed: () {
                                viewModel.navigateBack();
                              },
                            ),
                          ],
                        ),
                        Text(
                          viewModel.currentChallenge?.habit.title ??
                              'No Active Challenge',
                          style: kTitleTextStyle.copyWith(
                              color: kLightPrimaryColor),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          viewModel.currentChallenge?.description ??
                              'Join a challenge to get started!',
                          style: kMainDescription,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        if (viewModel.currentChallenge != null) ...[
                          RoundedProgressBar(
                            progress: viewModel.totalProgress,
                            lineHeight: 40,
                            color: kPrimaryColor,
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${viewModel.currentChallenge!.currentFullCompletions} / ${viewModel.currentChallenge!.requiredFullCompletions}',
                                style: kMainDescription.copyWith(
                                  color: Colors.white,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.people, size: 24),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Expanded(
                            child: ListView.separated(
                              itemCount: viewModel.participants.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final participant =
                                    viewModel.participants[index];
                                return LeaderboardCard(
                                    participant: viewModel.participants[index],
                                    rank: index + 1);
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  CommunityLeaderboardViewModel viewModelBuilder(BuildContext context) {
    final viewModel = CommunityLeaderboardViewModel();
    debugPrint('beginning to init view model w/ challenge id: $challengeId');
    viewModel.initialize(challengeId: challengeId);
    return viewModel;
  }
}
