import 'package:flutter/material.dart';
import 'package:habitur/components/profile_dialog.dart';
import 'package:habitur/components/user_avatar.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/modules/friends_manager.dart';
import 'package:habitur/data/remote/friends_database.dart';
import 'package:provider/provider.dart';

class LeaderboardCard extends StatelessWidget {
  final ParticipantData participant;
  final int index;

  const LeaderboardCard({
    Key? key,
    required this.participant,
    required this.index,
  }) : super(key: key);

  void _showProfileDialog(BuildContext context, ParticipantData participant) {
    debugPrint('LeaderboardCard: Opening profile dialog for user:');
    debugPrint('  - Username: ${participant.user.username}');
    debugPrint('  - UID: ${participant.user.uid}');
    debugPrint('  - User object: ${participant.user.toMap()}');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ProfileDialog(
          uid: participant.user.uid,
          isFriendProfile: true,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserLocalStorage>(context).currentUser;
    final isCurrentUser = participant.user.uid == currentUser.uid;
    final friendsManager = FriendsManager();

    debugPrint('LeaderboardCard: Building card for user:');
    debugPrint('  - Username: ${participant.user.username}');
    debugPrint('  - UID: ${participant.user.uid}');
    debugPrint('  - Is current user: $isCurrentUser');

    return StreamBuilder<List<String>>(
      stream: friendsManager.friendsStream,
      builder: (context, snapshot) {
        final isFriend =
            snapshot.hasData && snapshot.data!.contains(participant.user.uid);

        debugPrint('  - Friends stream data: ${snapshot.data}');
        debugPrint('  - Is friend: $isFriend');

        return GestureDetector(
          onTap: () {
            _showProfileDialog(context, participant);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isCurrentUser
                  ? kLightPrimaryColor.withOpacity(0.5)
                  : isFriend
                      ? Colors.green.withOpacity(0.1)
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
                // User Avatar
                UserAvatar(
                  username: participant.user.username,
                  size: 40.0,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              participant.user.username,
                              style: kSubHeadingTextStyle.copyWith(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                              overflow:
                                  TextOverflow.ellipsis, // Truncates long names
                              maxLines: 1,
                            ),
                          ),
                          if (isFriend)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Icon(
                                Icons.people,
                                color: Colors.green,
                                size: 20,
                              ),
                            ),
                        ],
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
          ),
        );
      },
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
