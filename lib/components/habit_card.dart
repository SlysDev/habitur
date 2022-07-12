import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class HabitCard extends StatelessWidget {
  String title;
  void Function() onTap;
  Color color;
  double progress;
  bool completed;
  void Function(DismissDirection) onDismissed;
  HabitCard({
    required this.title,
    required this.progress,
    required this.onTap,
    required this.color,
    required this.completed,
    required this.onDismissed,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Dismissible(
        onDismissed: onDismissed,
        key: Key(title),
        background: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: kBarnRed),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        child: Container(
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
