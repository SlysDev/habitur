import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habitur/components/accent_elevated_button.dart';
import 'package:habitur/components/habit_difficulty_popup.dart';
import 'package:habitur/components/static_card.dart';
import 'package:habitur/data/local/habits_local_storage.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/modules/habit_stats_handler.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/screens/edit_habit_screen.dart';
import 'package:habitur/screens/habit_overview_screen.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import './rounded_progress_bar.dart';
import 'package:confetti/confetti.dart';

class InactiveHabitCard extends StatefulWidget {
  Color color = Colors.white.withOpacity(0.04);
  int index;

  InactiveHabitCard({required this.index});

  @override
  State<InactiveHabitCard> createState() => _InactiveHabitCardState();
}

class _InactiveHabitCardState extends State<InactiveHabitCard> {
  Color completeButtonColor = Colors.green;
  bool isLoading = false;
  late ConfettiController _controller;
  void setLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  @override
  void initState() {
    _controller = ConfettiController(duration: const Duration(seconds: 1));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Habit habit = Provider.of<HabitManager>(context).habits[widget.index];
    double progress = habit.completionsToday / habit.requiredCompletions;
    bool completed = habit.completionsToday == habit.requiredCompletions;
    editHabit() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EditHabitScreen(
                    habitIndex: widget.index,
                  )));
    }

    deleteHabit() async {
      Database db = Database();
      await db.habitDatabase.deleteHabit(context, habit.id);
      await Provider.of<HabitsLocalStorage>(context, listen: false)
          .deleteHabit(habit);
      await Provider.of<HabitManager>(context, listen: false)
          .deleteHabit(context, widget.index);
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutSine,
      opacity: isLoading ? 0.1 : 1,
      child: Stack(
        children: [
          GestureDetector(
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
                    onPressed: (context) async {
                      setLoading(true);
                      await deleteHabit();
                      setLoading(false);
                    },
                    backgroundColor: kRed,
                    icon: Icons.delete,
                    borderRadius: BorderRadius.circular(20),
                    label: 'Delete',
                  ),
                  SlidableAction(
                    onPressed: (context) {
                      editHabit();
                    },
                    backgroundColor: kDarkPrimaryColor,
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
                      color: !completed
                          ? widget.color
                          : widget.color.withOpacity(0.5),
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
                                  style: kHeadingTextStyle.copyWith(
                                      color: Colors.white.withOpacity(0.75)),
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
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.ease,
                            width: 100,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.check,
                              size: 30,
                              color: Colors.grey.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 128,
            child: Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                emissionFrequency: 0,
                minBlastForce: 10,
                numberOfParticles: 10,
                blastDirectionality: BlastDirectionality.explosive,
                confettiController: _controller,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
