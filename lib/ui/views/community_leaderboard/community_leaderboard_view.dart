import 'package:flutter/material.dart';
import 'package:habitur/ui/widgets/navbar/navbar.dart';
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
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: SafeArea(
          child: viewModel.isBusy
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    Column(
                      children: [
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
                                return ListTile(
                                  leading: CircleAvatar(
                                    child: Text(participant.user.username[0]
                                        .toUpperCase()),
                                  ),
                                  title: Text(participant.user.username),
                                  subtitle: Text(
                                    'Completions: ${participant.currentCompletions}',
                                  ),
                                  trailing: Text(
                                    'Level ${participant.user.userLevel}',
                                    style: const TextStyle(
                                      color: kLightPrimaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
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
  CommunityLeaderboardViewModel viewModelBuilder(BuildContext context) =>
      CommunityLeaderboardViewModel();

  @override
  void onViewModelReady(CommunityLeaderboardViewModel viewModel) =>
      viewModel.initialize(challengeId: challengeId);
}
