import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';

import '../components/filled_text_field.dart';

class AddHabitScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff757575),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Column(
            children: [
              Text(
                'New Habit',
                style: kHeadingTextStyle,
              ),
              FilledTextField(onChanged: (value) {}, hintText: 'Title'),
            ],
          ),
        ),
      ),
    );
  }
}
