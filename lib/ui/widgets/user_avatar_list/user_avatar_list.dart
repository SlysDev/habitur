import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/widgets/modern_card.dart';
import 'package:habitur/ui/widgets/user_avatar/user_avatar.dart';

class UserAvatarList extends StatelessWidget {
  const UserAvatarList({super.key, required this.usernames, this.limit = 3});

  final List<String> usernames;
  final int limit;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ...usernames
            .take(limit)
            .map((username) => Container(
                  child: UserAvatar(
                    username: username,
                  ),
                ))
            .toList(),
        if (usernames.length > limit)
          Container(
            margin: const EdgeInsets.only(left: 8),
            child: Text(
              '+${usernames.length - limit}',
              style: const TextStyle(color: kGray),
            ),
          ),
      ],
    );
  }
}
