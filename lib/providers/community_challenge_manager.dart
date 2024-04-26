import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:habitur/models/community_challenge.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/modules/habit_stats_handler.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:provider/provider.dart';

class CommunityChallengeManager extends ChangeNotifier {
  List<CommunityChallenge> _challenges = [
    CommunityChallenge(
        description: "This is a test challenge",
        id: 0,
        requiredFullCompletions: 3,
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        habit: Habit(
          title: "Test",
          completionsToday: 0,
          requiredCompletions: 4,
          resetPeriod: "Daily",
          dateCreated: DateTime.now(),
        ))
  ];

  UnmodifiableListView<CommunityChallenge> get challenges {
    return UnmodifiableListView(_challenges);
  }

  void setChallenges(List<CommunityChallenge> challenges) {
    _challenges = challenges;
    notifyListeners();
  }

  // admin methods

  void addChallenge(CommunityChallenge communityChallenge) {
    _challenges.add(communityChallenge);
    notifyListeners();
  }

  void editChallenge(int index, CommunityChallenge newData) {
    _challenges[index] = newData;
    notifyListeners();
  }

  void removeChallenge(int index) {
    _challenges.removeAt(index);
    notifyListeners();
  }

  void updateChallenges(context) {
    Provider.of<Database>(context, listen: false).uploadData(context);
    print('Challenges updated');
    notifyListeners();
  }
}
