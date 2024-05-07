import 'package:flutter/material.dart';
import 'package:habitur/components/rounded_progress_bar.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/community_challenge.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/modules/habit_stats_handler.dart';
import 'package:habitur/providers/community_challenge_manager.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

class CommunityChallengeCard extends StatelessWidget {
  CommunityChallenge challenge;
  Color color;
  CommunityChallengeCard({
    super.key,
    required this.challenge,
    this.color = kFadedBlue,
  });

  @override
  Widget build(BuildContext context) {
    Habit currentHabit = challenge.habit;
    HabitStatsHandler habitStatsHandler = HabitStatsHandler(currentHabit);
    double totalProgress =
        challenge.currentFullCompletions / challenge.requiredFullCompletions;
    double userProgress =
        currentHabit.completionsToday / currentHabit.requiredCompletions;

    return GestureDetector(
      onTap: () {
        if (currentHabit.completionsToday != currentHabit.requiredCompletions) {
          habitStatsHandler.incrementCompletion(context);
          challenge.checkFullCompletion();
          Provider.of<CommunityChallengeManager>(context, listen: false)
              .updateChallenges(context);
        }
      },
      onLongPress: () {
        if (currentHabit.isCompleted) {
          challenge.decrementFullCompletion();
        }
        habitStatsHandler.decrementCompletion(context);
        Provider.of<CommunityChallengeManager>(context, listen: false)
            .updateChallenges(context);
      },
      child: AnimatedContainer(
        alignment: AlignmentDirectional.center,
        duration: const Duration(milliseconds: 500),
        height: 275,
        width: 475,
        curve: Curves.ease,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        decoration: BoxDecoration(
          color: !currentHabit.isCompleted ? color : color.withOpacity(0.5),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(),
                      SizedBox(
                        width: 10,
                      ),
                      CircleAvatar(),
                      SizedBox(
                        width: 10,
                      ),
                      CircleAvatar(),
                    ],
                  ),
                ],
              ),
              SizedBox(
                width: 75,
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
