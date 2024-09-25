import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:provider/provider.dart';

class LeaderboardCard extends StatelessWidget {
  final ParticipantData participant;
  final int index;

  LeaderboardCard({
    Key? key,
    required this.participant,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = participant.user.uid ==
        Provider.of<UserLocalStorage>(context).currentUser.uid;

    return Container(
      width: double.infinity, // Ensure the card uses available width
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isCurrentUser
            ? kLightPrimaryColor.withOpacity(0.5)
            : kFadedBlue.withOpacity(0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            alignment: Alignment.center,
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(2),
            margin: const EdgeInsets.only(left: 5),
            decoration: BoxDecoration(
              color: _getRankColor(index + 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '#' + (index + 1).toString(),
              style: kHeadingTextStyle.copyWith(
                color: kBackgroundColor,
                fontSize: 24,
              ),
            ),
          ),
          const SizedBox(width: 15),
          CircleAvatar(
            backgroundImage: participant.user.profilePicture,
            radius: 30,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.user.username,
                  style: kSubHeadingTextStyle.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                  overflow: TextOverflow.ellipsis, // Truncates long names
                  maxLines: 1,
                ),
                const SizedBox(height: 5),
                Text(
                  '${participant.fullCompletionCount} completions',
                  style: kMainDescription.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get color based on rank
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.yellow;
      case 2:
        return kGray;
      case 3:
        return Colors.brown;
      default:
        return kDarkGray;
    }
  }
}
