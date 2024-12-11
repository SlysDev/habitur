import 'package:flutter/material.dart';
import 'package:habitur/models/shared_habit.dart';
import 'package:habitur/ui/common/app_colors.dart';
import 'package:habitur/ui/widgets/user_avatar/user_avatar.dart';
import 'package:stacked/stacked.dart';
import 'invite_participants_viewmodel.dart';

class InviteParticipantsView extends StackedView<InviteParticipantsViewModel> {
  const InviteParticipantsView({Key? key, required this.sharedHabit})
      : super(key: key);

  final SharedHabit sharedHabit;

  @override
  Widget builder(
    BuildContext context,
    InviteParticipantsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Invite Friends',
          style: TextStyle(color: kcPrimaryColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(context, viewModel),
          Expanded(
            child: _buildFriendsList(context, viewModel),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, viewModel),
    );
  }

  Widget _buildSearchBar(
      BuildContext context, InviteParticipantsViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: viewModel.searchController,
        onChanged: viewModel.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search friends...',
          prefixIcon: const Icon(Icons.search, color: kcMediumGrey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: kcLightGrey.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildFriendsList(
      BuildContext context, InviteParticipantsViewModel viewModel) {
    if (viewModel.isBusy) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.filteredFriends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_outlined,
              size: 64,
              color: kcPrimaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              viewModel.searchController.text.isEmpty
                  ? 'No friends found'
                  : 'No matching friends found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: kcMediumGrey,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: viewModel.filteredFriends.length,
      itemBuilder: (context, index) {
        final friend = viewModel.filteredFriends[index];
        final isSelected = viewModel.isSelected(friend);
        final isExistingParticipant = viewModel.isExistingParticipant(friend);

        return ListTile(
          leading: UserAvatar(
            username: friend.username,
            size: 40,
          ),
          title: Text(friend.username),
          subtitle: isExistingParticipant
              ? const Text(
                  'Already participating',
                  style: TextStyle(color: kcAccentColor),
                )
              : null,
          trailing: isExistingParticipant
              ? const Icon(Icons.check_circle, color: kcAccentColor)
              : Checkbox(
                  value: isSelected,
                  onChanged: isExistingParticipant
                      ? null
                      : (value) => viewModel.toggleFriendSelection(friend),
                  activeColor: kcAccentColor,
                ),
          enabled: !isExistingParticipant,
          onTap: isExistingParticipant
              ? null
              : () => viewModel.toggleFriendSelection(friend),
        );
      },
    );
  }

  Widget _buildBottomBar(
      BuildContext context, InviteParticipantsViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${viewModel.selectedFriends.length} selected',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: kcPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ElevatedButton(
              onPressed: viewModel.selectedFriends.isEmpty
                  ? null
                  : viewModel.sendInvitations,
              style: ElevatedButton.styleFrom(
                backgroundColor: kcAccentColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Invite ${viewModel.selectedFriends.length} friends',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  InviteParticipantsViewModel viewModelBuilder(BuildContext context) {
    final viewModel = InviteParticipantsViewModel();
    viewModel.init(sharedHabit);
    return viewModel;
  }
}
