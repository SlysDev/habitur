import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/habit.dart';
import '../components/rounded_tile.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/providers/user_data.dart';
import 'package:provider/provider.dart';

import '../components/filled_text_field.dart';

int? selectedHabit = 0;
String habitTitle = '';
int habitCompletions = 1;
String selectedPeriod = 'Daily';
List<String> daysActive = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday'
];

class AddHabitScreen extends StatefulWidget {
  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      height: MediaQuery.of(context).size.height * 0.8,
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
                    height: 60,
                  ),
                  const Text(
                    'Name',
                    style: kHeadingTextStyle,
                  ),
                  FilledTextField(
                      onChanged: (value) {
                        habitTitle = value;
                      },
                      hintText: 'Meditate, Run, etc.'),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Goal',
                    style: kHeadingTextStyle,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedPeriod = 'Daily';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: selectedPeriod == 'Daily'
                                    ? kPrimaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              'Daily',
                              style: TextStyle(
                                  color: selectedPeriod == 'Daily'
                                      ? Colors.white
                                      : kGray),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedPeriod = 'Weekly';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: selectedPeriod == 'Weekly'
                                    ? kPrimaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              'Weekly',
                              style: TextStyle(
                                  color: selectedPeriod == 'Weekly'
                                      ? Colors.white
                                      : kGray),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedPeriod = 'Monthly';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: selectedPeriod == 'Monthly'
                                    ? kPrimaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              'Monthly',
                              style: TextStyle(
                                  color: selectedPeriod == 'Monthly'
                                      ? Colors.white
                                      : kGray),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 120,
                        child: FilledTextField(
                            onChanged: (value) {
                              habitCompletions = int.parse(value);
                            },
                            hintText: '#'),
                      ),
                      Text(
                        selectedPeriod == 'Daily'
                            ? 'time(s) per day'
                            : 'time(s) per ${selectedPeriod.substring(0, selectedPeriod.length - 2).toLowerCase()}',
                        // Removes 'ly' from adverbs
                        style: kSubHeadingTextStyle,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  selectedPeriod == 'Daily'
                      ? Column(
                          children: [
                            const Text(
                              'Days of the week',
                              style: kHeadingTextStyle,
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                RoundedTile(
                                  onTap: () {
                                    late bool daySelected;
                                    setState(() {
                                      daySelected = daysActive.remove('Monday');
                                    });
                                    if (daySelected == false) {
                                      setState(() {
                                        daysActive.add('Monday');
                                      });
                                    }
                                    // If monday isn't yet selected, add. Else, remove.
                                  },
                                  color: daysActive.contains('Monday')
                                      ? kPrimaryColor
                                      : Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 20),
                                  child: Center(
                                    child: Text(
                                      'Mo',
                                      style: TextStyle(
                                          color: daysActive.contains('Monday')
                                              ? kBackgroundColor
                                              : Colors.white),
                                    ),
                                  ),
                                ),
                                RoundedTile(
                                  onTap: () {
                                    late bool daySelected;
                                    setState(() {
                                      daySelected =
                                          daysActive.remove('Tuesday');
                                    });
                                    if (daySelected == false) {
                                      setState(() {
                                        daysActive.add('Tuesday');
                                      });
                                    }
                                  },
                                  color: daysActive.contains('Tuesday')
                                      ? kPrimaryColor
                                      : Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 20),
                                  child: Center(
                                    child: Text(
                                      'Tu',
                                      style: TextStyle(
                                          color: daysActive.contains('Tuesday')
                                              ? kBackgroundColor
                                              : Colors.white),
                                    ),
                                  ),
                                ),
                                RoundedTile(
                                  onTap: () {
                                    late bool daySelected;
                                    setState(() {
                                      daySelected =
                                          daysActive.remove('Wednesday');
                                    });
                                    if (daySelected == false) {
                                      setState(() {
                                        daysActive.add('Wednesday');
                                      });
                                    }
                                  },
                                  color: daysActive.contains('Wednesday')
                                      ? kPrimaryColor
                                      : Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 20),
                                  child: Center(
                                    child: Text(
                                      'We',
                                      style: TextStyle(
                                          color:
                                              daysActive.contains('Wednesday')
                                                  ? kBackgroundColor
                                                  : Colors.white),
                                    ),
                                  ),
                                ),
                                RoundedTile(
                                  onTap: () {
                                    late bool daySelected;
                                    setState(() {
                                      daySelected =
                                          daysActive.remove('Thursday');
                                    });
                                    if (daySelected == false) {
                                      setState(() {
                                        daysActive.add('Thursday');
                                      });
                                    }
                                  },
                                  color: daysActive.contains('Thursday')
                                      ? kPrimaryColor
                                      : Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 20),
                                  child: Center(
                                    child: Text(
                                      'Th',
                                      style: TextStyle(
                                          color: daysActive.contains('Thursday')
                                              ? kBackgroundColor
                                              : Colors.white),
                                    ),
                                  ),
                                ),
                                RoundedTile(
                                  onTap: () {
                                    late bool daySelected;
                                    setState(() {
                                      daySelected = daysActive.remove('Friday');
                                    });
                                    if (daySelected == false) {
                                      setState(() {
                                        daysActive.add('Friday');
                                      });
                                    }
                                  },
                                  color: daysActive.contains('Friday')
                                      ? kPrimaryColor
                                      : Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 20),
                                  child: Center(
                                    child: Text(
                                      'Fr',
                                      style: TextStyle(
                                          color: daysActive.contains('Friday')
                                              ? kBackgroundColor
                                              : Colors.white),
                                    ),
                                  ),
                                ),
                                RoundedTile(
                                  onTap: () {
                                    late bool daySelected;
                                    setState(() {
                                      daySelected =
                                          daysActive.remove('Saturday');
                                    });
                                    if (daySelected == false) {
                                      setState(() {
                                        daysActive.add('Saturday');
                                      });
                                    }
                                  },
                                  color: daysActive.contains('Saturday')
                                      ? kPrimaryColor
                                      : Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 20),
                                  child: Center(
                                    child: Text(
                                      'Sa',
                                      style: TextStyle(
                                          color: daysActive.contains('Saturday')
                                              ? kBackgroundColor
                                              : Colors.white),
                                    ),
                                  ),
                                ),
                                RoundedTile(
                                  onTap: () {
                                    late bool daySelected;
                                    setState(() {
                                      daySelected = daysActive.remove('Sunday');
                                    });
                                    if (daySelected == false) {
                                      setState(() {
                                        daysActive.add('Sunday');
                                      });
                                    }
                                  },
                                  color: daysActive.contains('Sunday')
                                      ? kPrimaryColor
                                      : Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 20),
                                  child: Center(
                                    child: Text(
                                      'Su',
                                      style: TextStyle(
                                          color: daysActive.contains('Sunday')
                                              ? kBackgroundColor
                                              : Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                          ],
                        )
                      : Container(),
                  ElevatedButton(
                    onPressed: () {
                      DateTime today = DateTime.now();
                      DateTime habitDueDate;
                      if (selectedPeriod == 'Daily') {
                        habitDueDate = today;
                      } else if (selectedPeriod == 'Weekly') {
                        habitDueDate = today.add(Duration(
                            days: (DateTime.daysPerWeek) - (today.weekday)));
                      } else {
                        habitDueDate = today.add(const Duration(days: 30));
                        // Defaulting motnh to 30 days, may change later.
                      }
                      Provider.of<HabitManager>(context, listen: false)
                          .addHabit(
                        Habit(
                            title: habitTitle,
                            dateCreated: DateTime.now(),
                            resetPeriod: selectedPeriod,
                            requiredDatesOfCompletion: daysActive,
                            requiredCompletions: habitCompletions),
                      );
                      Provider.of<HabitManager>(context, listen: false)
                          .updateHabits(context);
                      print(daysActive);
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
    );
  }
}
