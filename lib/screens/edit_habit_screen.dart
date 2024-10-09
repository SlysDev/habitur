import 'package:flutter/material.dart';
import 'package:habitur/components/loading_overlay_wrapper.dart';
import 'package:habitur/components/smart_notification_switch.dart';
import 'package:habitur/components/static_card.dart';
import 'package:habitur/data/local/habits_local_storage.dart';
import 'package:habitur/notifications/notification_scheduler.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/loading_state_provider.dart';
import 'package:habitur/providers/network_state_provider.dart';
import '../components/rounded_tile.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:provider/provider.dart';

import '../components/filled_text_field.dart';

class EditHabitScreen extends StatefulWidget {
  EditHabitScreen({required this.habitIndex});
  int habitIndex;
  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  dynamic selectedHabit;
  @override
  Widget build(BuildContext context) {
    selectedHabit ??=
        Provider.of<HabitManager>(context).habits[widget.habitIndex].copyWith();
    return Consumer<HabitManager>(builder: (context, habitManager, child) {
      return LoadingOverlayWrapper(
        child: Scaffold(
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Container(
              decoration: const BoxDecoration(
                color: kBackgroundColor,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                child: ListView(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Edit Habit',
                          style: kTitleTextStyle,
                        ),
                        const SizedBox(
                          height: 60,
                        ),
                        const Text(
                          'Name',
                          style: kHeadingTextStyle,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        FilledTextField(
                          initialValue: selectedHabit.title,
                          onChanged: (value) {
                            selectedHabit.title = value;
                          },
                          hintText: 'Enter a name here...',
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        SmartNotificationSwitch(habit: selectedHabit),
                        const SizedBox(
                          height: 40,
                        ),
                        const Text(
                          'Goal',
                          style: kHeadingTextStyle,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        StaticCard(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedHabit.resetPeriod = 'Daily';
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                          color: selectedHabit.resetPeriod ==
                                                  'Daily'
                                              ? kLightGreenAccent
                                                  .withOpacity(0.5)
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Text(
                                        'Daily',
                                        style: TextStyle(
                                            color: selectedHabit.resetPeriod ==
                                                    'Daily'
                                                ? Colors.white
                                                : kGray),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedHabit.resetPeriod = 'Weekly';
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                          color: selectedHabit.resetPeriod ==
                                                  'Weekly'
                                              ? kLightGreenAccent
                                                  .withOpacity(0.5)
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Text(
                                        'Weekly',
                                        style: TextStyle(
                                            color: selectedHabit.resetPeriod ==
                                                    'Weekly'
                                                ? Colors.white
                                                : kGray),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedHabit.resetPeriod = 'Monthly';
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                          color: selectedHabit.resetPeriod ==
                                                  'Monthly'
                                              ? kLightGreenAccent
                                                  .withOpacity(0.5)
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Text(
                                        'Monthly',
                                        style: TextStyle(
                                            color: selectedHabit.resetPeriod ==
                                                    'Monthly'
                                                ? Colors.white
                                                : kGray),
                                      ),
                                    ),
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
                                        initialValue: selectedHabit
                                            .requiredCompletions
                                            .toString(),
                                        onChanged: (value) {
                                          selectedHabit.requiredCompletions =
                                              int.parse(value);
                                        },
                                        hintText: '#'),
                                  ),
                                  SizedBox(width: 20),
                                  Text(
                                    selectedHabit.resetPeriod == 'Daily'
                                        ? 'time(s) per day'
                                        : 'time(s) per ${selectedHabit.resetPeriod.substring(0, selectedHabit.resetPeriod.length - 2).toLowerCase()}',
                                    // Removes 'ly' from adverbs
                                    style: kSubHeadingTextStyle.copyWith(
                                        color: kGray),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        selectedHabit.resetPeriod == 'Daily'
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      RoundedTile(
                                        onTap: () {
                                          late bool daySelected;
                                          setState(() {
                                            daySelected = selectedHabit
                                                .requiredDatesOfCompletion
                                                .remove('Monday');
                                          });
                                          if (daySelected == false) {
                                            setState(() {
                                              selectedHabit
                                                  .requiredDatesOfCompletion
                                                  .add('Monday');
                                            });
                                          }
                                          // If monday isn't yet selected, add. Else, remove.
                                        },
                                        color: selectedHabit
                                                .requiredDatesOfCompletion
                                                .contains('Monday')
                                            ? kPrimaryColor
                                            : Colors.transparent,
                                        child: Center(
                                          child: Text(
                                            'Mo',
                                            style: TextStyle(
                                                color: selectedHabit
                                                        .requiredDatesOfCompletion
                                                        .contains('Monday')
                                                    ? Colors.black
                                                    : Colors.white),
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 20),
                                      ),
                                      RoundedTile(
                                        onTap: () {
                                          late bool daySelected;
                                          setState(() {
                                            daySelected = selectedHabit
                                                .requiredDatesOfCompletion
                                                .remove('Tuesday');
                                          });
                                          if (daySelected == false) {
                                            setState(() {
                                              selectedHabit
                                                  .requiredDatesOfCompletion
                                                  .add('Tuesday');
                                            });
                                          }
                                        },
                                        color: selectedHabit
                                                .requiredDatesOfCompletion
                                                .contains('Tuesday')
                                            ? kPrimaryColor
                                            : Colors.transparent,
                                        child: Center(
                                          child: Text(
                                            'Tu',
                                            style: TextStyle(
                                                color: selectedHabit
                                                        .requiredDatesOfCompletion
                                                        .contains('Tuesday')
                                                    ? Colors.black
                                                    : Colors.white),
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 20),
                                      ),
                                      RoundedTile(
                                        onTap: () {
                                          late bool daySelected;
                                          setState(() {
                                            daySelected = selectedHabit
                                                .requiredDatesOfCompletion
                                                .remove('Wednesday');
                                          });
                                          if (daySelected == false) {
                                            setState(() {
                                              selectedHabit
                                                  .requiredDatesOfCompletion
                                                  .add('Wednesday');
                                            });
                                          }
                                        },
                                        color: selectedHabit
                                                .requiredDatesOfCompletion
                                                .contains('Wednesday')
                                            ? kPrimaryColor
                                            : Colors.transparent,
                                        child: Center(
                                          child: Text(
                                            'We',
                                            style: TextStyle(
                                                color: selectedHabit
                                                        .requiredDatesOfCompletion
                                                        .contains('Wednesday')
                                                    ? Colors.black
                                                    : Colors.white),
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 20),
                                      ),
                                      RoundedTile(
                                        onTap: () {
                                          late bool daySelected;
                                          setState(() {
                                            daySelected = selectedHabit
                                                .requiredDatesOfCompletion
                                                .remove('Thursday');
                                          });
                                          if (daySelected == false) {
                                            setState(() {
                                              selectedHabit
                                                  .requiredDatesOfCompletion
                                                  .add('Thursday');
                                            });
                                          }
                                        },
                                        color: selectedHabit
                                                .requiredDatesOfCompletion
                                                .contains('Thursday')
                                            ? kPrimaryColor
                                            : Colors.transparent,
                                        child: Center(
                                          child: Text(
                                            'Th',
                                            style: TextStyle(
                                                color: selectedHabit
                                                        .requiredDatesOfCompletion
                                                        .contains('Thursday')
                                                    ? Colors.black
                                                    : Colors.white),
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 20),
                                      ),
                                      RoundedTile(
                                        onTap: () {
                                          late bool daySelected;
                                          setState(() {
                                            daySelected = selectedHabit
                                                .requiredDatesOfCompletion
                                                .remove('Friday');
                                          });
                                          if (daySelected == false) {
                                            setState(() {
                                              selectedHabit
                                                  .requiredDatesOfCompletion
                                                  .add('Friday');
                                            });
                                          }
                                        },
                                        color: selectedHabit
                                                .requiredDatesOfCompletion
                                                .contains('Friday')
                                            ? kPrimaryColor
                                            : Colors.transparent,
                                        child: Center(
                                          child: Text(
                                            'Fr',
                                            style: TextStyle(
                                                color: selectedHabit
                                                        .requiredDatesOfCompletion
                                                        .contains('Friday')
                                                    ? Colors.black
                                                    : Colors.white),
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 20),
                                      ),
                                      RoundedTile(
                                        onTap: () {
                                          late bool daySelected;
                                          setState(() {
                                            daySelected = selectedHabit
                                                .requiredDatesOfCompletion
                                                .remove('Saturday');
                                          });
                                          if (daySelected == false) {
                                            setState(() {
                                              selectedHabit
                                                  .requiredDatesOfCompletion
                                                  .add('Saturday');
                                            });
                                          }
                                        },
                                        color: selectedHabit
                                                .requiredDatesOfCompletion
                                                .contains('Saturday')
                                            ? kPrimaryColor
                                            : Colors.transparent,
                                        child: Center(
                                          child: Text(
                                            'Sa',
                                            style: TextStyle(
                                                color: selectedHabit
                                                        .requiredDatesOfCompletion
                                                        .contains('Saturday')
                                                    ? Colors.black
                                                    : Colors.white),
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 20),
                                      ),
                                      RoundedTile(
                                        onTap: () {
                                          late bool daySelected;
                                          setState(() {
                                            daySelected = selectedHabit
                                                .requiredDatesOfCompletion
                                                .remove('Sunday');
                                          });
                                          if (daySelected == false) {
                                            setState(() {
                                              selectedHabit
                                                  .requiredDatesOfCompletion
                                                  .add('Sunday');
                                            });
                                          }
                                        },
                                        color: selectedHabit
                                                .requiredDatesOfCompletion
                                                .contains('Sunday')
                                            ? kPrimaryColor
                                            : Colors.transparent,
                                        child: Center(
                                          child: Text(
                                            'Su',
                                            style: TextStyle(
                                                color: selectedHabit
                                                        .requiredDatesOfCompletion
                                                        .contains('Sunday')
                                                    ? Colors.black
                                                    : Colors.white),
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
                          onPressed: () async {
                            DateTime today = DateTime.now();
                            DateTime habitDueDate;
                            if (selectedHabit.resetPeriod == 'Daily') {
                              habitDueDate = today;
                            } else if (selectedHabit.resetPeriod == 'Weekly') {
                              habitDueDate = today.add(Duration(
                                  days: (DateTime.daysPerWeek) -
                                      (today.weekday)));
                            } else {
                              habitDueDate = today.add(Duration(days: 30));
                              // Defaulting motnh to 30 days, may change later.
                            }
                            Habit editedHabit = selectedHabit;
                            selectedHabit.title = selectedHabit.title;
                            selectedHabit.resetPeriod =
                                selectedHabit.resetPeriod;
                            selectedHabit.requiredCompletions =
                                selectedHabit.requiredCompletions;
                            selectedHabit.requiredDatesOfCompletion =
                                selectedHabit.requiredDatesOfCompletion;
                            habitManager.editHabit(
                              widget.habitIndex,
                              editedHabit,
                            );
                            try {
                              Provider.of<LoadingStateProvider>(context,
                                      listen: false)
                                  .setLoading(true);
                              Database db = Database();
                              await db.habitDatabase
                                  .updateHabit(editedHabit, context);
                              Provider.of<NetworkStateProvider>(context,
                                      listen: false)
                                  .isConnected = true;
                            } catch (e) {
                              Provider.of<NetworkStateProvider>(context,
                                      listen: false)
                                  .isConnected = false;
                            }
                            Provider.of<HabitManager>(context, listen: false)
                                .updateHabits();
                            Provider.of<HabitManager>(context, listen: false)
                                .scheduleSmartHabitNotifs();
                            await Provider.of<HabitsLocalStorage>(context,
                                    listen: false)
                                .updateHabit(Provider.of<HabitManager>(context,
                                        listen: false)
                                    .habits[widget.habitIndex]);
                            Provider.of<LoadingStateProvider>(context,
                                    listen: false)
                                .setLoading(false);
                            Navigator.pop(context);
                          },
                          child: const Text('Update'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
