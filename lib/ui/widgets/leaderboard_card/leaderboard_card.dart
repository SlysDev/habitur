import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/ui/common/ui_helpers.dart';
import 'package:habitur/ui/widgets/user_avatar/user_avatar.dart';
import 'package:stacked/stacked.dart';

import 'leaderboard_card_model.dart';

class LeaderboardCard extends StackedView<LeaderboardCardModel> {
  final ParticipantData participant;
  final int rank;

  const LeaderboardCard({
    Key? key,
    required this.participant,
    required this.rank,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LeaderboardCardModel viewModel,
    Widget? child,
  ) {
    return GestureDetector(
      onTap: viewModel.showProfileDialog,
      child: Card(
        elevation: 4,
        color: viewModel.isFriend
            ? kFadedGreen.withOpacity(0.25)
            : viewModel.isCurrentUser
                ? kGray.withOpacity(0.4)
                : kFadedBlue.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: kPrimaryColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Rank number
              Text(
                '#$rank',
                style: TextStyle(
                  color: kGray,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 16),
              // User Avatar
              UserAvatar(
                username: participant.username,
                size: 1,
              ),
              const SizedBox(width: 12),
              // User Info
              FutureBuilder(
                  future: viewModel.getUserById(participant.userId),
                  builder: (context, snapshot) {
                    return Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            viewModel.isCurrentUser
                                ? 'You'
                                : participant.username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          snapshot.connectionState == ConnectionState.waiting
                              ? const CircularProgressIndicator()
                              : Text(
                                  'Level ${snapshot.data?.userLevel ?? 1}',
                                  style: TextStyle(
                                    color: kGray,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ],
                      ),
                    );
                  }),
              if (viewModel.isFriend)
                const Icon(Icons.group, color: kFadedGreen),
              horizontalSpaceMediumNew,
              // Completion Count
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: kBackgroundColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${participant.habit.totalProgress}',
                      style: const TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onViewModelReady(LeaderboardCardModel viewModel) {
    viewModel.initialize(participant);
  }

  @override
  LeaderboardCardModel viewModelBuilder(BuildContext context) =>
      LeaderboardCardModel();
}
