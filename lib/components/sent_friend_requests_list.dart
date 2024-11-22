import 'package:flutter/material.dart';
import 'package:habitur/components/profile_dialog.dart';
import 'package:provider/provider.dart';
import 'package:habitur/modules/friends_manager.dart';
import 'package:habitur/models/friend_request.dart';
import 'package:habitur/data/remote/user_database.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:habitur/components/user_avatar.dart';
import '../constants.dart';
import '../models/user.dart';

class SentFriendRequestsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FriendsManager friendsManager = FriendsManager();
    return StreamBuilder<List<FriendRequest>>(
      stream: friendsManager.sentFriendRequestsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
              padding: EdgeInsets.all(16.0),
              child: Text('No sent friend requests.'));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
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
                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ProfileDialog(
                          uid: recipient.uid,
                          isFriendProfile: true,
                        );
                      },
                    );
                  },
                  child: Opacity(
                    opacity: request.isAccepted || request.isDeclined ? 0.5 : 1,
                    child: Container(
              decoration: BoxDecoration(
                  color: kFadedBlue.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: kFadedBlue.withOpacity(0.6),
                  width: 1,
                ),
              ),
                  margin: EdgeInsets.all(16),
                  child: ListTile(
                        leading: UserAvatar(
                          username: recipient.username,
                          size: 40.0,
                        ),
                        title: Text(
                          recipient.username,
                        ),
                        subtitle: Text('Sent $relativeDate'),
                        trailing: request.isAccepted || request.isDeclined
                            ? Text(
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
                              )
                            : IconButton(
                                icon: Icon(Icons.cancel_outlined, color: kLightRedAccent),
                                onPressed: () async {
                                  await friendsManager.cancelFriendRequest(request, context);
                                },
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
