import 'package:flutter/material.dart';
import 'package:habitur/components/rounded_tile.dart';
import 'package:habitur/components/static_card.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/providers/days_of_week_selector_provider.dart';
import 'package:provider/provider.dart';

class DaysOfWeekSelector extends StatelessWidget {
  DaysOfWeekSelector({super.key, required this.habit});
  final Habit habit;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DaysOfWeekSelectorProvider>(
      create: (_) =>
          DaysOfWeekSelectorProvider(habit.requiredDatesOfCompletion),
      child: Consumer<DaysOfWeekSelectorProvider>(
          builder: (context, daysOfWeekSelectorProvider, child) {
        return Column(
          children: [
            Text(
              'Days of the week',
              style: kHeadingTextStyle.copyWith(color: Colors.white),
            ),
            const SizedBox(
              height: 30,
            ),
            StaticCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDayTile(
                      context, daysOfWeekSelectorProvider, 'Mo', 'Monday'),
                  _buildDayTile(
                      context, daysOfWeekSelectorProvider, 'Tu', 'Tuesday'),
                  _buildDayTile(
                      context, daysOfWeekSelectorProvider, 'We', 'Wednesday'),
                  _buildDayTile(
                      context, daysOfWeekSelectorProvider, 'Th', 'Thursday'),
                  _buildDayTile(
                      context, daysOfWeekSelectorProvider, 'Fr', 'Friday'),
                  _buildDayTile(
                      context, daysOfWeekSelectorProvider, 'Sa', 'Saturday'),
                  _buildDayTile(
                      context, daysOfWeekSelectorProvider, 'Su', 'Sunday'),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDayTile(
    BuildContext context,
    DaysOfWeekSelectorProvider provider,
    String shortDay,
    String fullDay,
  ) {
    bool isSelected = provider.isDaySelected(fullDay);

    return RoundedTile(
      onTap: () {
        provider.toggleDay(fullDay);
      },
      color: isSelected ? kPrimaryColor : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Center(
        child: Text(
          shortDay,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? kBackgroundColor : Colors.white,
          ),
        ),
      ),
    );
  }
}
