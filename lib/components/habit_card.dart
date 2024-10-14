import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habitur/components/custom_snack_bar.dart';
import 'package:habitur/components/habit_difficulty_popup.dart';
import 'package:habitur/data/local/habits_local_storage.dart';
import 'package:habitur/modules/habit_stats_handler.dart';
import 'package:habitur/notifications/notification_scheduler.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/providers/network_state_provider.dart';
import 'package:habitur/screens/edit_habit_screen.dart';
import 'package:habitur/screens/habit_overview_screen.dart';
import 'package:habitur/util_functions.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import './rounded_progress_bar.dart';
import 'package:confetti/confetti.dart';

class HabitCard extends StatefulWidget {
  Color color;
  int index;

  HabitCard({this.color = kFadedBlue, required this.index});

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  Color completeButtonColor = Colors.green;
  bool isLoading = false;
  late ConfettiController _controller;
  void setLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dynamic habit;
    try {
      habit = Provider.of<HabitManager>(context).habits[widget.index];
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      showDebugErrorSnackbar(context, e, s);
    }
    HabitStatsHandler habitStatsHandler = HabitStatsHandler(habit);
    Database db = Database();
    double progress = habit.completionsToday / habit.requiredCompletions;
    bool completed = habit.completionsToday == habit.requiredCompletions;
    Future<void> completeHabit(double recordedDifficulty) async {
      if (habit.completionsToday != habit.requiredCompletions) {
        await habitStatsHandler.incrementCompletion(context,
            recordedDifficulty: recordedDifficulty);
        if (Provider.of<NetworkStateProvider>(context, listen: false)
            .isConnected) {
          await db.habitDatabase.updateHabit(
              Provider.of<HabitManager>(context, listen: false)
                  .habits[widget.index],
              context);
        }
        await Provider.of<HabitsLocalStorage>(context, listen: false)
            .updateHabit(Provider.of<HabitManager>(context, listen: false)
                .habits[widget.index]);
        Provider.of<HabitManager>(context, listen: false).updateHabits();
        NotificationScheduler notificationScheduler = NotificationScheduler();
        notificationScheduler.cancelHabitSchedule(habit.id);
        notificationScheduler.scheduleHabitReminderTrack(habit,
            delay: Duration(
                days: habit.resetPeriod == "Daily"
                    ? 1
                    : habit.resetPeriod == "Weekly"
                        ? 7
                        : 31)); // schedule notifs for next period
      }
    }

    Future<void> decrementHabit() async {
      await habitStatsHandler.decrementCompletion(context);
      await db.habitDatabase.updateHabit(
          Provider.of<HabitManager>(context, listen: false)
              .habits[widget.index],
          context);
      await Provider.of<HabitsLocalStorage>(context, listen: false).updateHabit(
          Provider.of<HabitManager>(context, listen: false)
              .habits[widget.index]);
      Provider.of<HabitManager>(context, listen: false).updateHabits();
    }

    void editHabit() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EditHabitScreen(
                    habitIndex: widget.index,
                  )));
    }

    Future<void> deleteHabit() async {
      await Provider.of<HabitManager>(context, listen: false)
          .deleteHabit(context, widget.index);
      debugPrint(Provider.of<HabitsLocalStorage>(context, listen: false)
          .stringifyHabitData(context));
    }

    Future<void> difficultyPopup(
        BuildContext context, index, onDifficultySelected) async {
      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => HabitDifficultyPopup(
          habitIndex: index,
          onDifficultySelected: onDifficultySelected,
        ),
      );
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      curve: Curves.fastOutSlowIn,
      opacity: isLoading ? 0.6 : 1,
      child: Stack(
        children: [
          GestureDetector(
            onLongPress: () {
              habit.lastSeen = DateTime.now().subtract(const Duration(days: 1));
            },
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HabitOverviewScreen(
                            habit: habit,
                          )));
            },
            child: Slidable(
              startActionPane: ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    autoClose: true,
                    onPressed: (context) async {
                      setLoading(true);
                      await deleteHabit();
                      setLoading(false);
                    },
                    backgroundColor: kRed,
                    icon: Icons.delete,
                    borderRadius: BorderRadius.circular(20),
                    label: 'Delete',
                  ),
                  SlidableAction(
                    onPressed: (context) async {
                      editHabit();
                    },
                    backgroundColor: kDarkPrimaryColor,
                    icon: Icons.edit,
                    borderRadius: BorderRadius.circular(20),
                    label: 'Edit',
                  ),
                ],
              ),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.ease,
                    height: habit.title.length > 20
                        ? 128.0 + (habit.title.length.toDouble() * 2.15)
                        : 128,
                    decoration: BoxDecoration(
                      color: !completed
                          ? widget.color
                          : widget.color.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isLoading ? '...' : habit.title,
                                  style: kHeadingTextStyle.copyWith(
                                      color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                isLoading
                                    ? Container()
                                    : RoundedProgressBar(progress: progress),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (!completed) {
                              await difficultyPopup(context, widget.index,
                                  (recordedDifficulty) async {
                                setLoading(true);
                                await completeHabit(recordedDifficulty);
                                setLoading(false);
                              });
                              setState(() {
                                _controller.play();
                              });
                            } else {
                              showCustomSnackBar(context,
                                  "You've already completed this habit", kRed);
                            }
                          },
                          onLongPress: () async {
                            setLoading(true);
                            try {
                              await decrementHabit();
                            } catch (e, s) {
                              debugPrint(e.toString());
                              debugPrint(s.toString());
                            }
                            setLoading(false);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.ease,
                            width: 100,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.check,
                              size: 30,
                              color: kLightGreenAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 128,
            child: Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                emissionFrequency: 0,
                minBlastForce: 10,
                numberOfParticles: 10,
                blastDirectionality: BlastDirectionality.explosive,
                confettiController: _controller,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
