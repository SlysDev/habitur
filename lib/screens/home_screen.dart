import 'package:habitur/components/aside_button.dart';
import 'package:habitur/components/community-habit-list.dart';
import 'package:habitur/components/navbar.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/data/local/settings_local_storage.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../components/home_greeting_header.dart';
import 'package:habitur/constants.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    Provider.of<SettingsLocalStorage>(context, listen: false).init();
    super.initState();
  }

  Future<void> loadData(BuildContext context) async {
    try {
      await Provider.of<Database>(context, listen: false).loadUserData(context);
      await Provider.of<Database>(context, listen: false)
          .loadCommunityChallenges(context);
    } catch (e) {
      print(e);
      print('are we loading user data from LS?');
      await Provider.of<UserLocalStorage>(context, listen: false)
          .loadData(context);
    }
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadData(context),
      builder: (context, snapshot) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          actions: [
            Container(
              margin: EdgeInsets.all(5),
              child: IconButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, 'profile-screen'),
                  icon: Icon(
                    Icons.menu_rounded,
                    color: kPrimaryColor,
                    size: 30,
                  )),
            )
          ],
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              snapshot.connectionState == ConnectionState.waiting
                  ? CircularProgressIndicator()
                  : HomeGreetingHeader(),
              CommunityHabitList(),
              AsideButton(
                  text: 'Upload data',
                  onPressed: () {
                    Provider.of<Database>(context, listen: false)
                        .uploadData(context);
                  }),
              AsideButton(
                  text: 'Download data',
                  onPressed: () {
                    Provider.of<Database>(context, listen: false)
                        .loadData(context);
                    print('downloaded');
                  }),
              // HabitCardList(
              //   // Passes network status to card list
              //   isOnline: widget.isOnline,
              // ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
        bottomNavigationBar: NavBar(
          currentPage: 'home',
        ),
      ),
    );
  }
}


    // Checking for the day, will implement try/catch for online/offline later.
    // if (Provider.of<MHabitReset>(context).checkDailyHabits()) {
    //   Provider.of<UserData>(context).resetDailyHabits();
    //   Provider.of<MHabitReset>(context).getDay();
    // } else {
    //   Provider.of<MHabitReset>(context).getDay();
    // }

    // Scheduling with Cron - may implement in the future.
    // final cron = Cron();
    // cron.schedule(Schedule.parse('0 0 * * *'), () async {
    //   try {
    //     Provider.of<UserData>(context, listen: false).resetDailyHabits();
    //   } catch (e, st) {
    //     print(e);
    //   }
    // });
    // cron.schedule(Schedule.parse('0 0 * * 1'), () async {
    //   try {
    //     Provider.of<UserData>(context, listen: false).resetWeeklyHabits();
    //   } catch (e, st) {
    //     print(e);
    //   }
    // });
    // cron.schedule(Schedule.parse('0 0 1 * *'), () async {
    //   try {
    //     Provider.of<UserData>(context, listen: false).resetMonthlyHabits();
    //   } catch (e, st) {
    //     print(e);
    //   }
    // });
