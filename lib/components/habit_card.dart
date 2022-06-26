import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';

class HabitCard extends StatelessWidget {
  String title;
  void Function() onTap;
  HabitCard({
    required this.title,
    required this.onTap,
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
          color: kDarkBlueColor,
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
            Row(
              children: [
                RoundedWhiteCheckbox(
                  value: true,
                ),
                RoundedWhiteCheckbox(
                  value: true,
                ),
                RoundedWhiteCheckbox(
                  value: true,
                ),
                RoundedWhiteCheckbox(
                  value: false,
                ),
                RoundedWhiteCheckbox(
                  value: false,
                ),
                RoundedWhiteCheckbox(
                  value: false,
                ),
                RoundedWhiteCheckbox(
                  value: false,
                ),
              ],
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
