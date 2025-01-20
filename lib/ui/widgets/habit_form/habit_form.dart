import 'package:flutter/material.dart';
import 'package:habitur/ui/widgets/day_of_week_selector/day_of_week_selector.dart';
import 'package:habitur/ui/widgets/measurement_toggle/measurement_toggle.dart';
import 'package:habitur/ui/widgets/modern_card.dart';
import 'package:habitur/ui/widgets/reset_period_selector/reset_period_selector.dart';
import 'package:habitur/ui/widgets/smart_notifications_toggle/smart_notifications_toggle.dart';
import 'package:habitur/ui/widgets/target_goal_selector/target_goal_selector.dart';
import 'package:habitur/ui/widgets/text_fields/form_text_field.dart';
// ... other imports

class HabitForm extends StatelessWidget {
  final TextEditingController titleController;
  final String resetPeriod;
  final int targetGoal;
  final bool smartNotificationsEnabled;
  final List<String> selectedDays;
  final bool usesMeasurement;
  final String measurementUnit;
  final Function(String) onResetPeriodChanged;
  final Function(int) onTargetGoalChanged;
  final Function(bool) onSmartNotificationsChanged;
  final Function(String) onDayToggled;
  final Function(bool) onUsesMeasurementChanged;
  final Function(String) onMeasurementUnitChanged;
  final Widget submitButton;

  const HabitForm({
    Key? key,
    required this.titleController,
    required this.resetPeriod,
    required this.targetGoal,
    required this.smartNotificationsEnabled,
    required this.selectedDays,
    required this.usesMeasurement,
    required this.measurementUnit,
    required this.onResetPeriodChanged,
    required this.onTargetGoalChanged,
    required this.onSmartNotificationsChanged,
    required this.onDayToggled,
    required this.onUsesMeasurementChanged,
    required this.onMeasurementUnitChanged,
    required this.submitButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 16),
        FormTextField(
          label: 'Habit Name',
          controller: titleController,
          hint: 'Meditate, Exercise, Read...',
        ),
        const SizedBox(height: 24),

        SmartNotificationsToggle(
          smartNotificationsEnabled: smartNotificationsEnabled,
          onSmartNotificationsChanged: onSmartNotificationsChanged,
        ),
        const SizedBox(height: 24),

        ModernCard(
          child: ResetPeriodSelector(
            resetPeriod: resetPeriod,
            onResetPeriodChanged: onResetPeriodChanged,
          ),
        ),
        const SizedBox(height: 24),

        if (resetPeriod == 'Daily') ...[
          ModernCard(
            child: DaysOfWeekSelector(
              selectedDays: selectedDays,
              onDayToggled: onDayToggled,
            ),
          ),
          const SizedBox(height: 24),
        ],

        ModernCard(
          child: TargetGoalSelector(
            targetGoal: targetGoal,
            resetPeriodNoun: _getResetPeriodNoun(resetPeriod),
            onTargetGoalChanged: onTargetGoalChanged,
          ),
        ),
        const SizedBox(height: 24),

        MeasurementToggle(
          usesMeasurement: usesMeasurement,
          measurementUnit: measurementUnit,
          onUsesMeasurementChanged: onUsesMeasurementChanged,
          onMeasurementUnitChanged: onMeasurementUnitChanged,
        ),
        const SizedBox(height: 40),

        submitButton,
      ],
    );
  }

  String _getResetPeriodNoun(String period) {
    switch (period) {
      case 'Daily': return 'day';
      case 'Weekly': return 'week';
      case 'Monthly': return 'month';
      default: return 'day';
    }
  }
}
