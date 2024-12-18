import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:habitur/models/community_challenge.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/modules/habit_stats_handler.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/data/local/user_local_storage.dart';
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
          currentProgress: 0,
          targetGoal: 4,
          id: Random().nextInt(100000),
          lastSeen: DateTime.now(),
          resetPeriod: "Daily",
          dateCreated: DateTime.now(),
        ))
  ];
  // TODO: At some point remove the completions today tracking with the habits; maybe entire CC manager as well since you'll interact directly with the DB

  UnmodifiableListView<CommunityChallenge> get challenges =>
      UnmodifiableListView(_challenges);

  CommunityChallenge getChallenge(int index) => _challenges[index];

  void setChallenges(List<CommunityChallenge> challenges) {
    _challenges = challenges;
    notifyListeners();
  }

  // Admin Methods
  void addChallenge(CommunityChallenge communityChallenge) {
    if (_challenges.any((challenge) => challenge.id == communityChallenge.id)) {
      return;
    }
    _challenges.add(communityChallenge);
    notifyListeners();
  }

  void editChallenge(int index, CommunityChallenge updatedChallenge) {
    _challenges[index] = updatedChallenge;
    notifyListeners();
  }

  void removeChallenge(int index) {
    _challenges.removeAt(index);
    notifyListeners();
  }

  Future<void> uploadChallengesToDatabase(BuildContext context) async {
    Database db = Database();
    await db.communityChallengeDatabase.uploadCommunityChallenges(context);
    debugPrint('Challenges updated');
    notifyListeners();
  }

  void removeDuplicateChallenges() {
    final uniqueChallenges = _challenges.toSet().toList();
    if (_challenges.length != uniqueChallenges.length) {
      _challenges = uniqueChallenges;
      notifyListeners();
    }
  }

  // Participant Methods
  ParticipantData? getParticipantData(
      BuildContext context, CommunityChallenge challenge, UserModel user) {
    try {
      return challenge.participants
          .firstWhere((participant) => participant.user.uid == user.uid);
    } catch (_) {
      return null;
    }
  }

  ParticipantData? getCurrentUserParticipantData(
      context, CommunityChallenge challenge) {
    ParticipantData? currentParticipant =
        Provider.of<CommunityChallengeManager>(context, listen: false)
            .getParticipantData(
                context,
                challenge,
                Provider.of<UserLocalStorage>(context, listen: false)
                    .currentUser);
    return currentParticipant;
  }
  // TODO: Make commit saying that you're adding the above function and making sure that you're refing the particiapnt data when checking completions and stuff

  void updateParticipantCurrentCompletions(
      BuildContext context, CommunityChallenge challenge, int delta) {
    UserModel user =
        Provider.of<UserLocalStorage>(context, listen: false).currentUser;

    // Use a default ParticipantData if user not found
    final participantData = getParticipantData(context, challenge, user);
    // Update current completions
    if (participantData?.currentCompletions != null) {
      participantData?.currentCompletions += delta;
    } else {
      challenge.addParticipant(ParticipantData(
        user: user,
        lastSeen: DateTime.now(),
        currentCompletions: delta > 0 ? delta : 0,
        fullCompletionCount: 0,
      ));
      debugPrint(
          'User not found in participantDataList, added new participant data.');
    }
  }

  void updateParticipantFullCompletions(
      BuildContext context, CommunityChallenge challenge, int delta) {
    final user =
        Provider.of<UserLocalStorage>(context, listen: false).currentUser;
    final participant = getParticipantData(context, challenge, user);
    participant?.fullCompletionCount += delta;
  }

  bool handleFullCompletion(
      BuildContext context, CommunityChallenge challenge) {
    ParticipantData? currentParticiapnt =
        getCurrentUserParticipantData(context, challenge);
    if (currentParticiapnt?.currentCompletions == challenge.habit.targetGoal) {
      challenge.currentFullCompletions++;
      _addParticipantData(
        context,
        challenge,
        ParticipantData(
          user:
              Provider.of<UserLocalStorage>(context, listen: false).currentUser,
          lastSeen: DateTime.now(),
          fullCompletionCount: 1,
        ),
      );
      debugPrint('Full completion updated');
      return true;
    }
    return false;
  }

  void decrementFullCompletion(
      CommunityChallenge challenge, BuildContext context) {
    challenge.currentFullCompletions--;
    _decrementParticipantData(context, challenge,
        Provider.of<UserLocalStorage>(context, listen: false).currentUser);
  }

  void _addParticipantData(BuildContext context, CommunityChallenge challenge,
      ParticipantData newParticipantData) {
    final existingParticipant =
        getParticipantData(context, challenge, newParticipantData.user);

    if (existingParticipant == null) {
      challenge.addParticipant(newParticipantData);
    }
  }

  void _decrementParticipantData(
      BuildContext context, CommunityChallenge challenge, UserModel user) {
    final participant = getParticipantData(context, challenge, user);

    if (participant != null) {
      participant.currentCompletions =
          max(0, participant.currentCompletions - 1);
      participant.fullCompletionCount =
          max(0, participant.fullCompletionCount - 1);

      if (participant.currentCompletions == 0 &&
          participant.fullCompletionCount == 0) {
        challenge.participants.removeWhere((p) => p.user.uid == user.uid);
      }
    } else {
      debugPrint('User not found in participantDataList');
    }
  }

  void resetParticipantCompletions(
      BuildContext context, CommunityChallenge challenge, UserModel user) {
    final participant = getParticipantData(context, challenge, user);
    participant?.currentCompletions = 0;
  }

  void resetChallengesByPeriod(
      BuildContext context, UserModel user, String period) {
    for (var challenge in _challenges) {
      final participant = getParticipantData(context, challenge, user);
      if (participant == null) {
        continue;
      }
      final habitHandler = HabitStatsHandler(challenge.habit);

      if (challenge.habit.resetPeriod == period) {
        final periodDateFormatter = _getDateFormatForPeriod(period);

        if (periodDateFormatter.format(participant.lastSeen) !=
            periodDateFormatter.format(DateTime.now())) {
          habitHandler.resetHabitCompletions();
          resetParticipantCompletions(context, challenge, user);
          participant.lastSeen = DateTime.now();
        }
      }
    }
    notifyListeners();
  }

  void resetDailyChallenges(BuildContext context, UserModel user) {
    resetChallengesByPeriod(context, user, 'Daily');
  }

  void resetWeeklyChallenges(BuildContext context, UserModel user) {
    resetChallengesByPeriod(context, user, 'Weekly');
  }

  void resetMonthlyChallenges(BuildContext context, UserModel user) {
    resetChallengesByPeriod(context, user, 'Monthly');
  }

  void clearUserParticipantData(String uid) {
    for (CommunityChallenge challenge in _challenges) {
      challenge.participants
          .removeWhere((participant) => participant.user.uid == uid);
    }
  }

  DateFormat _getDateFormatForPeriod(String period) {
    switch (period) {
      case 'Weekly':
        return DateFormat('EEEE'); // Full weekday name, like 'Monday'
      case 'Monthly':
        return DateFormat('M'); // Month as a number
      default:
        return DateFormat('d'); // Day of the month
    }
  }
}
