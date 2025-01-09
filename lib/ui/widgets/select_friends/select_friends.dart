import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/ui/widgets/user_avatar/user_avatar.dart';
import 'select_friends_model.dart';

class SelectFriendsWidget extends StackedView<SelectFriendsModel> {
  final Function(List<UserModel>)? onSelectedFriendsChanged;
  final bool multiSelect;
  final List<UserModel>? initialSelectedFriends;

  const SelectFriendsWidget({
    Key? key,
    this.onSelectedFriendsChanged,
    this.multiSelect = true,
    this.initialSelectedFriends,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    SelectFriendsModel viewModel,
    Widget? child,
  ) {
    return Column(
      children: [
        // Search Bar
        _buildSearchBar(viewModel),
        const SizedBox(height: 16),

        // Friends List
        Expanded(
          child: _buildFriendsList(context, viewModel),
        ),
      ],
    );
  }

  Widget _buildSearchBar(SelectFriendsModel viewModel) {
    return TextField(
      onChanged: viewModel.setSearchQuery,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search friends...',
        hintStyle: const TextStyle(color: kGray),
        prefixIcon: Icon(Icons.search, color: kPrimaryColor),
        filled: true,
        fillColor: kFadedBlue,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kPrimaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildFriendsList(
    BuildContext context,
    SelectFriendsModel viewModel,
  ) {
    // Error state
    if (viewModel.hasError) {
      return Center(
        child: Text(
          'Error loading friends: ${viewModel.error}',
          style: const TextStyle(color: kLightRedAccent),
        ),
      );
    }

    // Loading state
    if (viewModel.isBusy) {
      return const Center(
        child: CircularProgressIndicator(
          color: kPrimaryColor,
        ),
      );
    }

    // No friends state
    final friendIds = viewModel.filteredFriendIds;
    if (friendIds.isEmpty) {
      return const Center(
        child: Text(
          'No friends found',
          style: TextStyle(color: kGray),
        ),
      );
    }

    // Friends list
    return ListView.separated(
      itemCount: friendIds.length,
      separatorBuilder: (context, index) => const Divider(
        color: kFadedBlue,
        height: 1,
      ),
      itemBuilder: (context, index) {
        final friendId = friendIds[index];
        return FutureBuilder<UserModel>(
          future: viewModel.getFriendById(friendId),
          builder: (context, snapshot) {
            // Loading or error state for individual friend
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final friend = snapshot.data!;
            return _buildFriendListItem(context, viewModel, friend);
          },
        );
      },
    );
  }

  Widget _buildFriendListItem(
    BuildContext context,
    SelectFriendsModel viewModel,
    UserModel friend,
  ) {
    final isSelected = viewModel.isSelected(friend);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: UserAvatar(
        username: friend.username,
      ),
      title: Text(
        friend.username,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: multiSelect
          ? Checkbox(
              activeColor: kPrimaryColor,
              checkColor: kBackgroundColor,
              value: isSelected,
              onChanged: (selected) {
                if (selected != null) {
                  viewModel.toggleFriendSelection(friend);
                  onSelectedFriendsChanged?.call(
                    viewModel.selectedFriends.toList(),
                  );
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            )
          : Radio<bool>(
              activeColor: kPrimaryColor,
              value: true,
              groupValue: isSelected,
              onChanged: (_) {
                // Deselect all other friends if not multi-select
                viewModel.selectedFriends.clear();
                viewModel.toggleFriendSelection(friend);
                onSelectedFriendsChanged?.call(
                  viewModel.selectedFriends.toList(),
                );
              },
            ),
      onTap: () {
        viewModel.toggleFriendSelection(friend);
        onSelectedFriendsChanged?.call(
          viewModel.selectedFriends.toList(),
        );
      },
    );
  }

  @override
  SelectFriendsModel viewModelBuilder(BuildContext context) =>
      SelectFriendsModel(initialSelectedFriends: initialSelectedFriends);
}
