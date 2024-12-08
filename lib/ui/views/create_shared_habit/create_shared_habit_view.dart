import 'package:flutter/material.dart';
import 'package:habitur/ui/common/app_colors.dart';
import 'package:habitur/ui/widgets/user_avatar/user_avatar.dart';
import 'package:stacked/stacked.dart';
import 'create_shared_habit_viewmodel.dart';

class CreateSharedHabitView extends StackedView<CreateSharedHabitViewModel> {
  const CreateSharedHabitView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    CreateSharedHabitViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Create Shared Habit',
          style: TextStyle(color: kcPrimaryColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHabitNameField(context, viewModel),
            const SizedBox(height: 24),
            _buildHabitTypeSelector(context, viewModel),
            const SizedBox(height: 24),
            _buildFrequencySection(context, viewModel),
            const SizedBox(height: 24),
            _buildParticipantsSection(context, viewModel),
            const SizedBox(height: 24),
            _buildDescriptionField(context, viewModel),
            const SizedBox(height: 32),
            _buildCreateButton(context, viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitNameField(
      BuildContext context, CreateSharedHabitViewModel viewModel) {
    return TextField(
      controller: viewModel.titleController,
      decoration: const InputDecoration(
        labelText: 'Habit Name',
        hintText: 'Enter a name for your shared habit',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildHabitTypeSelector(
      BuildContext context, CreateSharedHabitViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Habit Type',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: kcPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: viewModel.habitTypes.map((type) {
            return ChoiceChip(
              label: Text(type),
              selected: viewModel.selectedHabitType == type,
              onSelected: (selected) {
                if (selected) {
                  viewModel.setHabitType(type);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFrequencySection(
      BuildContext context, CreateSharedHabitViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequency',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: kcPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: viewModel.targetGoalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Goal',
                  hintText: 'Times per day',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: viewModel.selectedFrequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(),
                ),
                items: viewModel.frequencies
                    .map((freq) => DropdownMenuItem(
                          value: freq,
                          child: Text(freq),
                        ))
                    .toList(),
                onChanged: viewModel.setFrequency,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildParticipantsSection(
      BuildContext context, CreateSharedHabitViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Participants',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: kcPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton.icon(
              onPressed: viewModel.addParticipants,
              icon: const Icon(Icons.person_add),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (viewModel.selectedParticipants.isEmpty)
          const Center(
            child: Text(
              'No participants added yet',
              style: TextStyle(color: kcMediumGrey),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: viewModel.selectedParticipants.map((user) {
              return Chip(
                avatar: UserAvatar(user: user, size: 24),
                label: Text(user.username),
                onDeleted: () => viewModel.removeParticipant(user),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildDescriptionField(
      BuildContext context, CreateSharedHabitViewModel viewModel) {
    return TextField(
      controller: viewModel.descriptionController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Description (Optional)',
        hintText: 'Add a description for your shared habit',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildCreateButton(
      BuildContext context, CreateSharedHabitViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: viewModel.isBusy ? null : viewModel.createSharedHabit,
        style: ElevatedButton.styleFrom(
          backgroundColor: kcAccentColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: viewModel.isBusy
            ? const CircularProgressIndicator()
            : const Text(
                'Create Shared Habit',
                style: TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  @override
  CreateSharedHabitViewModel viewModelBuilder(BuildContext context) =>
      CreateSharedHabitViewModel();
}
