import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';

class ResetPeriodSelector extends StatelessWidget {
  const ResetPeriodSelector({
    super.key,
    required this.resetPeriod,
    required this.onResetPeriodChanged,
  });

  final String resetPeriod;
  final ValueChanged<String> onResetPeriodChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reset Period',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: ['Daily', 'Weekly', 'Monthly'].map((period) {
            bool isSelected = resetPeriod == period;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () => onResetPeriodChanged(period),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutSine,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? kPrimaryColor
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        period,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
