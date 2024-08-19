import 'package:flutter/material.dart';
import 'package:habitur/components/community-habit-list.dart';
import 'package:habitur/components/navbar.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/network_state_provider.dart';
import 'package:habitur/screens/add_community_challenge_screen.dart';
import 'package:provider/provider.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CommunityHabitList(
              isAdmin: true,
              onRefresh: () async {
                try {
                  Provider.of<Database>(context, listen: false)
                      .loadCommunityChallenges(context);
                  Provider.of<NetworkStateProvider>(context, listen: false)
                      .isConnected = true;
                } catch (e, s) {
                  print(s);
                  Provider.of<NetworkStateProvider>(context, listen: false)
                      .isConnected = false;
                }
              }),
        ],
      ),
      bottomNavigationBar: NavBar(
        currentPage: 'admin',
        onButtonPress: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            elevation: 20,
            isScrollControlled: true,
            builder: (context) => AddCommunityChallengeScreen(),
          );
        },
      ),
    );
  }
}
