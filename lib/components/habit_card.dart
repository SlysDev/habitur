import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../constants.dart';
import './rounded_progress_bar.dart';

class HabitCard extends StatelessWidget {
  String title;
  void Function() onTap;
  void Function() onLongPress;
  Color color;
  double progress;
  bool completed;
  void Function(BuildContext) onDismissed;
  void Function(BuildContext) onEdit;
  HabitCard({
    required this.title,
    required this.progress,
    required this.onTap,
    required this.onLongPress,
    required this.color,
    required this.completed,
    required this.onDismissed,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
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
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              decoration: BoxDecoration(
                color: !completed ? color : color.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    title,
                    style: kHeadingTextStyle.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  RoundedProgressBar(progress: progress),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
