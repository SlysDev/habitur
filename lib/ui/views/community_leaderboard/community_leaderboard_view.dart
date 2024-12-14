import 'package:flutter/material.dart';
import 'package:habitur/ui/widgets/leaderboard_card/leaderboard_card.dart';
import 'package:habitur/ui/widgets/loading_overlay/loading_overlay.dart';
import 'package:habitur/ui/widgets/navbar/navbar.dart';
import 'package:habitur/ui/widgets/primary_button.dart';
import 'package:habitur/ui/widgets/user_avatar/user_avatar.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/constants.dart';
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
    return LoadingOverlay(
      isLoading: viewModel.isBusy || viewModel.currentChallenge == null,
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: Container(
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
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
                        viewModel.currentChallenge?.title ??
                            'Community Challenge',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        viewModel.currentChallenge?.description ?? '',
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
                              final participant = viewModel.participants[index];
                              return Container(
                                margin:
                                    index == viewModel.participants.length - 1
                                        ? EdgeInsets.only(bottom: 75)
                                        : EdgeInsets.only(bottom: 0),
                                child: LeaderboardCard(
                                    participant: viewModel.participants[index],
                                    rank: index + 1),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: PrimaryButton(
            text: 'Complete', onPressed: viewModel.incrementProgress),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
