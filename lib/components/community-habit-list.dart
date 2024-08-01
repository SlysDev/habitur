import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:habitur/components/community_challenge_card.dart';
import 'package:habitur/models/community_challenge.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/providers/community_challenge_manager.dart';
import 'package:provider/provider.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/modules/habit_stats_handler.dart';
import 'package:intl/intl.dart';
import 'package:habitur/components/habit_card.dart';

class CommunityHabitList extends StatelessWidget {
  bool isAdmin;
  CommunityHabitList({super.key, this.isAdmin = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunityChallengeManager>(
        builder: (context, communityChallengeManager, child) {
      return Expanded(
        child: SizedBox(
          width: double.infinity,
          child: RefreshIndicator(
            backgroundColor: kPrimaryColor,
            color: kBackgroundColor,
            onRefresh: () async {
              Provider.of<Database>(context, listen: false).loadData(context);
              communityChallengeManager.clearDuplicateChallenges();
            },
            child: ListView.builder(
                itemBuilder: (context, index) {
                  CommunityChallenge currentChallenge =
                      communityChallengeManager.challenges[index];
                  print('Challenge title: ${currentChallenge.habit.title}');
                  return Column(
                    children: [
                      SizedBox(height: 30),
                      CommunityChallengeCard(
                        isAdmin: isAdmin,
                        challenge: currentChallenge,
                      ),
                    ],
                  );
                },
                itemCount: communityChallengeManager.challenges.length),
          ),
        ),
      );
    });
  }
}
