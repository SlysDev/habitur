import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:habitur/models/challenge.dart';
import 'package:habitur/models/habit.dart';

class ChallengeManager extends ChangeNotifier {
  List<Challenge> _challenges = [];

  UnmodifiableListView<Challenge> get challenges {
    return UnmodifiableListView(_challenges);
  }

  createChallenge(String name, String description, List participants, int id,
      DateTime startDate, List creators, DateTime endDate, habit) {
    _challenges.add(Challenge(
        name: name,
        description: description,
        id: id,
        creators: creators,
        startDate: startDate,
        endDate: endDate,
        participants: participants,
        habit: habit));
  }

  deleteChallenge(Challenge challenge) {
    _challenges.remove(challenge);
  }

  void editChallenge(int index, Challenge newData) {
    _challenges[index] = newData;
  }

  addChallengeParticipant(participant, Challenge challenge) {
    _challenges[_challenges.indexOf(challenge)].participants.add(participant);
  }

  removeChallengeParticipant(participant, Challenge challenge) {
    _challenges[_challenges.indexOf(challenge)]
        .participants
        .remove(participant);
  }
}
