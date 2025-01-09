import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/widgets/modern_card.dart';
import 'package:habitur/ui/widgets/user_avatar/user_avatar.dart';
import 'package:stacked/stacked.dart';

import 'friends_progress_list_model.dart';
import 'package:habitur/models/participant_data.dart';

class FriendsProgressList extends StackedView<FriendsProgressListModel> {
  final List<ParticipantData> participants;
  final double targetGoal;

  const FriendsProgressList({
    super.key,
    required this.participants,
    required this.targetGoal,
  });

  @override
  Widget builder(
    BuildContext context,
    FriendsProgressListModel viewModel,
    Widget? child,
  ) {
    debugPrint('${participants.length} participants in friends progress list');
    if (viewModel.isBusy) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.hasError) {
      return Center(
        child: Text(
          'Error: ${viewModel.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (viewModel.friendsProgress.isEmpty) {
      return const Center(
        child: Text(
          'No friends\' progress to display.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Friends\' Progress',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            padding: const EdgeInsets.all(0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: viewModel.friendsProgress.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final friend = viewModel.friendsProgress[index];
              return ListTile(
                leading: UserAvatar(username: friend.username),
                title: Text(
                  friend.username,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: LinearProgressIndicator(
                  value: friend.habit.currentProgress / viewModel.targetGoal,
                  backgroundColor: kDarkGray,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(kPrimaryColor),
                  minHeight: 8,
                ),
                trailing: Text(
                  '${friend.habit.currentProgress}/${viewModel.targetGoal}',
                  style: const TextStyle(color: kGray),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  FriendsProgressListModel viewModelBuilder(
    BuildContext context,
  ) =>
      FriendsProgressListModel(
        participants: participants,
        targetGoal: targetGoal,
      );
}
