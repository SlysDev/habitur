import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:habitur/models/community_challenge.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/modules/habit_stats_handler.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/user_data.dart';
import 'package:intl/intl.dart';
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
          id: Random().nextInt(100000),
          lastSeen: DateTime.now(),
          resetPeriod: "Daily",
          dateCreated: DateTime.now(),
        ))
  ];

  UnmodifiableListView<CommunityChallenge> get challenges {
    return UnmodifiableListView(_challenges);
  }

  CommunityChallenge getChallenge(int index) {
    return _challenges[index];
  }

  void setChallenges(List<CommunityChallenge> challenges) {
    _challenges = challenges;
    notifyListeners();
  }

  // admin methods

  void addChallenge(CommunityChallenge communityChallenge) {
    for (CommunityChallenge challenge in _challenges) {
      if (challenge.id == communityChallenge.id) {
        return;
      }
    }
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
    Provider.of<Database>(context, listen: false)
        .uploadCommunityChallenges(context);
    print('Challenges updated');
    notifyListeners();
  }

  void clearDuplicateChallenges() {
    for (int i = 0; i < _challenges.length; i++) {
      for (int j = i + 1; j < _challenges.length; j++) {
        if (_challenges[i].id == _challenges[j].id) {
          _challenges.removeAt(j);
          j--;
        }
      }
    }
  }

  void updateParticipantCurrentCompletions(
      BuildContext context, CommunityChallenge challenge, int delta) {
    UserModel user = Provider.of<UserData>(context, listen: false).currentUser;
    dynamic participantData;
    try {
      participantData = challenge.participants
          .firstWhere((element) => element.user.uid == user.uid);
    } catch (e) {
      participantData = null;
    }

    if (participantData != null) {
      participantData.currentCompletions += delta;
    } else {
      challenge.addParticipant(ParticipantData(
          user: user,
          currentCompletions: delta > 0 ? delta : 0,
          fullCompletionCount: 0));
      // Handle case where user is not yet a participant (add them?)
      print('User not found in participantDataList');
    }
  }

  void updateParticipantFullCompletions(
      BuildContext context, CommunityChallenge challenge, int delta) {
    UserModel user = Provider.of<UserData>(context, listen: false).currentUser;
    ParticipantData participantData = challenge.participants.firstWhere(
        (element) => element.user.uid == user.uid,
        orElse: () => ParticipantData(
            user: user,
            currentCompletions: delta > 0 ? delta : 0,
            fullCompletionCount: delta > 0 ? delta : 0));

    participantData.fullCompletionCount += delta;
    if (delta > 0 &&
        participantData.currentCompletions ==
            challenge.habit.requiredCompletions) {
      // User just completed the habit, increment current completions as well
      participantData.currentCompletions++;
    }
  }

// ///

  void incrementParticipantCompletions(
      BuildContext context, CommunityChallenge challenge) {
    addParticipantData(
        context,
        challenge,
        ParticipantData(
            user: Provider.of<UserData>(context, listen: false).currentUser,
            fullCompletionCount: 1,
            currentCompletions: challenge.habit.completionsToday));
  }

  void decrementParticipantCompletions(
      BuildContext context, CommunityChallenge challenge) {
    decrementParticipantData(
        challenge, Provider.of<UserData>(context).currentUser);
  }

  bool checkFullCompletion(BuildContext context, CommunityChallenge challenge) {
    if (challenge.habit.isCompleted == true) {
      challenge.currentFullCompletions++;
      addParticipantData(
          context,
          challenge,
          ParticipantData(
              user: Provider.of<UserData>(context, listen: false).currentUser,
              fullCompletionCount: 1));
      print('updated');
      return true;
    }
    return false;
  }

  void decrementFullCompletion(
      CommunityChallenge challenge, BuildContext context) {
    challenge.currentFullCompletions--;
    decrementParticipantData(
        challenge, Provider.of<UserData>(context, listen: false).currentUser);
  }

  void addParticipantData(BuildContext context, CommunityChallenge challenge,
      ParticipantData newParticipantData) {
    if (challenge.participants
        .where((element) => element.user.uid == newParticipantData.user.uid)
        .isEmpty) {
      challenge.addParticipant(newParticipantData);
    } else {
      ParticipantData currentParticipantData = challenge.participants
          .firstWhere(
              (element) => element.user.uid == newParticipantData.user.uid);
      currentParticipantData.fullCompletionCount +=
          newParticipantData.fullCompletionCount;
      currentParticipantData.currentCompletions +=
          newParticipantData.currentCompletions;
    }
  }

  void decrementParticipantData(CommunityChallenge challenge, UserModel user) {
    ParticipantData participantData = challenge.participants
        .firstWhere((element) => element.user.uid == user.uid);

    if (challenge.participants
        .where((element) => element.user.uid == user.uid)
        .isNotEmpty) {
      if (participantData.fullCompletionCount == 0 &&
          challenge.habit.completionsToday == 0) {
        challenge.participants
            .removeWhere((element) => element.user.uid == user.uid);
      } else {
        participantData.currentCompletions--;
        participantData.fullCompletionCount--;
      }
    } else {
      if (participantData.currentCompletions > 0) {
        participantData.currentCompletions--;
      }
      print('User not found in participantDataList');
    }
  }

  void resetDailyChallenges() {
    for (int i = 0; i < _challenges.length; i++) {
      CommunityChallenge element = _challenges[i];
      HabitStatsHandler habitStatsHandler = HabitStatsHandler(element.habit);
      if (element.habit.resetPeriod == 'Daily') {
        // If the task was not created today, make it incomplete
        if (DateFormat('d').format(element.habit.lastSeen) !=
            DateFormat('d').format(DateTime.now())) {
          habitStatsHandler.resetHabitCompletions();
          element.habit.lastSeen = DateTime.now();
        }
      } else {
        return;
      }
    }
    notifyListeners();
  }

  void resetWeeklyChallenges() {
    for (int i = 0; i < _challenges.length; i++) {
      CommunityChallenge element = _challenges[i];
      HabitStatsHandler habitStatsHandler = HabitStatsHandler(element.habit);
      if (element.habit.resetPeriod == 'Weekly') {
        // If its monday but its not the same day as when the habit was last seen, reset
        if (DateFormat('d').format(element.habit.lastSeen) == 'Monday' &&
            DateFormat('d').format(DateTime.now()) !=
                DateFormat('d').format(element.habit.lastSeen)) {
          habitStatsHandler.resetHabitCompletions();
          element.habit.lastSeen = DateTime.now();
        }
      } else {
        return;
      }
    }
    notifyListeners();
  }

  void resetMonthlyChallenges() {
    for (int i = 0; i < _challenges.length; i++) {
      CommunityChallenge element = _challenges[i];
      HabitStatsHandler habitStatsHandler = HabitStatsHandler(element.habit);
      if (element.habit.resetPeriod == 'Monthly') {
        // If the task was not created this month, make it incomplete
        if (DateFormat('m').format(element.habit.lastSeen) !=
            DateFormat('m').format(DateTime.now())) {
          habitStatsHandler.resetHabitCompletions();
          element.habit.lastSeen = DateTime.now();
        }
      } else {
        return;
      }
    }
    notifyListeners();
  }
}
