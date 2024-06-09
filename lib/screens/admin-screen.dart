import 'package:flutter/material.dart';
import 'package:habitur/components/community-habit-list.dart';
import 'package:habitur/components/navbar.dart';
import 'package:habitur/screens/add_community_challenge_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CommunityHabitList(isAdmin: true),
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
