import 'package:flutter/material.dart';
import 'package:habitur/ui/common/ui_helpers.dart';
import 'package:habitur/ui/widgets/modern_card.dart';
import 'package:habitur/ui/widgets/primary_button.dart';
import 'package:habitur/ui/widgets/text_fields/form_text_field.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/constants.dart';
import 'edit_habit_viewmodel.dart';

class EditHabitView extends StackedView<EditHabitViewModel> {
  final String? habitId;

  const EditHabitView({super.key, this.habitId});

  @override
  Widget builder(
    BuildContext context,
    EditHabitViewModel viewModel,
    Widget? child,
  ) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: SafeArea(
          bottom: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Title bar
                Row(
                  children: [
                    IconButton(
                      onPressed: () => viewModel.navigateBack(),
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                    horizontalSpaceMediumNew,
                    Text(
                      'Edit Habit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                Expanded(
                  child: ListView(
                    children: [
                      SizedBox(
                        height: 16,
                      ),
                      // Habit name input
                      FormTextField(
                        label: 'Habit Name',
                        controller: viewModel.titleController,
                        hint: 'Meditate, Exercise, Read...',
                      ),
                      const SizedBox(height: 24),

                      // Smart notifications toggle
                      _buildSmartNotificationsToggle(viewModel, context),

                      const SizedBox(height: 24),

                      // Reset period selector
                      ModernCard(child: _buildResetPeriodSelector(viewModel)),
                      const SizedBox(height: 24),

                      // Days of week selector
                      viewModel.resetPeriod == 'Daily'
                          ? ModernCard(child: _buildDaySelector(viewModel))
                          : Container(),
                      viewModel.resetPeriod == 'Daily'
                          ? const SizedBox(height: 24)
                          : Container(),

                      // Target goal selector
                      ModernCard(child: _buildTargetGoalSelector(viewModel)),
                      const SizedBox(height: 40),

                      // Save button
                      PrimaryButton(
                        onPressed: viewModel.isBusy
                            ? () {}
                            : () {
                                viewModel.saveHabit();
                                viewModel.navigateBack();
                              },
                        text: viewModel.isBusy ? '...' : 'Save Habit',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmartNotificationsToggle(
      EditHabitViewModel model, BuildContext context) {
    return ModernCard(
      color: kFadedGreen,
      opacity: 0.1,
      padding: 10,
      child: SwitchListTile.adaptive(
        title: Row(
          children: [
            Icon(
              Icons.bolt,
              color: kLightGreenAccent,
              size: 30,
            ),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: Text(
                  screenWidth(context) > 400
                      ? 'Smart Notifications'
                      : 'Smart \n Notifications',
                  textAlign: TextAlign.center,
                  style: kMainDescription.copyWith(fontSize: 16)),
            ),
          ],
        ),
        onChanged: model.setSmartNotifs,
        value: model.smartNotifsEnabled,
      ),
    );
  }

  Widget _buildResetPeriodSelector(EditHabitViewModel model) {
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
            bool isSelected = model.resetPeriod == period;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () => model.setResetPeriod(period),
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

  Widget _buildDaySelector(EditHabitViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Days of the Week',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
            'Sunday'
          ].map((day) {
            bool isSelected = model.selectedDays.contains(day);
            return FilterChip(
              label: Text(day),
              selected: isSelected,
              onSelected: (selected) {
                model.toggleDaySelection(day);
              },
              selectedColor: kPrimaryColor,
              backgroundColor: kFadedBlue.withOpacity(0.5),
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

  Widget _buildTargetGoalSelector(EditHabitViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daily Target',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline,
                  color: Colors.white70),
              onPressed: () => model.adjustTargetGoal(-1),
            ),
            Expanded(
              child: Text(
                '${model.targetGoal} time${model.targetGoal == 1 ? '' : 's'} per ${model.resetPeriodNoun}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.white70),
              onPressed: () => model.adjustTargetGoal(1),
            ),
          ],
        ),
      ],
    );
  }

  @override
  EditHabitViewModel viewModelBuilder(BuildContext context) =>
      EditHabitViewModel(habitId: habitId ?? '');
}
