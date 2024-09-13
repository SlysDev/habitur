import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';

class DaysOfWeekWidget extends StatelessWidget {
  // This will help us get the days of the week in abbreviation form (e.g., "Mo", "Tu")
  final List<String> days = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"];

  @override
  Widget build(BuildContext context) {
    // Get the current day index (Monday = 0, Sunday = 6)
    int currentDayIndex = DateTime.now().weekday - 1;
    debugPrint(currentDayIndex.toString());

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(days.length, (index) {
        bool isToday = index == currentDayIndex;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Container(
            decoration: BoxDecoration(
              color: isToday
                  ? kGray
                  : kFadedBlue, // Light blue for today, faded blue for others
              borderRadius: BorderRadius.circular(10), // Curved edges
            ),
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Text(
              days[index],
              style: TextStyle(
                color: isToday
                    ? Colors.white
                    : kGray, // White for today, gray for others
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }
}
