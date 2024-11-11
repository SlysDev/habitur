import 'package:flutter/material.dart';
import 'package:habitur/components/aside_button.dart';
import 'package:habitur/components/community-habit-list.dart';
import 'package:habitur/components/days_of_week_widget.dart';
import 'package:habitur/components/habit_card_list.dart';
import 'package:habitur/components/navbar.dart';
import 'package:habitur/data/data_manager.dart';
import 'package:habitur/data/local/habits_local_storage.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/data/local/settings_local_storage.dart';
import 'package:habitur/providers/network_state_provider.dart';
import 'package:provider/provider.dart';
import '../components/home_greeting_header.dart';
import 'package:habitur/constants.dart';
import '../components/friends_list.dart';
import '../components/received_friend_requests_list.dart';
import '../components/sent_friend_requests_list.dart';
import 'settings_screen.dart';
import 'package:habitur/providers/friends_manager.dart';

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
      endDrawer: Drawer(
        backgroundColor: kBackgroundColor,
        child: Column(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: kFadedBlue,
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 20,
                    left: 20,
                    child: CircleAvatar(
                      backgroundImage: user.profilePicture,
                      radius: 40,
                      backgroundColor: kDarkPrimaryColor.withOpacity(0.2),
                    ),
                  ),
                  Positioned(
                    top: 25,
                    left: 125,
                    right: 20,
                    child: Text(
                      user.username,
                      style: kHeadingTextStyle.copyWith(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 65,
                    left: 125,
                    right: 20,
                    child: Text(
                      user.bio.isEmpty ? 'No bio available.' : user.bio,
                      style: kMainDescription.copyWith(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            ExpansionTile(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.transparent),
              ),
              title: Text('Friends'),
              children: <Widget>[
                FriendsList(),
              ],
            ),
            ExpansionTile(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.transparent),
              ),
              title: Text('Received Friend Requests'),
              children: <Widget>[
                ReceivedFriendRequestsList(),
              ],
            ),
            ExpansionTile(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.transparent),
              ),
              title: Text('Sent Friend Requests'),
              children: <Widget>[
                SentFriendRequestsList(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  _showAddFriendDialog(context);
                },
                child: Text('Add Friend'),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              HomeGreetingHeader(),
              SizedBox(height: 20),
              CommunityHabitList(onRefresh: () async {
                DataManager dataManager = DataManager();
                await dataManager.loadData(context);
              }),
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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Friend'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Enter friend\'s UID'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () async {
                await Provider.of<FriendsManager>(context, listen: false)
                    .sendFriendRequest(_controller.text, context);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
