import 'package:flutter/material.dart';
import 'package:habitur/components/habit_card.dart';
import 'package:habitur/components/inactive_habit_card.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/modules/habit_stats_handler.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/providers/user_data.dart';
import 'package:habitur/screens/edit_habit_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HabitCardList extends StatelessWidget {
  bool isOnline;
  HabitCardList({context, this.isOnline = true});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        width: double.infinity,
        child: RefreshIndicator(
          backgroundColor: kPrimaryColor,
          color: Colors.white,
          onRefresh: () async {},
          child: ListView.builder(
              itemBuilder: (context, index) {
                Provider.of<HabitManager>(context, listen: false).sortHabits();
                return Provider.of<HabitManager>(context)
                        .sortedHabits[index]
                        .requiredDatesOfCompletion
                        .contains(DateFormat('EEEE').format(DateTime.now()))
                    ? Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          HabitCard(
                            index: index,
                          ),
                          // color: Provider.of<HabitManager>(context, listen: false).habits[index].color),
                          SizedBox(
                            height: 20,
                          )
                        ],
                      )
                    : Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          InactiveHabitCard(
                            index: index,
                          ),
                          // color: Provider.of<HabitManager>(context, listen: false).habits[index].color),
                          SizedBox(
                            height: 20,
                          )
                        ],
                      );
              },
              itemCount: Provider.of<HabitManager>(context).habits.length),
        ),
      ),
    );
  }
}
