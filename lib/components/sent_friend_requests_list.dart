import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/models/friend_request.dart';

import '../models/user.dart';

class SentFriendRequestsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserModel user = Provider.of<UserLocalStorage>(context).currentUser;

    return ListView.builder(
      shrinkWrap: true,
      itemCount: user.sentFriendRequests.length,
      itemBuilder: (context, index) {
        FriendRequest request = user.sentFriendRequests[index];
        return ListTile(
          title: Text(request.recipientUid),
          subtitle: Text('Sent on: ${request.dateSent}'),
          trailing: Text(request.isAccepted ? 'Accepted' : 'Pending'),
        );
      },
    );
  }
}