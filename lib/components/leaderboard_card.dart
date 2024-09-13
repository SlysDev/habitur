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
    return Container(
      width: 500,
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: participant.user.uid ==
                Provider.of<UserLocalStorage>(context).currentUser.uid
            ? kLightPrimaryColor.withOpacity(0.5)
            : kFadedBlue.withOpacity(0.5),
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
              color: index + 1 == 1
                  ? Colors.yellow
                  : index + 1 == 2
                      ? kGray
                      : index + 1 == 3
                          ? Colors.brown
                          : kDarkGray,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '#' + (index + 1).toString(),
              style: kHeadingTextStyle.copyWith(
                  color: kBackgroundColor, fontSize: 24),
            ),
          ),
          CircleAvatar(
            backgroundImage: participant.user.profilePicture,
          ),
          Container(
            width: 120,
            child: Text(
              participant.user.username,
              style:
                  kMainDescription.copyWith(color: Colors.white, fontSize: 22),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 15),
            child: Text(
              participant.fullCompletionCount.toString(),
              style:
                  kMainDescription.copyWith(color: Colors.white, fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
