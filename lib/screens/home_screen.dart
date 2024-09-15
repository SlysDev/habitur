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
import 'package:flutter/material.dart';
import '../components/home_greeting_header.dart';
import 'package:habitur/constants.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
      bottomNavigationBar: NavBar(
        currentPage: 'home',
      ),
    );
  }
}
