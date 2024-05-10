import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/community_challenge.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/components/leaderboard_card.dart';
import 'package:habitur/models/user.dart';
import 'package:percent_indicator/circular_percent_indicator.dart'; // Import your LeaderboardCard

class CommunityLeaderboardScreen extends StatelessWidget {
  CommunityChallenge challenge;
  CommunityLeaderboardScreen({
    super.key,
    required this.challenge,
  });
  @override
  Widget build(BuildContext context) {
    double totalProgress =
        challenge.currentFullCompletions / challenge.requiredFullCompletions;
    challenge.loadParticipants([
      ParticipantData(
          user: User(
            username: 'test',
            profilePicture: AssetImage('assets/images/logo.png'),
            uid: 'test',
            email: 'test',
            userXP: 0,
            userLevel: 0,
          ),
          completionCount: 0),
      ParticipantData(
          user: User(
            username: 'test4',
            profilePicture: AssetImage('assets/images/logo.png'),
            uid: 'test',
            email: 'test',
            userXP: 0,
            userLevel: 0,
          ),
          completionCount: 2)
    ]);
    List<ParticipantData> participants = challenge.getSortedParticipantData();
    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: SafeArea(
          child: Column(
            children: [
              Text(
                'Leaderboard',
                style: kHeadingTextStyle.copyWith(color: Colors.white),
              ),
              SizedBox(height: 40),
              Text(challenge.habit.title,
                  style: kTitleTextStyle.copyWith(color: kLightPrimaryColor)),
              SizedBox(height: 40),
              CircularPercentIndicator(
                animation: true,
                animationDuration: 500,
                animateFromLastPercent: true,
                curve: Curves.ease,
                radius: 70,
                percent: totalProgress,
                progressColor: kPrimaryColor,
                backgroundColor: kFadedBlue.withOpacity(0.4),
                circularStrokeCap: CircularStrokeCap.round,
                lineWidth: 15,
                center: Text(
                  "${(totalProgress * 100).toStringAsFixed(0)}%",
                  style: kHeadingTextStyle.copyWith(
                      color: Colors.white, fontSize: 28),
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    challenge.currentFullCompletions.toString(),
                    style: kMainDescription.copyWith(
                        color: Colors.white, fontSize: 22),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.people,
                    size: 24,
                  ),
                ],
              ),
              SizedBox(height: 30),
              Expanded(
                child: ListView.builder(
                  itemCount: participants.length,
                  itemBuilder: (context, index) {
                    final participant = participants[index];
                    return Column(
                      children: [
                        LeaderboardCard(participant: participant),
                        SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
