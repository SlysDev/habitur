import 'package:flutter/material.dart';
import 'package:habitur/components/habit_card.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/screens/edit_habit_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HabitCardList extends StatelessWidget {
  HabitCardList({context});
  @override
  Widget build(BuildContext context) {
    return Consumer<HabitManager>(builder: (context, habitManager, child) {
      return Expanded(
        child: SizedBox(
          width: double.infinity,
          child: ListView.builder(
              itemBuilder: (context, index) {
                return habitManager.habits[index].requiredDatesOfCompletion
                        .contains(DateFormat('EEEE').format(DateTime.now()))
                    ? HabitCard(
                        progress: habitManager.habits[index].completionsToday /
                            habitManager.habits[index].requiredCompletions,
                        completed: habitManager
                                    .habits[index].completionsToday ==
                                habitManager.habits[index].requiredCompletions
                            ? true
                            : false,
                        onDismissed: (context) {
                          habitManager.removeHabit(index);
                          habitManager.updateHabits(context);
                        },
                        onEdit: (context) {
                          showDialog(
                            context: context,
                            barrierColor: Colors.white,
                            builder: (BuildContext context) {
                              return Card(
                                child: EditHabitDialog(habitIndex: index),
                              );
                            },
                          );
                          // showModalBottomSheet(
                          //     context: context,
                          //     isScrollControlled: true,
                          //     builder: (context) => EditHabitScreen(
                          //           habitIndex: index,
                          //         ));
                        },
                        title: habitManager.habits[index].title,
                        onLongPress: () {
                          habitManager.habits[index].decrementCompletion();
                          habitManager.updateHabits(context);
                        },
                        onTap: () {
                          if (habitManager.habits[index].completionsToday !=
                              habitManager.habits[index].requiredCompletions) {
                            habitManager.habits[index].incrementCompletion();
                            habitManager.updateHabits(context);
                          }
                        },
                        color: habitManager.habits[index].color)
                    : Container();
              },
              itemCount: habitManager.habits.length),
        ),
      );
    });
  }
}