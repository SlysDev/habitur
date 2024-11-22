import 'package:flutter/material.dart';
import 'package:habitur/components/user_avatar.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/modules/friends_manager.dart';
import 'package:habitur/models/friend_request.dart';
import 'package:habitur/data/remote/user_database.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/user.dart';

class ReceivedFriendRequestsList extends StatelessWidget {
  final FriendsManager friendsManager = FriendsManager();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FriendRequest>>(
      stream: friendsManager.receivedFriendRequestsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: EdgeInsets.all(16.0),
            child: Text('No received friend requests.'),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data!.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            FriendRequest request = snapshot.data![index];
            return FutureBuilder<UserModel?>(
              future: UserDatabase().getUserModelById(request.senderUid),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(
                    leading: CircularProgressIndicator(),
                    title: Text('Loading...'),
                  );
                }
                if (!userSnapshot.hasData) {
                  return ListTile(
                    leading: UserAvatar(username: '?'),
                    title: Text('User not found'),
                  );
                }
                UserModel sender = userSnapshot.data!;
                String relativeDate = timeago.format(request.dateSent);

                return Container(
              decoration: BoxDecoration(
                  color: kFadedBlue.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: kFadedBlue.withOpacity(0.6),
                  width: 1,
                ),
              ),
                  margin: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: UserAvatar(
                          username: sender.username,
                          size: 40.0,
                        ),
                        title: Text(sender.username, style: TextStyle(fontSize: 16)),
                        trailing: request.isAccepted
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.check, color: Colors.green),
                                    onPressed: () async {
                                      await friendsManager.acceptFriendRequest(
                                          request, context);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, color: Colors.red),
                                    onPressed: () async {
                                      await friendsManager.declineFriendRequest(
                                          request, context);
                                    },
                                  ),
                                ],
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, bottom: 8.0, left: 64.0),
                        child: Text('Sent $relativeDate', style: TextStyle(fontSize: 14)),
                      ),
                    ],
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
