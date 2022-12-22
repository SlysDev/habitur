import 'package:flutter/material.dart';
import 'package:habitur/components/habit_card.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HabitCardList extends StatelessWidget {
  HabitCardList({context});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Consumer<HabitManager>(builder: (context, habitManager, child) {
        return Expanded(
          child: SizedBox(
            width: double.infinity,
            child: ListView.builder(
                itemBuilder: (context, index) {
                  return habitManager.habits[index].requiredDatesOfCompletion
                          .contains(DateFormat('EEEE').format(DateTime.now()))
                      ? HabitCard(
                          progress: habitManager
                                  .habits[index].completionsToday /
                              habitManager.habits[index].requiredCompletions,
                          completed: habitManager
                                      .habits[index].completionsToday ==
                                  habitManager.habits[index].requiredCompletions
                              ? true
                              : false,
                          onDismissed: (direction) {
                            habitManager.removeHabit(index);
                          },
                          title: habitManager.habits[index].title,
                          onLongPress: () {
                            habitManager.habits[index].decrementCompletion();
                          },
                          onTap: () {
                            if (habitManager.habits[index].completionsToday !=
                                habitManager
                                    .habits[index].requiredCompletions) {
                              habitManager.habits[index].incrementCompletion();
                            }
                          },
                          color: habitManager.habits[index].color)
                      : Container();
                },
                itemCount: habitManager.habits.length),
          ),
        );
      }),
    );
  }
}
