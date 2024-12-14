import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'edit_shared_habit_viewmodel.dart';

class EditSharedHabitView extends StackedView<EditSharedHabitViewModel> {
  const EditSharedHabitView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    EditSharedHabitViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
      ),
    );
  }

  @override
  EditSharedHabitViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      EditSharedHabitViewModel();
}
