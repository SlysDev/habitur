import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/community_challenge.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/components/leaderboard_card.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/providers/community_challenge_manager.dart';
import 'package:habitur/providers/user_data.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart'; // Import your LeaderboardCard

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
    challenge.sortParticipantData();
    print(challenge.participants);
    print('participants');
    List<ParticipantData> participants =
        Provider.of<CommunityChallengeManager>(context)
            .challenges[0]
            .participants;
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
                    ParticipantData participant = participants[index];
                    print('participant uid:');
                    print(participant.user.uid);
                    print('current user id:');
                    print(Provider.of<UserData>(context).currentUser.uid);
                    return Column(
                      children: [
                        LeaderboardCard(participant: participant),
                        SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Provider.of<CommunityChallengeManager>(context, listen: false)
                      .addParticipantData(
                    context,
                    challenge,
                    ParticipantData(
                      user: UserModel(
                        username: 'test',
                        profilePicture:
                            AssetImage('assets/images/default_profile.png'),
                        uid: 'test1043',
                        email: 'test',
                        userXP: 0,
                        userLevel: 0,
                      ),
                      fullCompletionCount: 1,
                    ),
                  );
                  Provider.of<CommunityChallengeManager>(context, listen: false)
                      .updateChallenges(context);
                  print('participant added');
                  print(Provider.of<CommunityChallengeManager>(context,
                          listen: false)
                      .getChallenge(0)
                      .participants);
                },
                child: Text('Add Participant'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
