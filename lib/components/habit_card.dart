import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class HabitCard extends StatelessWidget {
  String title;
  void Function() onTap;
  Color color;
  HabitCard({
    required this.title,
    required this.onTap,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 30),
        width: 250,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        decoration: BoxDecoration(
          color: color,
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
              percent: 0.5,
              barRadius: Radius.circular(30),
              lineHeight: 12.0,
              progressColor: Colors.white,
              backgroundColor: Colors.white24,
            ),
          ],
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
