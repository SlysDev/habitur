import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:habitur/components/days_of_week_selector.dart';
import 'package:habitur/components/reset_period_button.dart';
import 'package:habitur/components/smart_notification_switch.dart';
import 'package:habitur/components/static_card.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/data/local/habits_local_storage.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/providers/add_habit_screen_provider.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/network_state_provider.dart';
import '../components/rounded_tile.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:provider/provider.dart';

import '../components/filled_text_field.dart';

class AddHabitScreen extends StatefulWidget {
  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  @override
  Widget build(BuildContext context) {
    void setHabit(Habit habit) {
      Provider.of<AddHabitScreenProvider>(context, listen: false).habit = habit;
    }

    Habit newHabit = Provider.of<AddHabitScreenProvider>(context).habit;
    return Consumer<AddHabitScreenProvider>(
        builder: (context, addHabitProvider, child) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: const BoxDecoration(
            color: kBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          height: MediaQuery.of(context).size.height * 0.85,
          child: Container(
            decoration: const BoxDecoration(
              color: kBackgroundColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              child: ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'New Habit',
                        style: kTitleTextStyle,
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Text(
                        'Name',
                        style: kHeadingTextStyle.copyWith(color: Colors.white),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      FilledTextField(
                          controller: addHabitProvider.titleController,
                          onChanged: (value) {
                            setHabit(newHabit.copyWith(title: value));
                            debugPrint(newHabit.title);
                          },
                          hintText: 'Meditate, Run, etc.'),
                      const SizedBox(
                        height: 60,
                      ),
                      SmartNotificationSwitch(habit: newHabit),
                      const SizedBox(
                        height: 40,
                      ),
                      Text(
                        'Goal',
                        style: kHeadingTextStyle.copyWith(color: Colors.white),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      StaticCard(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ResetPeriodButton(
                                    habit: newHabit,
                                    resetPeriod: 'Daily',
                                    onTap: () {
                                      setHabit(newHabit.copyWith(
                                          resetPeriod: 'Daily'));
                                    }),
                                ResetPeriodButton(
                                    habit: newHabit,
                                    resetPeriod: 'Weekly',
                                    onTap: () {
                                      setHabit(newHabit.copyWith(
                                          resetPeriod: 'Weekly'));
                                    }),
                                ResetPeriodButton(
                                  habit: newHabit,
                                  resetPeriod: 'Monthly',
                                  onTap: () {
                                    setHabit(newHabit.copyWith(
                                        resetPeriod: 'Monthly'));
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 100,
                                  child: FilledTextField(
                                      controller: addHabitProvider
                                          .requiredCompletionsController,
                                      onChanged: (value) {
                                        setHabit(newHabit.copyWith(
                                          requiredCompletions: int.parse(value),
                                        ));
                                      },
                                      hintText: '#'),
                                ),
                                SizedBox(width: 20),
                                Text(
                                  newHabit.resetPeriod == 'Daily'
                                      ? 'time(s) per day'
                                      : 'time(s) per ${newHabit.resetPeriod.substring(0, newHabit.resetPeriod.length - 2).toLowerCase()}',
                                  // Removes 'ly' from adverbs
                                  style: kSubHeadingTextStyle.copyWith(
                                      color: kGray),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      newHabit.resetPeriod == 'Daily'
                          ? DaysOfWeekSelector(habit: newHabit)
                          : Container(),
                      ElevatedButton(
                        onPressed: () async {
                          Provider.of<HabitManager>(context, listen: false)
                              .addHabit(newHabit, context);
                          Database db = Database();
                          await db.habitDatabase.addHabit(newHabit, context);
                          await Provider.of<HabitsLocalStorage>(context,
                                  listen: false)
                              .addHabit(newHabit);
                          Provider.of<HabitManager>(context, listen: false)
                              .sortHabits();
                          Provider.of<HabitManager>(context, listen: false)
                              .updateHabits();
                          Provider.of<AddHabitScreenProvider>(context,
                                  listen: false)
                              .reset();
                          Navigator.pop(context);
                        },
                        child: const Text('Create'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
