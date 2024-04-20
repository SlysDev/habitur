import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:habitur/components/community_challenge_card.dart';
import 'package:habitur/models/community_challenge.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/providers/community_challenge_manager.dart';
import 'package:provider/provider.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/modules/habit_stats_handler.dart';
import 'package:intl/intl.dart';
import 'package:habitur/components/habit_card.dart';

class CommunityHabitList extends StatelessWidget {
  const CommunityHabitList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunityChallengeManager>(
        builder: (context, communityChallengeManager, child) {
      return Expanded(
        child: SizedBox(
          width: double.infinity,
          child: RefreshIndicator(
            backgroundColor: kPrimaryColor,
            color: kBackgroundColor,
            onRefresh: () async {
              Provider.of<Database>(context, listen: false).loadData(context);
              Future.delayed(Duration(seconds: 1));
            },
            child: ListView.builder(
                itemBuilder: (context, index) {
                  Habit currentHabit =
                      communityChallengeManager.getHabit(index);
                  CommunityChallenge currentChallenge =
                      communityChallengeManager.challenges[index];
                  HabitStatsHandler habitStatsHandler =
                      HabitStatsHandler(currentHabit);
                  return Column(
                    children: [
                      SizedBox(height: 30),
                      CommunityChallengeCard(
                          title: currentHabit.title,
                          userProgress: currentHabit.completionsToday /
                              currentHabit.requiredCompletions,
                          totalProgress:
                              currentChallenge.currentFullCompletions /
                                  currentChallenge.requiredFullCompletions,
                          completionCount: currentHabit.completionsToday,
                          totalFullCompletions:
                              currentChallenge.currentFullCompletions,
                          description: currentChallenge.description,
                          onTap: () {
                            if (currentHabit.completionsToday !=
                                currentHabit.requiredCompletions) {
                              habitStatsHandler.incrementCompletion(context);
                              currentChallenge.checkFullCompletion();
                              communityChallengeManager
                                  .updateChallenges(context);
                            }
                          },
                          onLongPress: () {
                            if (currentHabit.isCompleted) {
                              currentChallenge.decrementFullCompletion();
                            }
                            habitStatsHandler.decrementCompletion(context);
                            communityChallengeManager.updateChallenges(context);
                          },
                          color: kFadedBlue,
                          completed: currentHabit.completionsToday ==
                              currentHabit.requiredCompletions,
                          onDismissed: (context) {
                            communityChallengeManager.removeChallenge(index);
                            communityChallengeManager.updateChallenges(context);
                          },
                          onEdit: (context) {})
                    ],
                  );
                },
                itemCount: communityChallengeManager.challenges.length),
          ),
        ),
      );
    });
  }
}
