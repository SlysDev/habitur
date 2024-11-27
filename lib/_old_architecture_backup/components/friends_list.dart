import 'package:flutter/material.dart';
import 'package:habitur/components/profile_dialog.dart';
import 'package:habitur/components/stat-chips/confidence_level_stat_chip.dart';
import 'package:habitur/components/stat-chips/stat_chip.dart';
import 'package:habitur/components/user_avatar.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/modules/friends_manager.dart';
import 'package:habitur/data/remote/user_database.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/user.dart';

class FriendsList extends StatelessWidget {
  final FriendsManager friendsManager = FriendsManager();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: friendsManager.friendsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: EdgeInsets.all(16.0),
            child: Text('No friends found.'),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data!.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            String friendUid = snapshot.data![index];
            return FutureBuilder<UserModel?>(
              future: UserDatabase().getUserModelById(friendUid),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(
                    title: Text('Loading...'),
                  );
                }
                if (!userSnapshot.hasData) {
                  return ListTile(
                    title: Text('User not found'),
                  );
                }
                UserModel friend = userSnapshot.data!;
                return ListTile(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ProfileDialog(
                          uid: friend.uid,
                          isFriendProfile: true,
                        );
                      },
                    );
                  },
                  leading: UserAvatar(username: friend.username),
                  title: Text(friend.username),
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
      },
    );
  }
}
