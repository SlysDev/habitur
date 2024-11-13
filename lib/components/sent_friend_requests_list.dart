import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitur/providers/friends_manager.dart';
import 'package:habitur/models/friend_request.dart';
import 'package:habitur/data/remote/user_database.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../constants.dart';
import '../models/user.dart';

class SentFriendRequestsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FriendRequest>>(
      stream: Provider.of<FriendsManager>(context).sentFriendRequestsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No sent friend requests.');
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            FriendRequest request = snapshot.data![index];
            return FutureBuilder<UserModel?>(
              future: UserDatabase().getUserModelById(request.recipientUid),
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
                UserModel recipient = userSnapshot.data!;
                String relativeDate = timeago.format(request.dateSent);
                return Opacity(
                  opacity: request.isAccepted || request.isDeclined ? 0.5 : 1,
                  child: Container(
                    color: request.isAccepted
                        ? kFadedGreen.withOpacity(0.4)
                        : request.isDeclined
                            ? kFadedRed.withOpacity(0.4)
                            : Colors.transparent,
                    child: ListTile(
                      title: Text(
                        recipient.username,
                      ),
                      subtitle: Text('Sent $relativeDate'),
                      trailing: Text(
                        request.isAccepted
                            ? 'Accepted'
                            : request.isDeclined
                                ? 'Declined'
                                : 'Pending',
                        style: TextStyle(
                          color: request.isAccepted
                              ? kLightGreenAccent
                              : request.isDeclined
                                  ? kLightRedAccent
                                  : null,
                        ),
                      ),
                    ),
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