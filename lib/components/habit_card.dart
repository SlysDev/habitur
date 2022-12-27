import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habitur/constants.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

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
            // SlidableAction(
            //   onPressed: onEdit,
            //   backgroundColor: Colors.blue,
            //   icon: Icons.edit,
            //   borderRadius: BorderRadius.circular(20),
            //   label: 'Edit',
            // ),
          ],
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
          margin: EdgeInsets.symmetric(vertical: 20),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          decoration: BoxDecoration(
            color: !completed ? color : kSlateGray.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: kHeadingTextStyle.copyWith(color: Colors.white),
              ),
              const SizedBox(
                height: 15,
              ),
              LinearPercentIndicator(
                percent: progress,
                barRadius: const Radius.circular(30),
                lineHeight: 12.0,
                animation: true,
                animationDuration: 600,
                curve: Curves.easeInOut,
                animateFromLastPercent: true,
                progressColor: Colors.white,
                backgroundColor: Colors.white24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoundedWhiteCheckbox extends StatelessWidget {
  bool value;
  RoundedWhiteCheckbox({required this.value});
  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.tight,
      child: Checkbox(
        fillColor: MaterialStateProperty.all(Colors.white),
        value: value,
        onChanged: null,
        checkColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: const BorderSide(width: 20, color: Colors.white),
        ),
      ),
    );
  }
}