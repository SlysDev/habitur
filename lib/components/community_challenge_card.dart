import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habitur/components/aside_button.dart';
import 'package:habitur/components/inactive_elevated_button.dart';
import 'package:habitur/components/rounded_progress_bar.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/community_challenge.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/modules/habit_stats_handler.dart';
import 'package:habitur/providers/community_challenge_manager.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/screens/community_leaderboard_screen.dart';
import 'package:habitur/screens/edit_community_challenge_screen.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

class CommunityChallengeCard extends StatelessWidget {
  CommunityChallenge challenge;
  Color color;
  bool isAdmin;
  CommunityChallengeCard({
    super.key,
    required this.challenge,
    this.color = kFadedBlue,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    Habit currentHabit = challenge.habit;
    HabitStatsHandler habitStatsHandler = HabitStatsHandler(currentHabit);
    double totalProgress =
        challenge.currentFullCompletions / challenge.requiredFullCompletions;
    double userProgress =
        currentHabit.completionsToday / currentHabit.requiredCompletions;
    Function() completeChallenge = () {
      if (currentHabit.completionsToday != currentHabit.requiredCompletions) {
        habitStatsHandler.incrementCompletion(context);
        Provider.of<CommunityChallengeManager>(context, listen: false)
            .checkFullCompletion(context, challenge);
        Provider.of<CommunityChallengeManager>(context, listen: false)
            .updateChallenges(context);
      }
    };
    Function() decrementChallenge = () {
      if (currentHabit.isCompleted) {
        Provider.of<CommunityChallengeManager>(context, listen: false)
            .decrementFullCompletion(challenge, context);
      }
      habitStatsHandler.decrementCompletion(context);
      Provider.of<CommunityChallengeManager>(context, listen: false)
          .updateChallenges(context);
    };

    return isAdmin
        ? buildAdminCard(context, challenge, currentHabit, totalProgress)
        : buildNormalCard(
            context,
            challenge,
            decrementChallenge,
            completeChallenge,
            color,
            currentHabit,
            totalProgress,
            userProgress);
  }
}

Widget buildNormalCard(context, challenge, decrementChallenge,
    completeChallenge, color, currentHabit, totalProgress, userProgress) {
  return GestureDetector(
    onTap: () {
      print('habit tapped');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  CommunityLeaderboardScreen(challenge: challenge)));
    },
    // TODO: Implement popup screen
    onLongPress: decrementChallenge,
    child: AnimatedContainer(
      alignment: AlignmentDirectional.center,
      duration: const Duration(milliseconds: 500),
      height: 300,
      width: 475,
      curve: Curves.ease,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: BoxDecoration(
        color: challenge.currentFullCompletions ==
                challenge.requiredFullCompletions
            ? kLightGreenAccent
            : (challenge.habit.isCompleted ? color.withOpacity(0.5) : color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  child: CircularPercentIndicator(
                    animation: true,
                    animationDuration: 500,
                    animateFromLastPercent: true,
                    curve: Curves.ease,
                    radius: 60,
                    percent: totalProgress,
                    progressColor: challenge.currentFullCompletions ==
                            challenge.requiredFullCompletions
                        ? Colors.white
                        : kPrimaryColor,
                    backgroundColor: Colors.transparent,
                    circularStrokeCap: CircularStrokeCap.round,
                    lineWidth: 10,
                    center: Text(
                      "${(totalProgress * 100).toStringAsFixed(0)}%",
                      style: kHeadingTextStyle.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // total completions display
                Row(
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
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              width: 25,
            ),
            Container(
              width: 175,
              alignment: AlignmentDirectional.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    currentHabit.title,
                    style: kHeadingTextStyle.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    challenge.description,
                    style: kMainDescription.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  RoundedProgressBar(progress: userProgress),
                  SizedBox(
                    height: 30,
                  ),
                  challenge.currentFullCompletions ==
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
                              completeChallenge();
                            }
                          },
                          child: Text(
                            "Complete",
                            style:
                                kMainDescription.copyWith(color: Colors.black),
                            textAlign: TextAlign.center,
                          ))
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildAdminCard(context, challenge, currentHabit, totalProgress) {
  Color color = kFadedBlue;
  return Slidable(
    child: Container(
      alignment: AlignmentDirectional.center,
      height: 300,
      width: 475,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: BoxDecoration(
        color: !currentHabit.isCompleted ? color : color.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                child: CircularPercentIndicator(
                  animation: true,
                  animationDuration: 500,
                  animateFromLastPercent: true,
                  curve: Curves.ease,
                  radius: 60,
                  percent: totalProgress,
                  progressColor: kPrimaryColor,
                  backgroundColor: Colors.transparent,
                  circularStrokeCap: CircularStrokeCap.round,
                  lineWidth: 10,
                  center: Text(
                    "${(totalProgress * 100).toStringAsFixed(0)}%",
                    style: kHeadingTextStyle.copyWith(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // total completions display
              Row(
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
              SizedBox(height: 10),
            ],
          ),
          SizedBox(
            width: 25,
          ),
          Container(
            width: 175,
            alignment: AlignmentDirectional.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  currentHabit.title,
                  style: kHeadingTextStyle.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  challenge.description,
                  style: kMainDescription.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: AsideButton(
                          text: 'Edit',
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        EditCommunityChallengeScreen(
                                            challenge: challenge)));
                          }),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: AsideButton(
                          text: 'Delete',
                          onPressed: () {
                            Provider.of<Database>(context, listen: false)
                                .removeCommunityChallenge(
                                    challenge.id, context);
                          }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
