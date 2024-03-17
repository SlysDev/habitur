import 'package:flutter/material.dart';
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
            color: Colors.white,
            onRefresh: () async {
              communityChallengeManager.resetDailyHabits();
              Provider.of<Database>(context, listen: false).loadData(context);
              Future.delayed(Duration(seconds: 1));
            },
            child: ListView.builder(
                itemBuilder: (context, index) {
                  HabitStatsHandler habitStatsHandler = HabitStatsHandler(
                      communityChallengeManager.habits[index]);
                  communityChallengeManager.sortHabits();
                  Habit currentHabit = communityChallengeManager.habits[index];
                  return Column(
                    children: [
                      SizedBox(height: 30),
                      HabitCard(
                          title: currentHabit.title,
                          progress: currentHabit.completionsToday /
                              currentHabit.requiredCompletions,
                          onTap: () {
                            if (communityChallengeManager
                                    .habits[index].completionsToday !=
                                communityChallengeManager
                                    .habits[index].requiredCompletions) {
                              habitStatsHandler.incrementCompletion(context);
                              communityChallengeManager.updateHabits(context);
                            }
                          },
                          onLongPress: () {
                            habitStatsHandler.decrementCompletion(context);
                            communityChallengeManager.updateHabits(context);
                          },
                          color: kFadedBlue,
                          completed: currentHabit.completionsToday ==
                              currentHabit.requiredCompletions,
                          onDismissed: (context) {
                            communityChallengeManager.removeHabit(index);
                            communityChallengeManager.updateHabits(context);
                          },
                          onEdit: (context) {})
                    ],
                  );
                },
                itemCount: communityChallengeManager.habits.length),
          ),
        ),
      );
    });
  }
}
