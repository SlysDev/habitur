import 'package:flutter/material.dart';
import 'package:habitur/components/aside_button.dart';
import 'package:habitur/components/custom_alert_dialog.dart';
import 'package:habitur/components/filled_text_field.dart';
import 'package:habitur/components/friends_list.dart';
import 'package:habitur/components/home_greeting_header.dart';
import 'package:habitur/components/navbar.dart';
import 'package:habitur/components/profile_drawer.dart';
import 'package:habitur/components/received_friend_requests_list.dart';
import 'package:habitur/components/sent_friend_requests_list.dart';
import 'package:habitur/components/social_feed.dart';
import 'package:habitur/components/user_avatar.dart';
import 'package:habitur/data/data_manager.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/modules/friends_manager.dart';
import 'package:provider/provider.dart';
import 'settings_screen.dart';
import 'package:habitur/constants.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserLocalStorage>(context).currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: ProfileDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              HomeGreetingHeader(),
              SizedBox(height: 20),
              Expanded(
                child: SocialFeed(
                  onRefresh: () async {
                    DataManager dataManager = DataManager();
                    await dataManager.loadData(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBar(
        currentPage: 'home',
      ),
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    final FriendsManager friendsManager = FriendsManager();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: 'Add Friend',
          content: FilledTextField(
            controller: _controller,
            onChanged: (newValue) {},
            hintText: 'Enter account email',
          ),
          actions: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 5),
              child: AsideButton(
                text: 'Cancel',
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 5),
              child: AsideButton(
                text: 'Add',
                onPressed: () async {
                  await friendsManager.sendFriendRequestByUsername(
                      _controller.text, context);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showProfileDialog(BuildContext context) {
    // TODO: implement profile dialog
  }
}
