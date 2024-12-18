import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/components/community_challenge_card/community_challenge_card.dart';
import 'package:habitur/constants.dart';
import 'community_habit_list_viewmodel.dart';

class CommunityHabitList extends StackedView<CommunityHabitListViewModel> {
  final bool isAdmin;
  final Future<void> Function() onRefresh;

  const CommunityHabitList({
    super.key,
    this.isAdmin = false,
    required this.onRefresh,
  });

  @override
  Widget builder(
    BuildContext context,
    CommunityHabitListViewModel viewModel,
    Widget? child,
  ) {
    if (viewModel.isBusy) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: kLightRedAccent),
            const SizedBox(height: 16),
            Text(
              'Failed to load challenges\n${viewModel.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: kLightRedAccent),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.refreshChallenges,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (viewModel.challenges.isEmpty) {
      return const Center(
        child: Text(
          'No active challenges',
          style: TextStyle(fontSize: 16, color: kGray),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.refreshChallenges,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: viewModel.challenges.length,
        itemBuilder: (context, index) {
          final challenge = viewModel.challenges[index];
          return Column(
            children: [
              CommunityChallengeCard(
                challenge: challenge,
                isAdmin: viewModel.isAdmin,
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  @override
  CommunityHabitListViewModel viewModelBuilder(BuildContext context) =>
      CommunityHabitListViewModel();

  @override
  void onViewModelReady(CommunityHabitListViewModel viewModel) =>
      viewModel.initialize(isAdmin);
}
