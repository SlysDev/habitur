import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habitur/components/accent_elevated_button.dart';
import 'package:habitur/components/habit_difficulty_popup.dart';
import 'package:habitur/components/static_card.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/modules/habit_stats_handler.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/screens/edit_habit_screen.dart';
import 'package:habitur/screens/habit_overview_screen.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import './rounded_progress_bar.dart';

class HabitCard extends StatelessWidget {
  Color color;
  Color completeButtonColor = Colors.green;
  int index;
  HabitCard({this.color = kFadedBlue, required this.index});

  @override
  Widget build(BuildContext context) {
    Habit habit = Provider.of<HabitManager>(context).habits[index];
    HabitStatsHandler habitStatsHandler =
        HabitStatsHandler(Provider.of<HabitManager>(context).habits[index]);
    double progress = habit.completionsToday / habit.requiredCompletions;
    bool completed = habit.completionsToday == habit.requiredCompletions;
    completeHabit(double recordedDifficulty) {
      if (Provider.of<HabitManager>(context, listen: false)
              .habits[index]
              .completionsToday !=
          Provider.of<HabitManager>(context, listen: false)
              .habits[index]
              .requiredCompletions) {
        habitStatsHandler.incrementCompletion(context,
            recordedDifficulty: recordedDifficulty);
        Provider.of<HabitManager>(context, listen: false).updateHabits();
        Provider.of<Database>(context, listen: false).updateHabit(
            Provider.of<HabitManager>(context, listen: false).habits[index]);
      }
    }

    ;
    decrementHabit() {
      habitStatsHandler.decrementCompletion(context);
      Provider.of<HabitManager>(context, listen: false).updateHabits();
      Provider.of<Database>(context, listen: false).updateHabit(
          Provider.of<HabitManager>(context, listen: false).habits[index]);
    }

    ;
    editHabit() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EditHabitScreen(
                    habitIndex: index,
                  )));
    }

    ;
    deleteHabit() {
      Provider.of<HabitManager>(context, listen: false)
          .deleteHabit(context, index);
    }

    ;
    difficultyPopup(BuildContext context, index, onDifficultySelected) async {
      await showDialog(
        context: context,
        builder: (context) => HabitDifficultyPopup(
          habitIndex: index,
          onDifficultySelected: onDifficultySelected,
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HabitOverviewScreen(
                      habit: habit,
                    )));
      },
      child: Slidable(
        startActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                deleteHabit();
              },
              backgroundColor: Colors.red,
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(20),
              label: 'Delete',
            ),
            // TODO: Add editing functionality  <23-12-22, slys> //
            SlidableAction(
              onPressed: (context) {
                editHabit();
              },
              backgroundColor: Colors.blue,
              icon: Icons.edit,
              borderRadius: BorderRadius.circular(20),
              label: 'Edit',
            ),
          ],
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.ease,
              height: 128,
              decoration: BoxDecoration(
                color: !completed ? color : color.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            habit.title,
                            style:
                                kHeadingTextStyle.copyWith(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          RoundedProgressBar(progress: progress),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      difficultyPopup(context, index, completeHabit);
                    },
                    onLongPress: () {
                      decrementHabit();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.ease,
                      width: 100,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.check,
                        size: 30,
                        color: kLightGreenAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
