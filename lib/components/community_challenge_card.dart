import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habitur/components/aside_button.dart';
import 'package:habitur/components/emphasis_card.dart';
import 'package:habitur/components/inactive_elevated_button.dart';
import 'package:habitur/components/rounded_progress_bar.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/community_challenge.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/modules/habit_stats_handler.dart';
import 'package:habitur/providers/community_challenge_manager.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/network_state_provider.dart';
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
    this.color = kDarkGray,
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
    void completeChallenge() {
      if (currentHabit.completionsToday != currentHabit.requiredCompletions) {
        habitStatsHandler.incrementCompletion(context);
        Provider.of<CommunityChallengeManager>(context, listen: false)
            .updateParticipantCurrentCompletions(
                context, challenge, 1); // Increment current completions
        Provider.of<CommunityChallengeManager>(context, listen: false)
            .handleFullCompletion(context, challenge);
        if (challenge.currentFullCompletions ==
            challenge.requiredFullCompletions) {
          Provider.of<CommunityChallengeManager>(context, listen: false)
              .updateParticipantFullCompletions(
                  context, challenge, 1); // Increment full completions
        }
        Provider.of<CommunityChallengeManager>(context, listen: false)
            .uploadChallengesToDatabase(context);
      }
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
          .uploadChallengesToDatabase(context);
    }

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
      if (Provider.of<NetworkStateProvider>(context, listen: false)
          .isConnected) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    CommunityChallengeOverviewScreen(challenge: challenge)));
      }
    },
    onLongPress: decrementChallenge,
    child: EmphasisCard(
      color: challenge.currentFullCompletions ==
              challenge.requiredFullCompletions
          ? kLightGreenAccent
          : Provider.of<NetworkStateProvider>(context).isConnected
              ? (challenge.habit.isCompleted ? color.withOpacity(0.5) : color)
              : kDarkGray.withOpacity(0.1),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Icon(Icons.groups,
                size: 32,
                color: Provider.of<NetworkStateProvider>(context).isConnected
                    ? kOrangeAccent
                    : kDarkGray),
          ),
          Provider.of<NetworkStateProvider>(context).isConnected
              ? Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularPercentIndicator(
                        animation: true,
                        animationDuration: 500,
                        animateFromLastPercent: true,
                        curve: Curves.ease,
                        radius: 50,
                        percent: totalProgress,
                        progressColor: challenge.currentFullCompletions ==
                                challenge.requiredFullCompletions
                            ? Colors.white
                            : kPrimaryColor,
                        backgroundColor: kBackgroundColor.withOpacity(0.3),
                        circularStrokeCap: CircularStrokeCap.round,
                        lineWidth: 10,
                        center: Text(
                          "${(totalProgress * 100).toStringAsFixed(0)}%",
                          style: kHeadingTextStyle.copyWith(
                              color: Colors.white, fontSize: 20),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                          alignment: AlignmentDirectional.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                currentHabit.title,
                                style: kHeadingTextStyle.copyWith(
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              RoundedProgressBar(
                                progress: userProgress,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(Icons.no_accounts_rounded, size: 32, color: kGray),
                        Text("Login to access",
                            style: kMainDescription.copyWith(color: kGray)),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    ),
  );
}

Widget buildAdminCard(context, challenge, currentHabit, totalProgress) {
  Color color = kFadedBlue;
  return Slidable(
    child: Container(
      alignment: AlignmentDirectional.center,
      width: 475,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: BoxDecoration(
        color: !currentHabit.isCompleted ? color : color.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Provider.of<NetworkStateProvider>(context).isConnected
          ? Row(
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
                          style:
                              kHeadingTextStyle.copyWith(color: Colors.white),
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 20),
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: AsideButton(
                                text: 'Delete',
                                onPressed: () {
                                  Database db = Database();
                                  db.communityChallengeDatabase
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
            )
          : Align(
              alignment: Alignment.center,
              child:
                  SizedBox(child: Icon(Icons.wifi_off, size: 32, color: kGray)),
            ),
    ),
  );
}
