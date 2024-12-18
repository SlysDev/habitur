import 'package:flutter/material.dart';
import 'package:habitur/components/habit_stats_card.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:provider/provider.dart';
import '../constants.dart';

class HabitStatsCardList extends StatelessWidget {
  const HabitStatsCardList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: Provider.of<HabitManager>(context).habits.length,
      itemBuilder: (BuildContext context, int index) => HabitStatsCard(
          habit: Provider.of<HabitManager>(context).habits[index]),
    );
  }
}
