import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:habitur/components/habit_stats_card.dart';
import 'package:habitur/components/inactive_elevated_button.dart';
import 'package:habitur/components/rounded_progress_bar.dart';
import 'package:habitur/components/static_card.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/community_challenge.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/components/leaderboard_card.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/modules/habit_stats_handler.dart';
import 'package:habitur/providers/community_challenge_manager.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart'; // Import your LeaderboardCard

class CommunityChallengeOverviewScreen extends StatelessWidget {
  CommunityChallenge challenge;
  CommunityChallengeOverviewScreen({
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
    Habit currentHabit = challenge.habit;
    HabitStatsHandler habitStatsHandler = HabitStatsHandler(currentHabit);
    double userProgress =
        currentHabit.completionsToday / currentHabit.requiredCompletions;
    void completeChallenge() {
      if (currentHabit.completionsToday != currentHabit.requiredCompletions) {
        habitStatsHandler.incrementCompletion(context);
        Provider.of<CommunityChallengeManager>(context, listen: false)
            .updateParticipantCurrentCompletions(
                context, challenge, 1); // Increment current completions
        Provider.of<CommunityChallengeManager>(context, listen: false)
            .checkFullCompletion(context, challenge);
        if (challenge.currentFullCompletions ==
            challenge.requiredFullCompletions) {
          Provider.of<CommunityChallengeManager>(context, listen: false)
              .updateParticipantFullCompletions(
                  context, challenge, 1); // Increment full completions
        }
      }
      Provider.of<CommunityChallengeManager>(context, listen: false)
          .updateChallenges(context);
    }

    void decrementChallenge() {
      if (currentHabit.isCompleted) {
        Provider.of<CommunityChallengeManager>(context, listen: false)
            .decrementFullCompletion(challenge, context);
        Provider.of<CommunityChallengeManager>(context, listen: false)
            .updateParticipantFullCompletions(
                context, challenge, -1); // Decrement full completions
      } else {
        Provider.of<CommunityChallengeManager>(context, listen: false)
            .updateParticipantCurrentCompletions(
                context, challenge, -1); // Decrement current completions
      }
      habitStatsHandler.decrementCompletion(context);
      Provider.of<CommunityChallengeManager>(context, listen: false)
          .updateChallenges(context);
    }

    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Text(challenge.habit.title,
                      style:
                          kTitleTextStyle.copyWith(color: kLightPrimaryColor),
                      textAlign: TextAlign.center),
                  SizedBox(height: 20),
                  Text(challenge.description,
                      style: kMainDescription, textAlign: TextAlign.center),
                  SizedBox(height: 40),
                  RoundedProgressBar(
                    progress: totalProgress,
                    lineHeight: 40,
                    color: kPrimaryColor,
                  ),
                  // CircularPercentIndicator(
                  //   animation: true,
                  //   animationDuration: 500,
                  //   animateFromLastPercent: true,
                  //   curve: Curves.ease,
                  //   radius: 70,
                  //   percent: totalProgress,
                  //   progressColor: kPrimaryColor,
                  //   backgroundColor: kFadedBlue.withOpacity(0.4),
                  //   circularStrokeCap: CircularStrokeCap.round,
                  //   lineWidth: 15,
                  //   center: Text(
                  //     "${(totalProgress * 100).toStringAsFixed(0)}%",
                  //     style: kHeadingTextStyle.copyWith(
                  //         color: Colors.white, fontSize: 28),
                  //   ),
                  // ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${challenge.currentFullCompletions.toString()} / ${challenge.requiredFullCompletions.toString()}',
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
                  Container(
                    width: 300,
                    child: Row(
                      children: [
                        Text(
                          'Today\'s progress:',
                          style: kMainDescription,
                        ),
                        Expanded(
                          child: RoundedProgressBar(progress: userProgress),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Expanded(
                    child: StaticCard(
                      opacity: 0.3,
                      child: ListView.builder(
                        itemCount: participants.length,
                        itemBuilder: (context, index) {
                          ParticipantData participant = participants[index];
                          print('participant uid:');
                          print(participant.user.uid);
                          print('current user id:');
                          print(Provider.of<UserLocalStorage>(context)
                              .currentUser
                              .uid);
                          return Column(
                            children: [
                              LeaderboardCard(participant: participant),
                              SizedBox(height: 20),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: challenge.currentFullCompletions ==
                        challenge.requiredFullCompletions
                    ? InactiveElevatedButton(
                        child: Text(
                        'Complete',
                        style: kMainDescription.copyWith(color: Colors.black),
                        textAlign: TextAlign.center,
                      ))
                    : ElevatedButton(
                        onPressed: () {
                          if (!(challenge.currentFullCompletions ==
                              challenge.requiredFullCompletions)) {
                            print('completed');
                            completeChallenge();
                          }
                        },
                        child: Text(
                          "Complete",
                          style: kMainDescription.copyWith(color: Colors.black),
                          textAlign: TextAlign.center,
                        )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
