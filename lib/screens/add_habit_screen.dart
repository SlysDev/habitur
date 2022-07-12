import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/providers/user_data.dart';
import 'package:provider/provider.dart';

import '../components/filled_text_field.dart';

int? selectedHabit = 0;
String habitTitle = '';
int habitCompletions = 1;
String selectedPeriod = 'Daily';
List daysActive = [
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
      height: MediaQuery.of(context).size.height * 0.9,
      color: const Color(0xff757575),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
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
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: selectedPeriod == 'Daily'
                                    ? kNeutralBlue
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              'Daily',
                              style: TextStyle(
                                  color: selectedPeriod == 'Daily'
                                      ? Colors.white
                                      : Colors.black),
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
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: selectedPeriod == 'Weekly'
                                    ? kNeutralBlue
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              'Weekly',
                              style: TextStyle(
                                  color: selectedPeriod == 'Weekly'
                                      ? Colors.white
                                      : Colors.black),
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
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: selectedPeriod == 'Monthly'
                                    ? kNeutralBlue
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              'Monthly',
                              style: TextStyle(
                                  color: selectedPeriod == 'Monthly'
                                      ? Colors.white
                                      : Colors.black),
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
                  SizedBox(
                    height: 20,
                  ),
                  selectedPeriod == 'Daily'
                      ? Column(
                          children: [
                            Text(
                              'Days of the week',
                              style: kHeadingTextStyle,
                            ),
                            SizedBox(
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
                                      ? kNeutralBlue
                                      : Colors.transparent,
                                  child: Center(
                                    child: Text(
                                      'Mo',
                                      style: TextStyle(
                                          color: daysActive.contains('Monday')
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 20),
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
                                      ? kNeutralBlue
                                      : Colors.transparent,
                                  child: Center(
                                    child: Text(
                                      'Tu',
                                      style: TextStyle(
                                          color: daysActive.contains('Tuesday')
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 20),
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
                                      ? kNeutralBlue
                                      : Colors.transparent,
                                  child: Center(
                                    child: Text(
                                      'We',
                                      style: TextStyle(
                                          color:
                                              daysActive.contains('Wednesday')
                                                  ? Colors.white
                                                  : Colors.black),
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 20),
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
                                      ? kNeutralBlue
                                      : Colors.transparent,
                                  child: Center(
                                    child: Text(
                                      'Th',
                                      style: TextStyle(
                                          color: daysActive.contains('Thursday')
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 20),
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
                                      ? kNeutralBlue
                                      : Colors.transparent,
                                  child: Center(
                                    child: Text(
                                      'Fr',
                                      style: TextStyle(
                                          color: daysActive.contains('Friday')
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 20),
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
                                      ? kNeutralBlue
                                      : Colors.transparent,
                                  child: Center(
                                    child: Text(
                                      'Sa',
                                      style: TextStyle(
                                          color: daysActive.contains('Saturday')
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 20),
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
                                      ? kNeutralBlue
                                      : Colors.transparent,
                                  child: Center(
                                    child: Text(
                                      'Su',
                                      style: TextStyle(
                                          color: daysActive.contains('Sunday')
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 20),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 30,
                            ),
                          ],
                        )
                      : Container(),
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<UserData>(context, listen: false)
                          .addUserHabit(
                        Habit(
                            title: habitTitle,
                            category: '',
                            difficulty: 0,
                            requiredCompletions: habitCompletions),
                      );
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

class RoundedTile extends StatelessWidget {
  final Widget child;
  final void Function() onTap;
  final Color color;
  final EdgeInsets padding;
  const RoundedTile(
      {required this.color,
      required this.child,
      required this.onTap,
      this.padding = const EdgeInsets.all(10)});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.all(2),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: color,
          ),
          child: child,
        ),
      ),
    );
  }
}
