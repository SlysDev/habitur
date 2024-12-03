import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/common/ui_helpers.dart';
import 'package:habitur/ui/widgets/modern_card.dart';
import 'package:habitur/ui/widgets/primary_button.dart';
import 'package:habitur/ui/widgets/static_card.dart';
import 'package:habitur/ui/widgets/text_fields/form_text_field.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'add_habit_sheet_model.dart';

class AddHabitSheet extends StackedView<AddHabitSheetModel> {
  final Function(SheetResponse response)? completer;
  final SheetRequest request;
  const AddHabitSheet({
    Key? key,
    required this.completer,
    required this.request,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AddHabitSheetModel viewModel,
    Widget? child,
  ) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: const BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Title bar
            Text(
              'New Habit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
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

                  // Create button
                  PrimaryButton(
                    onPressed: viewModel.isBusy ? () {} : viewModel.createHabit,
                    text: viewModel.isBusy ? '...' : 'Create Habit',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildResetPeriodSelector(AddHabitSheetModel model) {
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

  Widget _buildDaySelector(AddHabitSheetModel model) {
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
            bool isSelected = model.selectedDays.contains(day);
            return FilterChip(
              selected: isSelected,
              label: Text(day.substring(0, 3)),
              onSelected: (selected) => model.toggleDay(day),
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

  Widget _buildTargetGoalSelector(AddHabitSheetModel model) {
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

  Widget _buildSmartNotificationsToggle(
      AddHabitSheetModel model, BuildContext context) {
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
        onChanged: model.setSmartNotifications,
        value: model.smartNotificationsEnabled,
      ),
    );
    return SwitchListTile(
      title: const Text(
        'Smart Notifications',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
      ),
      subtitle: const Text(
        'Get reminded at optimal times',
        style: TextStyle(
          color: Colors.white38,
          fontSize: 14,
        ),
      ),
      value: model.smartNotificationsEnabled,
      onChanged: model.setSmartNotifications,
      activeColor: kPrimaryColor,
    );
  }

  @override
  AddHabitSheetModel viewModelBuilder(BuildContext context) =>
      AddHabitSheetModel();
}
