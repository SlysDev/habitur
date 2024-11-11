import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitur/data/local/user_local_storage.dart';

import '../models/user.dart';

class FriendsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserModel user = Provider.of<UserLocalStorage>(context).currentUser;

    return ListView.builder(
      shrinkWrap: true,
      itemCount: user.friends.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(user.friends[index]),
        );
      },
    );
  }
}