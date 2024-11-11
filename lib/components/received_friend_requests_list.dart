import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/models/friend_request.dart';
import 'package:habitur/providers/database.dart';

import '../data/remote/friends_database.dart';
import '../models/user.dart';

class ReceivedFriendRequestsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserModel user = Provider.of<UserLocalStorage>(context).currentUser;

    return ListView.builder(
      shrinkWrap: true,
      itemCount: user.receivedFriendRequests.length,
      itemBuilder: (context, index) {
        FriendRequest request = user.receivedFriendRequests[index];
        return ListTile(
          title: Text(request.senderUid),
          subtitle: Text('Sent on: ${request.dateSent}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  Provider.of<FriendsDatabase>(context, listen: false)
                      .acceptFriendRequest(request, context);
                },
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Provider.of<FriendsDatabase>(context, listen: false)
                      .declineFriendRequest(request, context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}