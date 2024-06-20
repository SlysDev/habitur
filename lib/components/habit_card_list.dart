import 'package:flutter/material.dart';
import 'package:habitur/components/habit_card.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/modules/habit_stats_handler.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/providers/user_data.dart';
import 'package:habitur/screens/edit_habit_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HabitCardList extends StatelessWidget {
  bool isOnline;
  HabitCardList({context, this.isOnline = true});
  @override
  Widget build(BuildContext context) {
    return Consumer<HabitManager>(builder: (context, habitManager, child) {
      return Expanded(
        child: SizedBox(
          width: double.infinity,
          child: RefreshIndicator(
            backgroundColor: kPrimaryColor,
            color: Colors.white,
            onRefresh: () async {
              habitManager.resetDailyHabits();
              Provider.of<Database>(context, listen: false).loadData(context);
              Future.delayed(Duration(seconds: 1));
            },
            child: ListView.builder(
                itemBuilder: (context, index) {
                  HabitStatsHandler habitStatsHandler =
                      HabitStatsHandler(habitManager.habits[index]);
                  habitManager.sortHabits();
                  return habitManager
                          .sortedHabits[index].requiredDatesOfCompletion
                          .contains(DateFormat('EEEE').format(DateTime.now()))
                      ? Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            HabitCard(
                              progress:
                                  habitManager.habits[index].completionsToday /
                                      habitManager
                                          .habits[index].requiredCompletions,
                              completed:
                                  habitManager.habits[index].completionsToday ==
                                          habitManager
                                              .habits[index].requiredCompletions
                                      ? true
                                      : false,
                              onDismissed: (context) {
                                habitManager.removeHabit(index);
                                habitManager.updateHabits(context);
                              },
                              onEdit: (context) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditHabitScreen(
                                              habitIndex: index,
                                            )));
                              },
                              title: habitManager.habits[index].title,
                              onLongPress: () {
                                habitStatsHandler.decrementCompletion(context);
                                habitManager.updateHabits(context);
                              },
                              onTap: () {
                                if (habitManager
                                        .habits[index].completionsToday !=
                                    habitManager
                                        .habits[index].requiredCompletions) {
                                  habitStatsHandler
                                      .incrementCompletion(context);
                                  habitManager.updateHabits(context);
                                }
                              },
                              habit: habitManager.habits[index],
                            ),
                            // color: habitManager.habits[index].color),
                            SizedBox(
                              height: 20,
                            )
                          ],
                        )
                      : Container();
                },
                itemCount: habitManager.habits.length),
          ),
        ),
      );
    });
  }
}
