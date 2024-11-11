import 'package:flutter/material.dart';
import 'package:habitur/providers/friends_manager.dart';
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
                    title: Text('Loading...'),
                  );
                }
                if (!userSnapshot.hasData) {
                  return ListTile(
                    title: Text('User not found'),
                  );
                }
                UserModel sender = userSnapshot.data!;
                String relativeDate = timeago.format(request.dateSent);
                bool isAccepted = request
                    .isAccepted; // Assuming you have this property in your model

                return ListTile(
                  title: Text(sender.username),
                  subtitle: Text('Sent $relativeDate'),
                  trailing: isAccepted
                      ? null
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check),
                              onPressed: () async {
                                await friendsManager.acceptFriendRequest(
                                    request, context);
                                request.isAccepted =
                                    true; // Update the request status
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () async {
                                await friendsManager.declineFriendRequest(
                                    request, context);
                              },
                            ),
                          ],
                        ),
                  tileColor: isAccepted ? Colors.grey.withOpacity(0.5) : null,
                );
              },
            );
          },
        );
      },
    );
  }
}
