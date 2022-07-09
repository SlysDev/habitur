import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/providers/user_data.dart';
import 'package:provider/provider.dart';

import '../components/filled_text_field.dart';

int? selectedHabit = 0;
String habitTitle = '';

class AddHabitScreen extends StatefulWidget {
  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
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
              FilledTextField(
                  onChanged: (value) {
                    habitTitle = value;
                    print(habitTitle);
                  },
                  hintText: 'Title'),
              ElevatedButton(
                onPressed: () {
                  Provider.of<UserData>(context, listen: false).addUserHabit(
                    Habit(title: habitTitle, category: '', difficulty: 0),
                  );
                  Navigator.pop(context);
                },
                child: Text('Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
