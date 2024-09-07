import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/habit.dart';

class ResetPeriodButton extends StatefulWidget {
  Habit habit;
  String resetPeriod;
  Function() onTap;
  ResetPeriodButton(
      {super.key,
      required this.habit,
      required this.resetPeriod,
      required this.onTap});

  @override
  State<ResetPeriodButton> createState() => _ResetPeriodButtonState();
}

class _ResetPeriodButtonState extends State<ResetPeriodButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: widget.habit.resetPeriod == widget.resetPeriod
                ? kLightGreenAccent.withOpacity(0.5)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20)),
        child: Text(
          widget.resetPeriod,
          style: TextStyle(
              color: widget.habit.resetPeriod == widget.resetPeriod
                  ? Colors.white
                  : kGray),
        ),
      ),
    );
  }
}
