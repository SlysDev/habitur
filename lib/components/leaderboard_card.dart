import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/providers/user_data.dart';
import 'package:provider/provider.dart';

class LeaderboardCard extends StatelessWidget {
  final ParticipantData participant;

  LeaderboardCard({
    Key? key,
    required this.participant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: participant.user == Provider.of<UserData>(context).currentUser
            ? kLightPrimaryColor.withOpacity(0.5)
            : kFadedBlue.withOpacity(0.5),
      ),
      child: Row(
        children: [
          SizedBox(width: 20),
          Text(
            participant.completionCount.toString(),
            style: kHeadingTextStyle.copyWith(
                color: kLightPrimaryColor, fontSize: 25),
          ),
          SizedBox(width: 20),
          CircleAvatar(
            backgroundImage: participant.user.profilePicture,
          ),
          SizedBox(width: 20),
          Text(
            participant.user.username,
            style: kMainDescription.copyWith(color: Colors.white, fontSize: 22),
          ),
          SizedBox(width: 20),
        ],
      ),
    );
  }
}
