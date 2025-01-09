import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/widgets/user_avatar/user_avatar.dart';
import 'package:habitur/ui/widgets/stat-chips/stat_chip.dart';
import 'friends_list_model.dart';

class FriendsList extends StackedView<FriendsListModel> {
  const FriendsList({super.key, this.onTap});

  final void Function(dynamic)? onTap;

  @override
  Widget builder(
      BuildContext context, FriendsListModel viewModel, Widget? child) {
    if (viewModel.hasError) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Error loading friends: ${viewModel.error}',
          style: const TextStyle(color: kLightRedAccent),
        ),
      );
    }

    if (viewModel.isBusy) {
      return const Center(child: CircularProgressIndicator());
    }

    final friends = viewModel.data;
    if (friends == null || friends.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No friends found.',
          style: TextStyle(color: kGray),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friendUid = friends[index];
        return FutureBuilder(
          future: viewModel.getFriendUser(friendUid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ListTile(
                title: Text('Loading...', style: TextStyle(color: kGray)),
              );
            }

            final friend = snapshot.data;
            if (friend == null) {
              return const ListTile(
                title: Text(
                  'User not found',
                  style: TextStyle(color: kLightRedAccent),
                ),
              );
            }

            return ListTile(
              onTap: () =>
                  onTap ??
                  () {
                    viewModel.showFriendProfile(friend);
                  },
              leading: UserAvatar(username: friend.username),
              title: Text(
                friend.username,
                style: const TextStyle(color: Colors.white),
              ),
              trailing: StatChip(
                color: kPrimaryColor,
                label: friend.userLevel.toString(),
                icon: Icons.star,
              ),
            );
          },
        );
      },
    );
  }

  @override
  FriendsListModel viewModelBuilder(BuildContext context) => FriendsListModel();
}
