import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/screens/habit_overview_screen.dart';
import '../constants.dart';
import './rounded_progress_bar.dart';

class HabitCard extends StatelessWidget {
  String title;
  void Function() onTap;
  void Function() onLongPress;
  Color color;
  Color completeButtonColor = Colors.green;
  double progress;
  bool completed;
  void Function(BuildContext) onDismissed;
  void Function(BuildContext) onEdit;
  Habit habit;
  HabitCard({
    required this.title,
    required this.progress,
    required this.onTap,
    required this.onLongPress,
    this.color = kFadedBlue,
    required this.completed,
    required this.onDismissed,
    required this.onEdit,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
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
          motion: DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: onDismissed,
              backgroundColor: Colors.red,
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(20),
              label: 'Delete',
            ),
            // TODO: Add editing functionality  <23-12-22, slys> //
            SlidableAction(
              onPressed: onEdit,
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
              duration: const Duration(milliseconds: 500),
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
                            title,
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
                    onTap: onTap,
                    onLongPress: onLongPress,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
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
