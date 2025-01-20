import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/widgets/habit_form/habit_form.dart';
import 'package:habitur/ui/widgets/primary_button.dart';
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
              child: HabitForm(
                onSubmit: viewModel.createHabit,
                submitButtonText: viewModel.isBusy ? '...' : 'Create Habit',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  AddHabitSheetModel viewModelBuilder(BuildContext context) => AddHabitSheetModel();
}
