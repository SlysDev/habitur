import 'package:flutter/material.dart';
import 'package:habitur/models/habit.dart';

class HabitOverviewScreen extends StatelessWidget {
  const HabitOverviewScreen({super.key, required Habit habit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Text('Overview Screen'),
      ),
    );
  }
}
