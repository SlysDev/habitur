import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';

class DaysOfWeekSelector extends StatelessWidget {
  const DaysOfWeekSelector({
    super.key,
    required this.selectedDays,
    required this.onDayToggled,
  });

  final List<String> selectedDays;
  final ValueChanged<String> onDayToggled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Days',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
            'Sunday'
          ].map((day) {
            bool isSelected = selectedDays.contains(day);
            return FilterChip(
              selected: isSelected,
              label: Text(day.substring(0, 3)),
              onSelected: (selected) => onDayToggled(day),
              backgroundColor: kFadedBlue.withOpacity(0.5),
              selectedColor: kPrimaryColor,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
